import XCTest
@testable import ReihumCore

final class DayDateTests: XCTestCase {
    func testAddingDaysAcrossSpringDSTTransition() {
        // Europe/Zurich switches to summer time on 2026-03-29.
        let day = DayDate(year: 2026, month: 3, day: 28)
        XCTAssertEqual(day.adding(days: 1), DayDate(year: 2026, month: 3, day: 29))
        XCTAssertEqual(day.adding(days: 2), DayDate(year: 2026, month: 3, day: 30))
        XCTAssertEqual(day.adding(days: 2).adding(days: -2), day)
    }

    func testRoundTripThroughLocalCalendarOnDSTDays() {
        var zurich = Calendar(identifier: .gregorian)
        zurich.timeZone = TimeZone(identifier: "Europe/Zurich")!
        for day in [DayDate(year: 2026, month: 3, day: 29), DayDate(year: 2026, month: 10, day: 25)] {
            let local = day.startOfDay(in: zurich)
            XCTAssertEqual(DayDate(local, in: zurich), day)
        }
    }

    func testLeapYearArithmetic() {
        XCTAssertEqual(DayDate(year: 2028, month: 2, day: 28).adding(days: 1), DayDate(year: 2028, month: 2, day: 29))
        XCTAssertEqual(DayDate(year: 2028, month: 2, day: 28).adding(days: 2), DayDate(year: 2028, month: 3, day: 1))
        XCTAssertEqual(DayDate(year: 2027, month: 2, day: 28).adding(days: 1), DayDate(year: 2027, month: 3, day: 1))
        XCTAssertEqual(DayDate(year: 2028, month: 2, day: 1).daysInMonth, 29)
        XCTAssertEqual(DayDate(year: 2027, month: 2, day: 1).daysInMonth, 28)
        XCTAssertEqual(DayDate(year: 2026, month: 4, day: 1).daysInMonth, 30)
    }

    func testWeekdays() {
        XCTAssertEqual(DayDate(year: 2026, month: 10, day: 1).weekday, .thursday)
        XCTAssertEqual(DayDate(year: 2026, month: 10, day: 2).weekday, .friday)
        XCTAssertEqual(DayDate(year: 2026, month: 10, day: 4).weekday, .sunday)
        XCTAssertTrue(DayDate(year: 2026, month: 10, day: 3).weekday.isWeekend)
    }

    func testOrdinals() {
        let day = DayDate(year: 2026, month: 10, day: 30) // last Friday of October 2026
        XCTAssertEqual(day.ordinalOfWeekdayInMonth, 5)
        XCTAssertTrue(day.isLastOccurrenceOfWeekdayInMonth)
        XCTAssertFalse(DayDate(year: 2026, month: 10, day: 23).isLastOccurrenceOfWeekdayInMonth)
    }

    func testComparisonAndDistance() {
        let a = DayDate(year: 2026, month: 12, day: 31)
        let b = DayDate(year: 2027, month: 1, day: 1)
        XCTAssertTrue(a < b)
        XCTAssertEqual(a.days(until: b), 1)
        XCTAssertEqual(b.days(until: a), -1)
    }

    func testValidity() {
        XCTAssertTrue(DayDate(year: 2028, month: 2, day: 29).isValid)
        XCTAssertFalse(DayDate(year: 2027, month: 2, day: 29).isValid)
        XCTAssertFalse(DayDate(year: 2026, month: 4, day: 31).isValid)
    }

    func testCodableRoundTrip() throws {
        let day = DayDate(year: 2026, month: 10, day: 2)
        let data = try JSONEncoder().encode(day)
        XCTAssertEqual(try JSONDecoder().decode(DayDate.self, from: data), day)
        XCTAssertEqual(day.iso, "2026-10-02")
    }
}
