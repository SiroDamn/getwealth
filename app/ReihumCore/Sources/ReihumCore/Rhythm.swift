import Foundation

/// How often a plan has a turn.
public enum Rhythm: Codable, Hashable, Sendable {
    /// Every calendar day.
    case daily
    /// Monday to Friday.
    case weekdays
    /// Once a week on the given weekday.
    case weekly(Weekday)
    /// Every second week on the given weekday, anchored at the first occurrence on or after the start date.
    case biweekly(Weekday)
    /// The n-th occurrence of a weekday in each month (`ordinal` 1…4), or the last occurrence (`ordinal` -1).
    case monthlyNthWeekday(ordinal: Int, weekday: Weekday)
    /// A fixed day of the month (1…31); clamped to the last day of shorter months.
    case monthlyDay(Int)
}
