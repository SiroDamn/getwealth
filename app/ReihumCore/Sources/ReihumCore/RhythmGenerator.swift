import Foundation

public enum RhythmGenerator {
    /// Upper bound for a single plan (about ten years) to keep generation cheap and predictable.
    public static let maximumSpanDays = 3660

    /// All turn dates of `rhythm` between `start` and `end` (both inclusive), ascending.
    public static func dates(for rhythm: Rhythm, from start: DayDate, to end: DayDate) -> [DayDate] {
        guard start <= end else { return [] }
        let span = min(start.days(until: end), maximumSpanDays)
        var result: [DayDate] = []
        var biweeklyAnchor: DayDate?
        var current = start

        for _ in 0...span {
            switch rhythm {
            case .daily:
                result.append(current)

            case .weekdays:
                if !current.weekday.isWeekend { result.append(current) }

            case .weekly(let weekday):
                if current.weekday == weekday { result.append(current) }

            case .biweekly(let weekday):
                if current.weekday == weekday {
                    if let anchor = biweeklyAnchor {
                        if anchor.days(until: current) % 14 == 0 { result.append(current) }
                    } else {
                        biweeklyAnchor = current
                        result.append(current)
                    }
                }

            case .monthlyNthWeekday(let ordinal, let weekday):
                if current.weekday == weekday {
                    if ordinal == -1 {
                        if current.isLastOccurrenceOfWeekdayInMonth { result.append(current) }
                    } else if current.ordinalOfWeekdayInMonth == ordinal {
                        result.append(current)
                    }
                }

            case .monthlyDay(let day):
                let target = min(max(day, 1), current.daysInMonth)
                if current.day == target { result.append(current) }
            }
            current = current.adding(days: 1)
        }
        return result
    }
}
