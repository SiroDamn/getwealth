import XCTest
@testable import ReihumCore

final class PlanStoreTests: XCTestCase {
    private var folder: URL!
    private var file: URL { folder.appendingPathComponent("plans.json") }

    override func setUpWithError() throws {
        folder = FileManager.default.temporaryDirectory.appendingPathComponent("reihum-tests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: folder)
    }

    private func store(now: @escaping () -> Date = { Date(timeIntervalSince1970: 1_790_000_000) }) -> PlanStore {
        PlanStore(fileURL: file, now: now)
    }

    private func unreadableFiles() throws -> [URL] {
        try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil).filter { $0.lastPathComponent.contains("unreadable") }
    }

    func testStartsEmptyWithoutAFile() {
        let s = store()
        XCTAssertTrue(s.plans.isEmpty)
        XCTAssertNil(s.lastError)
        XCTAssertFalse(FileManager.default.fileExists(atPath: file.path))
    }

    func testChangesSurviveARestart() {
        let s = store()
        let first = Fixture.plan(name: "Eins")
        let second = Fixture.plan(name: "Zwei")
        XCTAssertTrue(s.add(first))
        XCTAssertTrue(s.add(second))

        var renamed = first
        renamed.name = "Eins umbenannt"
        XCTAssertTrue(s.update(renamed))
        s.delete(id: second.id)

        let reopened = store()
        XCTAssertEqual(reopened.plans.map(\.name), ["Eins umbenannt"])
        XCTAssertEqual(reopened.plan(id: first.id)?.slots, first.slots)

        reopened.deleteAll()
        XCTAssertTrue(store().plans.isEmpty)
    }

    func testInvalidPlanIsRejectedAndNothingIsWritten() {
        let s = store()
        var bad = Fixture.plan()
        bad.endDate = bad.startDate.adding(days: RhythmGenerator.maximumSpanDays + 50)
        XCTAssertFalse(s.add(bad))
        XCTAssertNotNil(s.lastError)
        XCTAssertTrue(s.plans.isEmpty)
        XCTAssertFalse(FileManager.default.fileExists(atPath: file.path))
    }

    func testUpdateOfUnknownPlanDoesNothing() {
        let s = store()
        XCTAssertFalse(s.update(Fixture.plan()))
        XCTAssertTrue(s.plans.isEmpty)
    }

    func testOrdinaryInputIsNormalisedInsteadOfRejected() {
        let s = store()
        var plan = Fixture.plan()
        plan.name = "  " + String(repeating: "x", count: 200)
        plan.members[0].name = ""
        XCTAssertTrue(s.add(plan))
        XCTAssertEqual(s.plans[0].name.count, PlanLimits.maxNameLength)
        XCTAssertEqual(s.plans[0].members[0].name, "Ohne Namen")
        XCTAssertEqual(store().plans.count, 1) // and it loads again
    }

    func testPlanCountIsLimited() {
        let s = store()
        for _ in 0..<PlanLimits.maxPlans {
            XCTAssertTrue(s.add(Plan(name: "P", rhythm: .daily, startDate: Fixture.start, endDate: Fixture.start.adding(days: 1), members: [Member(name: "A")])))
        }
        XCTAssertFalse(s.add(Fixture.plan()))
        XCTAssertEqual(s.plans.count, PlanLimits.maxPlans)
    }

    func testCorruptFileIsMovedAsideNotOverwritten() throws {
        let garbage = Data("das ist keine json datei {{{".utf8)
        try garbage.write(to: file)

        let s = store()
        XCTAssertTrue(s.plans.isEmpty)
        XCTAssertNotNil(s.lastError)
        XCTAssertFalse(FileManager.default.fileExists(atPath: file.path))
        let saved = try unreadableFiles()
        XCTAssertEqual(saved.count, 1)
        XCTAssertEqual(try Data(contentsOf: saved[0]), garbage)
        XCTAssertTrue(saved[0].lastPathComponent.contains("19700101") == false)

        // Continuing to use the app must not destroy the saved copy.
        XCTAssertTrue(s.add(Fixture.plan(name: "Neu")))
        XCTAssertEqual(try Data(contentsOf: try unreadableFiles()[0]), garbage)
        XCTAssertEqual(store().plans.map(\.name), ["Neu"])
    }

    func testFileFromANewerVersionIsKeptToo() throws {
        let future = Data("{\"schemaVersion\":2,\"plans\":[]}".utf8)
        try future.write(to: file)
        let s = store()
        XCTAssertNotNil(s.lastError)
        XCTAssertTrue(s.lastError?.contains("neueren Version") == true)
        XCTAssertEqual(try Data(contentsOf: try unreadableFiles()[0]), future)
    }

    func testRepeatedCorruptionKeepsEveryCopy() throws {
        for round in 1...3 {
            try Data("kaputt \(round)".utf8).write(to: file)
            _ = store() // same clock value each time: names must not collide
        }
        XCTAssertEqual(try unreadableFiles().count, 3)
    }

    func testImportMergesReplacesAndCountsPlans() throws {
        let a = store()
        let existing = Fixture.plan(name: "Bleibt")
        let replaced = Fixture.plan(name: "Alt")
        XCTAssertTrue(a.add(existing))
        XCTAssertTrue(a.add(replaced))

        var newVersion = replaced
        newVersion.name = "Neu"
        let incoming = try BackupCodec.encode([newVersion, Fixture.plan(name: "Dazu")])
        XCTAssertEqual(try a.importJSON(incoming), 2)
        XCTAssertEqual(a.plans.map(\.name), ["Bleibt", "Neu", "Dazu"])
        XCTAssertEqual(store().plans.map(\.name), ["Bleibt", "Neu", "Dazu"])
    }

    func testImportIsAllOrNothing() throws {
        let s = store()
        XCTAssertTrue(s.add(Fixture.plan(name: "Vorhanden")))
        var bad = Fixture.plan(name: "Kaputt")
        bad.members[0].weight = 0
        let data = try BackupCodec.encode([Fixture.plan(name: "Gut"), bad])
        XCTAssertThrowsError(try s.importJSON(data))
        XCTAssertEqual(s.plans.map(\.name), ["Vorhanden"])
        XCTAssertThrowsError(try s.importJSON(Data("nope".utf8)))
        XCTAssertEqual(s.plans.map(\.name), ["Vorhanden"])
    }

    func testExportThenImportIntoAnotherStore() throws {
        let a = store()
        XCTAssertTrue(a.add(Fixture.plan(name: "Eins")))
        XCTAssertTrue(a.add(Fixture.plan(name: "Zwei")))
        let data = try a.exportJSON()

        let otherFolder = folder.appendingPathComponent("other")
        let b = PlanStore(fileURL: otherFolder.appendingPathComponent("plans.json"))
        XCTAssertEqual(try b.importJSON(data), 2)
        XCTAssertEqual(b.plans, a.plans)
    }

    func testDidSaveHookRunsOnlyAfterSuccessfulSaves() {
        let s = store()
        var calls = 0
        var lastCount = 0
        s.onDidSave = { plans in calls += 1; lastCount = plans.count }

        XCTAssertTrue(s.add(Fixture.plan()))
        XCTAssertEqual(calls, 1)
        XCTAssertEqual(lastCount, 1)

        var bad = Fixture.plan()
        bad.members[0].id = bad.members[1].id
        XCTAssertFalse(s.add(bad))
        XCTAssertEqual(calls, 1)
    }

    func testRegenerateUsesTheGivenToday() {
        let s = store()
        let plan = Fixture.plan(days: 28)
        let today = Fixture.start.adding(days: 14)
        let result = s.regenerate(plan, today: today)
        for (before, after) in zip(plan.sortedSlots, result.sortedSlots) where before.date < today {
            XCTAssertEqual(before.assignedMemberIDs, after.assignedMemberIDs)
        }
    }
}
