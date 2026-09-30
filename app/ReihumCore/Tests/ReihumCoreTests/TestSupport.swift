import Foundation
@testable import ReihumCore

enum Fixture {
    static let start = DayDate(year: 2026, month: 10, day: 2)

    /// A valid, regenerated plan with whole-second timestamps so that JSON round-trips compare equal.
    static func plan(name: String = "Znüni", days: Int = 28, members: [String] = ["Anna", "Ben", "Cara"]) -> Plan {
        let people = members.enumerated().map { Member(name: $0.element, colorIndex: $0.offset) }
        var plan = Plan(name: name, rhythm: .weekly(.friday), startDate: start, endDate: start.adding(days: days - 1), members: people)
        plan = FairnessEngine.regenerate(plan, today: start)
        plan.createdAt = Date(timeIntervalSince1970: 1_790_000_000)
        plan.updatedAt = plan.createdAt
        return plan
    }
}

/// Deterministic pseudo-random numbers, so a failing fuzz run can be reproduced.
struct SplitMix64: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
