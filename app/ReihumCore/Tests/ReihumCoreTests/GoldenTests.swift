import XCTest
@testable import ReihumCore

/// Shared scenarios for the Swift engine and its JavaScript port (web-prototype).
/// Swift is the reference: `REIHUM_WRITE_GOLDEN=1 swift test` rewrites golden.json, and both sides must reproduce it.
final class GoldenTests: XCTestCase {
    struct Scenario: Decodable { let name: String; let plan: PlanSpec; let ops: [Op] }
    struct PlanSpec: Decodable { let rhythm: RhythmSpec; let start: String; let end: String; let slotSize: Int; let members: [MemberSpec] }
    struct MemberSpec: Decodable { let name: String; let weight: Double?; let active: Bool?; let absences: [[String]]? }
    struct RhythmSpec: Decodable { let kind: String; let weekday: Int?; let ordinal: Int?; let day: Int? }
    struct Op: Decodable {
        let op: String
        let today: String?; let overwriteManual: Bool?
        let date: String?; let names: [String]?
        let member: String?; let start: String?; let end: String?; let value: Double?
        let a: String?; let b: String?
        let rhythm: RhythmSpec?
    }
    struct Output: Codable, Equatable {
        struct Row: Codable, Equatable { let date: String; let names: [String]; let manual: Bool; let skipped: Bool; let sequence: Int }
        let name: String
        let slots: [Row]
        let counts: [String: Int]
    }

    private func directory() throws -> URL {
        if let override = ProcessInfo.processInfo.environment["REIHUM_GOLDEN_DIR"] { return URL(fileURLWithPath: override) }
        var url = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 { url.deleteLastPathComponent() }
        return url.appendingPathComponent("web-prototype/test")
    }

    private func day(_ iso: String) -> DayDate {
        let parts = iso.split(separator: "-").compactMap { Int($0) }
        return DayDate(year: parts[0], month: parts[1], day: parts[2])
    }

    private func rhythm(_ spec: RhythmSpec) -> Rhythm {
        let weekday = Weekday(rawValue: spec.weekday ?? 2) ?? .monday
        switch spec.kind {
        case "daily": return .daily
        case "weekdays": return .weekdays
        case "weekly": return .weekly(weekday)
        case "biweekly": return .biweekly(weekday)
        case "monthlyNth": return .monthlyNthWeekday(ordinal: spec.ordinal ?? 1, weekday: weekday)
        case "monthlyDay": return .monthlyDay(spec.day ?? 1)
        default: fatalError("unknown rhythm \(spec.kind)")
        }
    }

    private func run(_ scenario: Scenario) -> Output {
        var ids: [String: UUID] = [:]
        var members: [Member] = []
        for (index, spec) in scenario.plan.members.enumerated() {
            let id = UUID(); ids[spec.name] = id
            members.append(Member(id: id, name: spec.name, weight: spec.weight ?? 1, colorIndex: index, isActive: spec.active ?? true,
                                  absences: (spec.absences ?? []).map { Absence(start: day($0[0]), end: day($0[1])) }))
        }
        var plan = Plan(name: scenario.name, rhythm: rhythm(scenario.plan.rhythm), startDate: day(scenario.plan.start), endDate: day(scenario.plan.end),
                        slotSize: scenario.plan.slotSize, members: members)
        func slot(_ iso: String) -> Slot { plan.slots.first { $0.date == day(iso) }! }
        func memberIndex(_ name: String) -> Int { plan.members.firstIndex { $0.id == ids[name]! }! }

        for op in scenario.ops {
            switch op.op {
            case "regen": plan = FairnessEngine.regenerate(plan, today: day(op.today!), overwriteManual: op.overwriteManual ?? false)
            case "manual":
                var edited = slot(op.date!); edited.assignedMemberIDs = op.names!.map { ids[$0]! }
                plan = FairnessEngine.applyManualEdit(edited, in: plan)
            case "skip":
                var edited = slot(op.date!); edited.isSkipped = true; edited.assignedMemberIDs = []
                plan = FairnessEngine.applyManualEdit(edited, in: plan)
            case "swap": plan = FairnessEngine.swap(slotA: slot(op.a!).id, slotB: slot(op.b!).id, in: plan)
            case "absence": plan.members[memberIndex(op.member!)].absences.append(Absence(start: day(op.start!), end: day(op.end!)))
            case "weight": plan.members[memberIndex(op.member!)].weight = op.value!
            case "deactivate": plan.members[memberIndex(op.member!)].isActive = false
            case "addMember":
                let id = UUID(); ids[op.member!] = id
                plan.members.append(Member(id: id, name: op.member!, weight: op.value ?? 1, colorIndex: plan.members.count))
            case "rhythm":
                plan.rhythm = rhythm(op.rhythm!)
                if let start = op.start { plan.startDate = day(start) }
                if let end = op.end { plan.endDate = day(end) }
            default: fatalError("unknown op \(op.op)")
            }
        }
        let counts = FairnessEngine.assignmentCounts(in: plan)
        return Output(
            name: scenario.name,
            slots: plan.sortedSlots.map { .init(date: $0.date.iso, names: plan.names(for: $0), manual: $0.isManual, skipped: $0.isSkipped, sequence: $0.sequence) },
            counts: Dictionary(uniqueKeysWithValues: plan.members.map { ($0.name, counts[$0.id] ?? 0) })
        )
    }

    func testScenariosMatchTheGoldenFile() throws {
        let dir = try directory()
        let scenariosURL = dir.appendingPathComponent("scenarios.json")
        guard FileManager.default.fileExists(atPath: scenariosURL.path) else {
            throw XCTSkip("scenarios.json not found next to the package (\(dir.path)); set REIHUM_GOLDEN_DIR")
        }
        let scenarios = try JSONDecoder().decode([Scenario].self, from: Data(contentsOf: scenariosURL))
        let outputs = scenarios.map(run)
        XCTAssertGreaterThan(outputs.count, 10)

        let goldenURL = dir.appendingPathComponent("golden.json")
        if ProcessInfo.processInfo.environment["REIHUM_WRITE_GOLDEN"] == "1" {
            let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            try encoder.encode(outputs).write(to: goldenURL)
            return
        }
        let golden = try JSONDecoder().decode([Output].self, from: Data(contentsOf: goldenURL))
        XCTAssertEqual(golden.count, outputs.count)
        for (expected, actual) in zip(golden, outputs) { XCTAssertEqual(actual, expected, "scenario: \(expected.name)") }
    }
}
