import XCTest
@testable import ReihumCore

final class ExportTests: XCTestCase {
    let start = DayDate(year: 2026, month: 10, day: 2)

    func makePlan() -> Plan {
        let members = [Member(name: "Anna"), Member(name: "Ben, Jr."), Member(name: "Cara")]
        let plan = Plan(name: "Znüni; Kaffee, Tee", rhythm: .weekly(.friday), startDate: start, endDate: start.adding(days: 27), members: members)
        return FairnessEngine.regenerate(plan, today: start)
    }

    func testICSStructureAndCounts() {
        let plan = makePlan()
        let ics = ICSExporter.export(plan, now: Date(timeIntervalSince1970: 1_790_000_000))
        XCTAssertTrue(ics.hasPrefix("BEGIN:VCALENDAR\r\n"))
        XCTAssertTrue(ics.hasSuffix("END:VCALENDAR\r\n"))
        XCTAssertEqual(ics.components(separatedBy: "BEGIN:VEVENT").count - 1, 4)
        XCTAssertTrue(ics.contains("DTSTART;VALUE=DATE:20261002\r\n"))
        XCTAssertTrue(ics.contains("DTEND;VALUE=DATE:20261003\r\n"))
        XCTAssertTrue(ics.contains("PRODID:-//Reihum//Turnusplan//DE"))
        XCTAssertFalse(ics.contains("\n\n"))
        for line in ics.components(separatedBy: "\r\n") {
            XCTAssertLessThanOrEqual(line.utf8.count, 75, "line too long: \(line)")
        }
    }

    func testEscaping() {
        XCTAssertEqual(ICSExporter.escape("a,b;c\\d\ne"), "a\\,b\;c\\\\d\\ne")
        let ics = ICSExporter.export(makePlan())
        XCTAssertTrue(ics.contains("X-WR-CALNAME:Znüni\; Kaffee\\, Tee"))
    }

    func testUIDIsStableAcrossExports() {
        let plan = makePlan()
        let first = ICSExporter.export(plan, now: Date())
        let second = ICSExporter.export(plan, now: Date().addingTimeInterval(3600))
        func uids(_ text: String) -> [String] {
            text.components(separatedBy: "\r\n").filter { $0.hasPrefix("UID:") }
        }
        XCTAssertEqual(uids(first), uids(second))
        XCTAssertEqual(Set(uids(first)).count, 4)
    }

    func testPerMemberFilter() {
        let plan = makePlan()
        let anna = plan.members[0].id
        let ics = ICSExporter.export(plan, options: ICSExporter.Options(memberID: anna))
        let expected = plan.slots.filter { $0.assignedMemberIDs.contains(anna) }.count
        XCTAssertEqual(ics.components(separatedBy: "BEGIN:VEVENT").count - 1, expected)
        XCTAssertGreaterThan(expected, 0)
    }

    func testLongLinesAreFoldedAndUnfoldable() {
        var plan = makePlan()
        plan.name = String(repeating: "Sehr langer Planname ", count: 8)
        let ics = ICSExporter.export(plan)
        for line in ics.components(separatedBy: "\r\n") {
            XCTAssertLessThanOrEqual(line.utf8.count, 75)
        }
        let unfolded = ics.replacingOccurrences(of: "\r\n ", with: "")
        XCTAssertTrue(unfolded.contains("X-WR-CALNAME:\(ICSExporter.escape(plan.name))"))
    }

    func testFoldNeverSplitsMultiByteCharacters() {
        let line = "SUMMARY:" + String(repeating: "ü", count: 120)
        let folded = ICSExporter.fold(line)
        for physical in folded.components(separatedBy: "\r\n") {
            XCTAssertLessThanOrEqual(physical.utf8.count, 75)
            XCTAssertNotNil(String(data: Data(physical.utf8), encoding: .utf8))
        }
        XCTAssertEqual(folded.replacingOccurrences(of: "\r\n ", with: ""), line)
    }

    func testTextExport() {
        var plan = makePlan()
        var open = plan.sortedSlots[1]
        open.assignedMemberIDs = []
        plan = FairnessEngine.applyManualEdit(open, in: plan)
        let text = TextExporter.export(plan)
        XCTAssertTrue(text.hasPrefix(plan.name + "\n\n"))
        XCTAssertTrue(text.contains("02.10.2026"))
        XCTAssertTrue(text.contains(" – offen"))
        XCTAssertEqual(text.components(separatedBy: "\n").count, 6)

        let anna = plan.members[0].id
        let filtered = TextExporter.export(plan, memberID: anna)
        XCTAssertFalse(filtered.contains("offen"))
    }

    func testPlanCodableRoundTrip() throws {
        let plan = makePlan()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let data = try encoder.encode(plan)
        let decoded = try decoder.decode(Plan.self, from: data)
        XCTAssertEqual(decoded.id, plan.id)
        XCTAssertEqual(decoded.slots.map { $0.assignedMemberIDs }, plan.slots.map { $0.assignedMemberIDs })
        XCTAssertEqual(decoded.rhythm, plan.rhythm)
    }
}
