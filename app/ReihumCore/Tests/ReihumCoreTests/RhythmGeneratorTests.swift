import XCTest
@testable import ReihumCore

final class RhythmGeneratorTests: XCTestCase {
    let oct1 = DayDate(year: 2026, month: 10, day: 1)
    let dec31 = DayDate(year: 2026, month: 12, day: 31)

    func testWeeklyFriday() {
        let dates = RhythmGenerator.dates(for: .weekly(.friday), from: oct1, to: dec31)
        XCTAssertEqual(dates.count, 13)
        XCTAssertEqual(dates.first, DayDate(year: 2026, month: 10, day: 2))
        XCTAssertEqual(dates.last, DayDate(year: 2026, month: 12, day: 25))
        XCTAssertTrue(dates.allSatisfy { $0.weekday == .friday })
    }

    func testWeekdaysSkipWeekend() {
        let dates = RhythmGenerator.dates(for: .weekdays, from: DayDate(year: 2026, month: 10, day: 5), to: DayDate(year: 2026, month: 10, day: 11))
        XCTAssertEqual(dates.count, 5)
        XCTAssertFalse(dates.contains { $0.weekday.isWeekend })
    }

    func testDaily() {
        let dates = RhythmGenerator.dates(for: .daily, from: oct1, to: oct1.adding(days: 9))
        XCTAssertEqual(dates.count, 10)
    }

    func testBiweeklyMondayAnchorsAtFirstOccurrence() {
        let dates = RhythmGenerator.dates(for: .biweekly(.monday), from: oct1, to: DayDate(year: 2026, month: 11, day: 30))
        let expected = [5, 19].map { DayDate(year: 2026, month: 10, day: $0) } + [2, 16, 30].map { DayDate(year: 2026, month: 11, day: $0) }
        XCTAssertEqual(dates, expected)
    }

    func testMonthlyFirstMonday() {
        let dates = RhythmGenerator.dates(for: .monthlyNthWeekday(ordinal: 1, weekday: .monday), from: oct1, to: dec31)
        XCTAssertEqual(dates, [DayDate(year: 2026, month: 10, day: 5), DayDate(year: 2026, month: 11, day: 2), DayDate(year: 2026, month: 12, day: 7)])
    }

    func testMonthlyLastFriday() {
        let dates = RhythmGenerator.dates(for: .monthlyNthWeekday(ordinal: -1, weekday: .friday), from: oct1, to: DayDate(year: 2026, month: 10, day: 31))
        XCTAssertEqual(dates, [DayDate(year: 2026, month: 10, day: 30)])
    }

    func testMonthlyDay31ClampsToShorterMonths() {
        let dates = RhythmGenerator.dates(for: .monthlyDay(31), from: DayDate(year: 2028, month: 1, day: 1), to: DayDate(year: 2028, month: 4, day: 30))
        XCTAssertEqual(dates, [
            DayDate(year: 2028, month: 1, day: 31),
            DayDate(year: 2028, month: 2, day: 29),
            DayDate(year: 2028, month: 3, day: 31),
            DayDate(year: 2028, month: 4, day: 30)
        ])
    }

    func testMonthlyDay15() {
        let dates = RhythmGenerator.dates(for: .monthlyDay(15), from: oct1, to: dec31)
        XCTAssertEqual(dates.map { $0.day }, [15, 15, 15])
    }

    func testStartAfterEndIsEmpty() {
        XCTAssertTrue(RhythmGenerator.dates(for: .daily, from: dec31, to: oct1).isEmpty)
    }

    func testDailyAcrossDSTHasNoGapsOrDuplicates() {
        let dates = RhythmGenerator.dates(for: .daily, from: DayDate(year: 2026, month: 3, day: 27), to: DayDate(year: 2026, month: 3, day: 31))
        XCTAssertEqual(dates.map { $0.day }, [27, 28, 29, 30, 31])
    }
}
