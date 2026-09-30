import Foundation

/// Hard limits that keep every plan, and every file read back from disk, small, safe and quick to compute.
public enum PlanLimits {
    public static let maxPlans = 200
    public static let maxMembersPerPlan = 100
    public static let maxAbsencesPerMember = 200
    public static let maxSlotsPerPlan = 8000
    public static let maxNameLength = 80
    public static let maxMemberNameLength = 40
    public static let maxNoteLength = 200
    public static let maxSymbolLength = 60
    public static let maxColorIndex = 99
    public static let minYear = 1970
    public static let maxYear = 2200
    public static let minWeight = 0.25
    public static let maxWeight = 4.0
    public static let maxSequence = 1_000_000
    /// Upper size for a file the user imports.
    public static let maxImportBytes = 10_000_000
}

extension Plan {
    /// Trims and clamps user-editable fields so that ordinary input can never make a plan invalid.
    /// Structural problems (too long a period, unknown member IDs, …) are left for `PlanValidator`.
    public func normalized() -> Plan {
        var copy = self
        copy.name = Self.clean(name, fallback: "Plan", maxLength: PlanLimits.maxNameLength)
        copy.symbolName = String(symbolName.prefix(PlanLimits.maxSymbolLength))
        copy.colorIndex = min(max(colorIndex, 0), PlanLimits.maxColorIndex)
        copy.slotSize = min(max(slotSize, 1), 2)
        for index in copy.members.indices {
            let member = members[index]
            copy.members[index].name = Self.clean(member.name, fallback: "Ohne Namen", maxLength: PlanLimits.maxMemberNameLength)
            copy.members[index].weight = member.weight.isFinite
                ? min(max(member.weight, PlanLimits.minWeight), PlanLimits.maxWeight)
                : 1
            copy.members[index].colorIndex = min(max(member.colorIndex, 0), PlanLimits.maxColorIndex)
            for absenceIndex in copy.members[index].absences.indices {
                copy.members[index].absences[absenceIndex].note = Self.note(member.absences[absenceIndex].note)
            }
        }
        for index in copy.slots.indices {
            copy.slots[index].note = Self.note(slots[index].note)
        }
        return copy
    }

    private static func clean(_ text: String, fallback: String, maxLength: Int) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : String(trimmed.prefix(maxLength))
    }

    private static func note(_ text: String?) -> String? {
        guard let text else { return nil }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : String(trimmed.prefix(PlanLimits.maxNoteLength))
    }
}

/// Structural checks. A plan that passes can be stored, shared and recomputed without surprises.
public enum PlanValidator {

    /// A calendar day that exists and lies inside the supported range.
    public static func isAcceptable(_ day: DayDate) -> Bool {
        (PlanLimits.minYear...PlanLimits.maxYear).contains(day.year)
            && (1...12).contains(day.month)
            && (1...31).contains(day.day)
            && day.isValid
    }

    /// The first problem found, described for the user in German, or `nil` when the plan is fine.
    public static func problem(in plan: Plan) -> String? {
        if plan.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return "Der Plan hat keinen Namen." }
        if plan.name.count > PlanLimits.maxNameLength { return "Der Planname ist zu lang (höchstens \(PlanLimits.maxNameLength) Zeichen)." }
        if plan.symbolName.count > PlanLimits.maxSymbolLength { return "Das Symbol ist ungültig." }
        if !(0...PlanLimits.maxColorIndex).contains(plan.colorIndex) { return "Die Farbe ist ungültig." }
        if !(1...2).contains(plan.slotSize) { return "Personen pro Termin muss 1 oder 2 sein." }

        guard isAcceptable(plan.startDate), isAcceptable(plan.endDate) else { return "Start oder Ende des Zeitraums ist kein gültiges Datum." }
        if plan.startDate > plan.endDate { return "Das Ende liegt vor dem Start." }
        if plan.startDate.days(until: plan.endDate) > RhythmGenerator.maximumSpanDays { return "Der Zeitraum ist zu lang (höchstens zehn Jahre)." }

        if plan.members.count > PlanLimits.maxMembersPerPlan { return "Zu viele Personen (höchstens \(PlanLimits.maxMembersPerPlan))." }
        guard Set(plan.members.map(\.id)).count == plan.members.count else { return "Eine Person kommt doppelt vor." }
        for member in plan.members {
            if member.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return "Eine Person hat keinen Namen." }
            if member.name.count > PlanLimits.maxMemberNameLength { return "Ein Name ist zu lang (höchstens \(PlanLimits.maxMemberNameLength) Zeichen)." }
            if !member.weight.isFinite || member.weight < PlanLimits.minWeight || member.weight > PlanLimits.maxWeight {
                return "Der Anteil von «\(member.name.prefix(20))» ist ungültig."
            }
            if !(0...PlanLimits.maxColorIndex).contains(member.colorIndex) { return "Die Farbe einer Person ist ungültig." }
            if member.absences.count > PlanLimits.maxAbsencesPerMember { return "Zu viele Abwesenheiten bei «\(member.name.prefix(20))»." }
            for absence in member.absences {
                guard isAcceptable(absence.start), isAcceptable(absence.end), absence.start <= absence.end else {
                    return "Eine Abwesenheit von «\(member.name.prefix(20))» ist ungültig."
                }
                if (absence.note?.count ?? 0) > PlanLimits.maxNoteLength { return "Ein Abwesenheitshinweis ist zu lang." }
            }
        }

        if plan.slots.count > PlanLimits.maxSlotsPerPlan { return "Zu viele Termine (höchstens \(PlanLimits.maxSlotsPerPlan))." }
        guard Set(plan.slots.map(\.id)).count == plan.slots.count else { return "Ein Termin kommt doppelt vor." }
        guard Set(plan.slots.map(\.date)).count == plan.slots.count else { return "Ein Datum hat mehrere Termine." }
        let knownMembers = Set(plan.members.map(\.id))
        for slot in plan.slots {
            guard isAcceptable(slot.date) else { return "Ein Termin hat kein gültiges Datum." }
            if slot.assignedMemberIDs.count > 2 { return "Ein Termin hat mehr als zwei Personen." }
            if Set(slot.assignedMemberIDs).count != slot.assignedMemberIDs.count { return "Eine Person ist einem Termin doppelt zugeteilt." }
            if !slot.assignedMemberIDs.allSatisfy(knownMembers.contains) { return "Ein Termin verweist auf eine unbekannte Person." }
            if (slot.note?.count ?? 0) > PlanLimits.maxNoteLength { return "Eine Terminnotiz ist zu lang." }
            if !(0...PlanLimits.maxSequence).contains(slot.sequence) { return "Ein Termin hat eine ungültige Versionsnummer." }
        }
        return nil
    }
}
