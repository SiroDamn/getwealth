import XCTest
@testable import ReihumCore

final class ValidationTests: XCTestCase {
    func testRegeneratedPlanIsValid() {
        XCTAssertNil(PlanValidator.problem(in: Fixture.plan()))
    }

    func testEachStructuralProblemIsDetected() {
        func expectProblem(_ message: String, _ change: (inout Plan) -> Void, file: StaticString = #filePath, line: UInt = #line) {
            var plan = Fixture.plan()
            change(&plan)
            XCTAssertNotNil(PlanValidator.problem(in: plan), message, file: file, line: line)
        }
        expectProblem("empty name") { $0.name = "   " }
        expectProblem("long name") { $0.name = String(repeating: "x", count: PlanLimits.maxNameLength + 1) }
        expectProblem("slot size 3") { $0.slotSize = 3 }
        expectProblem("slot size 0") { $0.slotSize = 0 }
        expectProblem("start after end") { $0.startDate = $0.endDate.adding(days: 1) }
        expectProblem("period too long") { $0.endDate = $0.startDate.adding(days: RhythmGenerator.maximumSpanDays + 1) }
        expectProblem("impossible date") { $0.endDate = DayDate(year: 2027, month: 2, day: 30) }
        expectProblem("year out of range") { $0.startDate = DayDate(year: 1800, month: 1, day: 1) }
        expectProblem("weight zero") { $0.members[0].weight = 0 }
        expectProblem("weight nan") { $0.members[0].weight = .nan }
        expectProblem("weight infinite") { $0.members[0].weight = .infinity }
        expectProblem("weight too big") { $0.members[0].weight = 100 }
        expectProblem("empty member name") { $0.members[0].name = "" }
        expectProblem("duplicate member id") { $0.members[1].id = $0.members[0].id }
        expectProblem("unknown member in slot") { $0.slots[0].assignedMemberIDs = [UUID()] }
        expectProblem("three people in a slot") { plan in
            let extra = (0..<3).map { _ in Member(name: "X") }
            plan.members += extra
            plan.slots[0].assignedMemberIDs = extra.map(\.id)
        }
        expectProblem("same person twice in a slot") { $0.slots[0].assignedMemberIDs = [$0.members[0].id, $0.members[0].id] }
        expectProblem("duplicate slot date") { $0.slots[1].date = $0.slots[0].date }
        expectProblem("duplicate slot id") { $0.slots[1].id = $0.slots[0].id }
        expectProblem("bad slot date") { $0.slots[0].date = DayDate(year: 2026, month: 13, day: 1) }
        expectProblem("negative sequence") { $0.slots[0].sequence = -1 }
        expectProblem("absence reversed") { plan in
            var absence = Absence(start: Fixture.start, end: Fixture.start)
            absence.start = Fixture.start.adding(days: 3)
            plan.members[0].absences = [absence]
        }
        expectProblem("too many members") { plan in
            plan.members = (0...PlanLimits.maxMembersPerPlan).map { Member(name: "M\($0)") }
            plan.slots = []
        }
    }

    func testNormalizingMakesOrdinaryInputValid() {
        var plan = Fixture.plan()
        plan.name = "  " + String(repeating: "N", count: 300) + "  "
        plan.members[0].name = ""
        plan.members[1].name = String(repeating: "B", count: 100)
        plan.members[2].weight = .nan
        plan.members[0].weight = 99
        plan.members[0].colorIndex = -5
        plan.slots[0].note = String(repeating: "n", count: 500)
        plan.symbolName = String(repeating: "s", count: 200)
        XCTAssertNotNil(PlanValidator.problem(in: plan))

        let cleaned = plan.normalized()
        XCTAssertNil(PlanValidator.problem(in: cleaned))
        XCTAssertEqual(cleaned.name.count, PlanLimits.maxNameLength)
        XCTAssertEqual(cleaned.members[0].name, "Ohne Namen")
        XCTAssertEqual(cleaned.members[1].name.count, PlanLimits.maxMemberNameLength)
        XCTAssertEqual(cleaned.members[2].weight, 1)
        XCTAssertEqual(cleaned.members[0].weight, PlanLimits.maxWeight)
        XCTAssertEqual(cleaned.members[0].colorIndex, 0)
        XCTAssertEqual(cleaned.slots[0].note?.count, PlanLimits.maxNoteLength)
    }

    func testNormalizingDoesNotChangeAValidPlan() {
        let plan = Fixture.plan()
        XCTAssertEqual(plan.normalized(), plan)
    }
}
