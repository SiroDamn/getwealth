import XCTest
@testable import ReihumCore

final class FairnessEngineTests: XCTestCase {
    let start = DayDate(year: 2026, month: 10, day: 1)

    func makePlan(memberCount: Int, weights: [Double]? = nil, days: Int, slotSize: Int = 1, rhythm: Rhythm = .daily) -> Plan {
        let members = (0..<memberCount).map { index in
            Member(name: "M\(index)", weight: weights?[index] ?? 1, colorIndex: index)
        }
        return Plan(name: "Test", rhythm: rhythm, startDate: start, endDate: start.adding(days: days - 1), slotSize: slotSize, members: members)
    }

    func testBalanceInvariantForEqualWeights() {
        let plan = FairnessEngine.regenerate(makePlan(memberCount: 5, days: 100), today: start)
        var counts: [UUID: Int] = [:]
        for slot in plan.sortedSlots {
            XCTAssertEqual(slot.assignedMemberIDs.count, 1)
            for id in slot.assignedMemberIDs { counts[id, default: 0] += 1 }
            let values = plan.members.map { counts[$0.id, default: 0] }
            XCTAssertLessThanOrEqual(values.max()! - values.min()!, 1, "prefix ending \(slot.date) is unbalanced: \(values)")
        }
        XCTAssertEqual(Set(plan.members.map { counts[$0.id, default: 0] }), [20])
    }

    func testAbsencesAreRespected() {
        var plan = makePlan(memberCount: 3, days: 60)
        let absentID = plan.members[0].id
        plan.members[0].absences = [Absence(start: start.adding(days: 4), end: start.adding(days: 19))]
        let result = FairnessEngine.regenerate(plan, today: start)
        for slot in result.slots where slot.date >= start.adding(days: 4) && slot.date <= start.adding(days: 19) {
            XCTAssertFalse(slot.assignedMemberIDs.contains(absentID))
        }
        XCTAssertTrue(result.openSlots.isEmpty)
        // The absent member catches up afterwards: totals stay within a small band.
        let counts = FairnessEngine.assignmentCounts(in: result)
        XCTAssertLessThanOrEqual(counts.values.max()! - counts.values.min()!, 1)
    }

    func testDeterminism() {
        let plan = makePlan(memberCount: 4, days: 90, rhythm: .weekdays)
        let first = FairnessEngine.regenerate(plan, today: start)
        let second = FairnessEngine.regenerate(plan, today: start)
        XCTAssertEqual(first.slots.map { $0.assignedMemberIDs }, second.slots.map { $0.assignedMemberIDs })
    }

    func testWeightsAreProportional() {
        let plan = FairnessEngine.regenerate(makePlan(memberCount: 3, weights: [1, 1, 0.5], days: 200), today: start)
        let counts = FairnessEngine.assignmentCounts(in: plan)
        let full = counts[plan.members[0].id]!
        let half = counts[plan.members[2].id]!
        XCTAssertEqual(full, 80, accuracy: 3)
        XCTAssertEqual(half, 40, accuracy: 3)
    }

    func testTwoPersonSlotsAreDistinct() {
        let plan = FairnessEngine.regenerate(makePlan(memberCount: 5, days: 50, slotSize: 2), today: start)
        for slot in plan.slots {
            XCTAssertEqual(slot.assignedMemberIDs.count, 2)
            XCTAssertEqual(Set(slot.assignedMemberIDs).count, 2)
        }
        let counts = FairnessEngine.assignmentCounts(in: plan)
        XCTAssertLessThanOrEqual(counts.values.max()! - counts.values.min()!, 1)
    }

    func testOpenSlotWhenEverybodyIsAbsent() {
        var plan = makePlan(memberCount: 2, days: 10)
        for index in plan.members.indices {
            plan.members[index].absences = [Absence(start: start.adding(days: 3), end: start.adding(days: 3))]
        }
        let result = FairnessEngine.regenerate(plan, today: start)
        let open = result.openSlots
        XCTAssertEqual(open.count, 1)
        XCTAssertEqual(open.first?.date, start.adding(days: 3))
    }

    func testPartialSlotWhenOnlyOneIsAvailable() {
        var plan = makePlan(memberCount: 2, days: 5, slotSize: 2)
        plan.members[1].absences = [Absence(start: start.adding(days: 2), end: start.adding(days: 2))]
        let result = FairnessEngine.regenerate(plan, today: start)
        let partial = result.sortedSlots[2]
        XCTAssertEqual(partial.assignedMemberIDs, [plan.members[0].id])
    }

    func testRegenerationKeepsHistoryAndManualSlots() {
        let plan = FairnessEngine.regenerate(makePlan(memberCount: 3, days: 40), today: start)
        let today = start.adding(days: 10)
        let manualDate = start.adding(days: 12)
        var edited = plan
        let manualIndex = edited.slots.firstIndex { $0.date == manualDate }!
        let forcedMember = edited.members[2].id
        var manualSlot = edited.slots[manualIndex]
        manualSlot.assignedMemberIDs = [forcedMember]
        edited = FairnessEngine.applyManualEdit(manualSlot, in: edited)
        XCTAssertTrue(edited.slots[manualIndex].isManual)

        edited.members.append(Member(name: "Neu", colorIndex: 3))
        let regenerated = FairnessEngine.regenerate(edited, today: today)

        for (before, after) in zip(plan.sortedSlots, regenerated.sortedSlots) where before.date < today {
            XCTAssertEqual(before.assignedMemberIDs, after.assignedMemberIDs, "history changed at \(before.date)")
        }
        let manualAfter = regenerated.slots.first { $0.date == manualDate }!
        XCTAssertEqual(manualAfter.assignedMemberIDs, [forcedMember])
        XCTAssertTrue(manualAfter.isManual)

        let overwritten = FairnessEngine.regenerate(edited, today: today, overwriteManual: true)
        XCTAssertFalse(overwritten.slots.first { $0.date == manualDate }!.isManual)
    }

    func testHistoryIsKeptWhenRhythmChanges() {
        let plan = FairnessEngine.regenerate(makePlan(memberCount: 3, days: 30), today: start)
        var changed = plan
        changed.rhythm = .weekly(.monday)
        let today = start.adding(days: 10)
        let regenerated = FairnessEngine.regenerate(changed, today: today)
        let historyBefore = plan.sortedSlots.filter { $0.date < today }
        let historyAfter = regenerated.sortedSlots.filter { $0.date < today }
        XCTAssertEqual(historyBefore.map { $0.date }, historyAfter.map { $0.date })
        XCTAssertTrue(regenerated.slots.filter { $0.date >= today }.allSatisfy { $0.date.weekday == .monday })
    }

    func testSwapMarksBothManual() {
        let plan = FairnessEngine.regenerate(makePlan(memberCount: 3, days: 6), today: start)
        let a = plan.sortedSlots[0]
        let b = plan.sortedSlots[1]
        let swapped = FairnessEngine.swap(slotA: a.id, slotB: b.id, in: plan)
        let newA = swapped.slots.first { $0.id == a.id }!
        let newB = swapped.slots.first { $0.id == b.id }!
        XCTAssertEqual(newA.assignedMemberIDs, b.assignedMemberIDs)
        XCTAssertEqual(newB.assignedMemberIDs, a.assignedMemberIDs)
        XCTAssertTrue(newA.isManual && newB.isManual)
        XCTAssertEqual(newA.sequence, a.sequence + 1)
    }

    func testSkippedSlotsStayAndDoNotCount() {
        let plan = FairnessEngine.regenerate(makePlan(memberCount: 2, days: 4), today: start)
        var skipped = plan.sortedSlots[1]
        skipped.isSkipped = true
        skipped.assignedMemberIDs = []
        let edited = FairnessEngine.applyManualEdit(skipped, in: plan)
        let regenerated = FairnessEngine.regenerate(edited, today: start)
        XCTAssertTrue(regenerated.sortedSlots[1].isSkipped)
        XCTAssertEqual(FairnessEngine.assignmentCounts(in: regenerated).values.reduce(0, +), 3)
    }

    func testInactiveMembersAreNotAssigned() {
        var plan = makePlan(memberCount: 3, days: 20)
        plan.members[1].isActive = false
        let result = FairnessEngine.regenerate(plan, today: start)
        XCTAssertFalse(result.slots.contains { $0.assignedMemberIDs.contains(plan.members[1].id) })
    }

    func testPerformanceWithManyMembersAndSlots() {
        let plan = makePlan(memberCount: 50, days: 365)
        measure {
            _ = FairnessEngine.regenerate(plan, today: start)
        }
    }
}
