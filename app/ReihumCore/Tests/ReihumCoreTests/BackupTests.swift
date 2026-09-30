import XCTest
@testable import ReihumCore

final class BackupTests: XCTestCase {
    func testRoundTripKeepsEverything() throws {
        let plans = [Fixture.plan(name: "A"), Fixture.plan(name: "B", days: 14, members: ["X", "Y"])]
        for pretty in [false, true] {
            let data = try BackupCodec.encode(plans, pretty: pretty)
            XCTAssertEqual(try BackupCodec.decode(data), plans)
        }
    }

    func testEmptyBackupIsValid() throws {
        XCTAssertEqual(try BackupCodec.decode(try BackupCodec.encode([])), [])
    }

    func testRejectsFilesThatAreNotBackups() {
        let bad: [String] = ["", "not json", "[]", "{}", "{\"plans\":[]}", "{\"schemaVersion\":\"1\",\"plans\":[]}", "{\"schemaVersion\":0,\"plans\":[]}", "{\"schemaVersion\":-3,\"plans\":[]}", "null", "42"]
        for text in bad {
            XCTAssertThrowsError(try BackupCodec.decode(Data(text.utf8)), "should reject: \(text)") { error in
                XCTAssertEqual(error as? BackupError, .notABackup)
            }
        }
    }

    func testValidHeaderButWrongBodyIsNotABackup() {
        let text = "{\"schemaVersion\":1,\"exportedAt\":\"2026-10-02T12:00:00Z\",\"plans\":\"nope\"}"
        XCTAssertThrowsError(try BackupCodec.decode(Data(text.utf8))) { XCTAssertEqual($0 as? BackupError, .notABackup) }
    }

    func testNewerSchemaIsReportedAsNewerVersionEvenIfShapeDiffers() {
        let text = "{\"schemaVersion\":2,\"somethingNew\":true}"
        XCTAssertThrowsError(try BackupCodec.decode(Data(text.utf8))) { XCTAssertEqual($0 as? BackupError, .newerVersion(2)) }
    }

    func testSizeLimit() throws {
        let data = try BackupCodec.encode([Fixture.plan()])
        XCTAssertThrowsError(try BackupCodec.decode(data, maxBytes: 100)) { XCTAssertEqual($0 as? BackupError, .tooLarge) }
        XCTAssertNoThrow(try BackupCodec.decode(data, maxBytes: data.count))
    }

    func testInvalidContentIsRejectedAsAWhole() throws {
        var bad = Fixture.plan(name: "Kaputt")
        bad.members[0].weight = 0
        let data = try BackupCodec.encode([Fixture.plan(name: "Gut"), bad])
        XCTAssertThrowsError(try BackupCodec.decode(data)) { error in
            guard case .invalidContent(let reason)? = error as? BackupError else { return XCTFail("wrong error \(error)") }
            XCTAssertTrue(reason.contains("Kaputt"))
        }
    }

    func testDuplicatePlanIDsAndTooManyPlans() throws {
        let plan = Fixture.plan()
        XCTAssertThrowsError(try BackupCodec.decode(try BackupCodec.encode([plan, plan]))) {
            XCTAssertEqual(($0 as? BackupError).map { "\($0)" }?.hasPrefix("invalidContent"), true)
        }
        let many = (0...PlanLimits.maxPlans).map { _ in
            Plan(name: "P", rhythm: .daily, startDate: Fixture.start, endDate: Fixture.start.adding(days: 1), members: [Member(name: "A")])
        }
        XCTAssertThrowsError(try BackupCodec.decode(try BackupCodec.encode(many))) {
            XCTAssertEqual(($0 as? BackupError).map { "\($0)" }?.hasPrefix("invalidContent"), true)
        }
    }

    func testTargetedTamperingIsCaught() throws {
        let json = String(decoding: try BackupCodec.encode([Fixture.plan()]), as: UTF8.self)
        let tampered: [(String, String)] = [
            ("\"slotSize\":1", "\"slotSize\":9"),
            ("\"weight\":1", "\"weight\":0"),
            ("\"weight\":1", "\"weight\":1e999"),
            ("\"year\":2026", "\"year\":99999999999")
        ]
        for (old, new) in tampered {
            XCTAssertTrue(json.contains(old), "fixture no longer contains \(old)")
            let data = Data(json.replacingOccurrences(of: old, with: new).utf8)
            XCTAssertThrowsError(try BackupCodec.decode(data), "should reject \(new)")
        }
    }

    /// Random damage to a valid file must never crash, and must never yield an invalid plan.
    func testFuzzedFilesNeverCrashAndNeverYieldInvalidPlans() throws {
        let original = try BackupCodec.encode([Fixture.plan(name: "Eins"), Fixture.plan(name: "Zwei", days: 14, members: ["X", "Y"])])
        var rng = SplitMix64(state: 20261002)
        var accepted = 0

        for _ in 0..<3000 {
            var bytes = [UInt8](original)
            for _ in 0..<Int.random(in: 1...3, using: &rng) {
                guard !bytes.isEmpty else { break }
                switch Int.random(in: 0..<6, using: &rng) {
                case 0: bytes[Int.random(in: 0..<bytes.count, using: &rng)] = UInt8.random(in: 0...255, using: &rng)
                case 1:
                    let start = Int.random(in: 0..<bytes.count, using: &rng)
                    let end = min(bytes.count, start + Int.random(in: 1...20, using: &rng))
                    bytes.removeSubrange(start..<end)
                case 2:
                    let at = Int.random(in: 0...bytes.count, using: &rng)
                    bytes.insert(contentsOf: (0..<Int.random(in: 1...8, using: &rng)).map { _ in UInt8.random(in: 0...255, using: &rng) }, at: at)
                case 3: bytes.removeSubrange(Int.random(in: 0..<bytes.count, using: &rng)...)
                case 4:
                    let digits = bytes.indices.filter { (48...57).contains(bytes[$0]) }
                    if let index = digits.randomElement(using: &rng) { bytes[index] = UInt8(48 + Int.random(in: 0...9, using: &rng)) }
                default:
                    let a = Int.random(in: 0..<bytes.count, using: &rng), b = Int.random(in: 0..<bytes.count, using: &rng)
                    bytes.swapAt(a, b)
                }
            }
            if let plans = try? BackupCodec.decode(Data(bytes)) {
                accepted += 1
                for plan in plans { XCTAssertNil(PlanValidator.problem(in: plan)) }
            }
        }
        // Harmless mutations (e.g. a changed digit in a name) are accepted; that is fine, but not all of them.
        XCTAssertLessThan(accepted, 3000)
    }
}
