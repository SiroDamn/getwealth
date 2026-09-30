import Foundation

public struct Absence: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var start: DayDate
    public var end: DayDate
    public var note: String?

    public init(id: UUID = UUID(), start: DayDate, end: DayDate, note: String? = nil) {
        self.id = id
        self.start = min(start, end)
        self.end = max(start, end)
        self.note = note
    }

    public func contains(_ day: DayDate) -> Bool { start <= day && day <= end }
}

public struct Member: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var name: String
    /// Relative share of turns: 0.5 = half as often as a member with weight 1.
    public var weight: Double
    public var colorIndex: Int
    public var isActive: Bool
    public var absences: [Absence]

    public init(id: UUID = UUID(), name: String, weight: Double = 1, colorIndex: Int = 0, isActive: Bool = true, absences: [Absence] = []) {
        self.id = id
        self.name = name
        self.weight = weight
        self.colorIndex = colorIndex
        self.isActive = isActive
        self.absences = absences
    }

    public func isAbsent(on day: DayDate) -> Bool {
        absences.contains { $0.contains(day) }
    }

    /// Up to two initials, e.g. "Anna Meier" → "AM", "Ben" → "B".
    public var initials: String {
        let parts = name.split(separator: " ").prefix(2)
        let letters = parts.compactMap { $0.first }.map { String($0).uppercased() }
        return letters.joined()
    }
}

public struct Slot: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var date: DayDate
    /// Assigned members in display order. Empty and not skipped means "open".
    public var assignedMemberIDs: [UUID]
    /// Set by the user (manual assignment or swap). Protected from regeneration unless explicitly overwritten.
    public var isManual: Bool
    public var isSkipped: Bool
    public var note: String?
    /// Incremented whenever the assignment changes; exported as the iCalendar SEQUENCE.
    public var sequence: Int

    public init(id: UUID = UUID(), date: DayDate, assignedMemberIDs: [UUID] = [], isManual: Bool = false, isSkipped: Bool = false, note: String? = nil, sequence: Int = 0) {
        self.id = id
        self.date = date
        self.assignedMemberIDs = assignedMemberIDs
        self.isManual = isManual
        self.isSkipped = isSkipped
        self.note = note
        self.sequence = sequence
    }

    public var isOpen: Bool { !isSkipped && assignedMemberIDs.isEmpty }
}

public struct Plan: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var name: String
    public var symbolName: String
    public var colorIndex: Int
    public var rhythm: Rhythm
    public var startDate: DayDate
    public var endDate: DayDate
    /// Members per turn (1 or 2).
    public var slotSize: Int
    /// Shows the "Erstellt mit Reihum" line on shared images.
    public var showAttribution: Bool
    public var createdAt: Date
    public var updatedAt: Date
    public var members: [Member]
    public var slots: [Slot]

    public init(id: UUID = UUID(), name: String, symbolName: String = "person.2", colorIndex: Int = 0, rhythm: Rhythm, startDate: DayDate, endDate: DayDate, slotSize: Int = 1, showAttribution: Bool = true, createdAt: Date = Date(), updatedAt: Date = Date(), members: [Member] = [], slots: [Slot] = []) {
        self.id = id
        self.name = name
        self.symbolName = symbolName
        self.colorIndex = colorIndex
        self.rhythm = rhythm
        self.startDate = min(startDate, endDate)
        self.endDate = max(startDate, endDate)
        self.slotSize = max(1, min(slotSize, 2))
        self.showAttribution = showAttribution
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.members = members
        self.slots = slots
    }

    public var activeMembers: [Member] { members.filter { $0.isActive } }

    public func member(id: UUID) -> Member? { members.first { $0.id == id } }

    public func names(for slot: Slot) -> [String] {
        slot.assignedMemberIDs.map { member(id: $0)?.name ?? "?" }
    }

    public var sortedSlots: [Slot] { slots.sorted { $0.date < $1.date } }

    public func nextSlot(onOrAfter day: DayDate) -> Slot? {
        sortedSlots.first { $0.date >= day && !$0.isSkipped }
    }

    public var openSlots: [Slot] { slots.filter { $0.isOpen } }
}
