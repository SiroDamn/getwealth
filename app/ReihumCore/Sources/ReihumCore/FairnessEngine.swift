import Foundation

/// Deterministic, explainable turn assignment.
///
/// Rules:
/// 1. Past slots, skipped slots and manual slots are frozen and count towards each member's load.
/// 2. Every other turn date gets the members with the lowest normalised load (assignments ÷ weight).
/// 3. Ties: the member whose last turn is longest ago, then the stable member order.
/// 4. A date on which nobody is available becomes an "open" slot.
public enum FairnessEngine {

    /// Recomputes all non-frozen slots of `input` for its rhythm and period.
    /// - Parameters:
    ///   - today: slots before this day are history and never change.
    ///   - overwriteManual: when true, manual future slots are recomputed as well.
    public static func regenerate(_ input: Plan, today: DayDate, overwriteManual: Bool = false) -> Plan {
        var plan = input
        let dates = RhythmGenerator.dates(for: plan.rhythm, from: plan.startDate, to: plan.endDate)
        let dateSet = Set(dates)

        // 1. Frozen slots: history, skipped, manual (unless overwritten). Future frozen slots that
        //    no longer belong to the rhythm are dropped; history is always kept.
        var frozen: [DayDate: Slot] = [:]
        for slot in plan.slots {
            let isPast = slot.date < today
            let keepManual = slot.isManual && !overwriteManual
            guard isPast || keepManual || slot.isSkipped else { continue }
            guard isPast || dateSet.contains(slot.date) else { continue }
            frozen[slot.date] = slot
        }

        // 2. Load and last turn from frozen slots.
        var load: [UUID: Double] = [:]
        var lastTurn: [UUID: DayDate] = [:]
        for slot in frozen.values.sorted(by: { $0.date < $1.date }) where !slot.isSkipped {
            for id in slot.assignedMemberIDs {
                load[id, default: 0] += 1
                if let previous = lastTurn[id], previous >= slot.date { continue }
                lastTurn[id] = slot.date
            }
        }

        // 3. Compute the rest in date order.
        let existingByDate = Dictionary(plan.slots.map { ($0.date, $0) }, uniquingKeysWith: { first, _ in first })
        let indexedMembers = Array(plan.activeMembers.enumerated())
        var result = Array(frozen.values)

        for date in dates where frozen[date] == nil {
            var slot = existingByDate[date] ?? Slot(date: date)
            let candidates = indexedMembers.filter { !$0.element.isAbsent(on: date) }
            let ranked = candidates.sorted { lhs, rhs in
                let lhsLoad = load[lhs.element.id, default: 0] / max(lhs.element.weight, 0.25)
                let rhsLoad = load[rhs.element.id, default: 0] / max(rhs.element.weight, 0.25)
                if lhsLoad != rhsLoad { return lhsLoad < rhsLoad }
                let lhsLast = lastTurn[lhs.element.id] ?? .distantPast
                let rhsLast = lastTurn[rhs.element.id] ?? .distantPast
                if lhsLast != rhsLast { return lhsLast < rhsLast }
                return lhs.offset < rhs.offset
            }
            let chosen = Array(ranked.prefix(plan.slotSize).map { $0.element.id })
            if chosen != slot.assignedMemberIDs { slot.sequence += 1 }
            slot.assignedMemberIDs = chosen
            slot.isManual = false
            slot.isSkipped = false
            for id in chosen {
                load[id, default: 0] += 1
                lastTurn[id] = date
            }
            result.append(slot)
        }

        plan.slots = result.sorted { $0.date < $1.date }
        plan.updatedAt = Date()
        return plan
    }

    /// Number of turns per member over all non-skipped slots.
    public static func assignmentCounts(in plan: Plan) -> [UUID: Int] {
        var counts: [UUID: Int] = [:]
        for member in plan.members { counts[member.id] = 0 }
        for slot in plan.slots where !slot.isSkipped {
            for id in slot.assignedMemberIDs { counts[id, default: 0] += 1 }
        }
        return counts
    }

    /// Exchanges the assignments of two slots and marks both as manual.
    public static func swap(slotA: UUID, slotB: UUID, in plan: Plan) -> Plan {
        guard let indexA = plan.slots.firstIndex(where: { $0.id == slotA }),
              let indexB = plan.slots.firstIndex(where: { $0.id == slotB }),
              indexA != indexB else { return plan }
        var updated = plan
        let assignmentsA = updated.slots[indexA].assignedMemberIDs
        updated.slots[indexA].assignedMemberIDs = updated.slots[indexB].assignedMemberIDs
        updated.slots[indexB].assignedMemberIDs = assignmentsA
        for index in [indexA, indexB] {
            updated.slots[index].isManual = true
            updated.slots[index].sequence += 1
        }
        updated.updatedAt = Date()
        return updated
    }

    /// Replaces one slot (manual edit) and marks it manual when the assignment or skip state changed.
    public static func applyManualEdit(_ edited: Slot, in plan: Plan) -> Plan {
        guard let index = plan.slots.firstIndex(where: { $0.id == edited.id }) else { return plan }
        var updated = plan
        var slot = edited
        let previous = updated.slots[index]
        if previous.assignedMemberIDs != slot.assignedMemberIDs || previous.isSkipped != slot.isSkipped {
            slot.isManual = true
            slot.sequence = previous.sequence + 1
        }
        updated.slots[index] = slot
        updated.updatedAt = Date()
        return updated
    }
}
