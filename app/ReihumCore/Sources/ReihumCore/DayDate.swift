import Foundation

/// Weekday numbering follows `Calendar`: 1 = Sunday … 7 = Saturday.
public enum Weekday: Int, Codable, CaseIterable, Hashable, Sendable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday

    public var isWeekend: Bool { self == .saturday || self == .sunday }
}

/// A calendar day without a time of day.
///
/// All arithmetic runs in a fixed Gregorian/UTC reference calendar so that
/// daylight-saving transitions and the device time zone can never shift a day.
public struct DayDate: Hashable, Codable, Comparable, Sendable, CustomStringConvertible {
    public var year: Int
    public var month: Int
    public var day: Int

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    /// Gregorian calendar pinned to UTC. Used for all date arithmetic.
    public static let referenceCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar
    }()

    /// The calendar day that `date` falls on in `calendar` (default: the user's current calendar).
    public init(_ date: Date, in calendar: Calendar = .current) {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        self.init(year: components.year ?? 1, month: components.month ?? 1, day: components.day ?? 1)
    }

    public static func today(in calendar: Calendar = .current, now: Date = Date()) -> DayDate {
        DayDate(now, in: calendar)
    }

    public static let distantPast = DayDate(year: 1, month: 1, day: 1)

    /// Noon UTC of this day in the reference calendar. Only for arithmetic and formatting in UTC.
    public var referenceDate: Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 12
        return DayDate.referenceCalendar.date(from: components) ?? Date(timeIntervalSince1970: 0)
    }

    /// Start of this day in the given calendar (for display and local notifications).
    public func startOfDay(in calendar: Calendar = .current) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return calendar.date(from: components) ?? referenceDate
    }

    /// True when the components describe an existing day (e.g. rejects 30 February).
    public var isValid: Bool {
        DayDate(referenceDate, in: DayDate.referenceCalendar) == self
    }

    public func adding(days: Int) -> DayDate {
        let shifted = DayDate.referenceCalendar.date(byAdding: .day, value: days, to: referenceDate) ?? referenceDate
        return DayDate(shifted, in: DayDate.referenceCalendar)
    }

    /// Number of days from this day to `other` (negative when `other` is earlier).
    public func days(until other: DayDate) -> Int {
        DayDate.referenceCalendar.dateComponents([.day], from: referenceDate, to: other.referenceDate).day ?? 0
    }

    public var weekday: Weekday {
        Weekday(rawValue: DayDate.referenceCalendar.component(.weekday, from: referenceDate)) ?? .monday
    }

    public var daysInMonth: Int {
        DayDate.referenceCalendar.range(of: .day, in: .month, for: referenceDate)?.count ?? 30
    }

    /// 1 for the first occurrence of this weekday in the month, 2 for the second, and so on.
    public var ordinalOfWeekdayInMonth: Int { (day - 1) / 7 + 1 }

    public var isLastOccurrenceOfWeekdayInMonth: Bool { day + 7 > daysInMonth }

    public var firstOfMonth: DayDate { DayDate(year: year, month: month, day: 1) }

    /// ISO 8601 date, e.g. 2026-10-02.
    public var iso: String { String(format: "%04d-%02d-%02d", year, month, day) }

    public var description: String { iso }

    public static func < (lhs: DayDate, rhs: DayDate) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }
}
