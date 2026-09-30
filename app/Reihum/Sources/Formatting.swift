import SwiftUI
import ReihumCore

enum Fmt {
    static let locale = Locale(identifier: "de_CH")

    private static func formatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = format
        return formatter
    }

    static let shortDay = formatter("EE, d. MMM")
    static let longDay = formatter("EEEE, d. MMMM yyyy")
    static let numericDay = formatter("dd.MM.yyyy")
    static let monthTitle = formatter("LLLL yyyy")

    static func short(_ day: DayDate) -> String { shortDay.string(from: day.referenceDate) }
    static func long(_ day: DayDate) -> String { longDay.string(from: day.referenceDate) }
    static func numeric(_ day: DayDate) -> String { numericDay.string(from: day.referenceDate) }
    static func month(_ day: DayDate) -> String { monthTitle.string(from: day.referenceDate) }

    static func weight(_ value: Double) -> String {
        value == 1 ? "1" : (value == 0.5 ? "½" : "\(value)")
    }
}

extension Weekday {
    var germanName: String {
        switch self {
        case .monday: return "Montag"
        case .tuesday: return "Dienstag"
        case .wednesday: return "Mittwoch"
        case .thursday: return "Donnerstag"
        case .friday: return "Freitag"
        case .saturday: return "Samstag"
        case .sunday: return "Sonntag"
        }
    }

    /// Monday first, as is customary in Switzerland.
    static let orderedForPicker: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
}

extension Rhythm {
    var label: String {
        switch self {
        case .daily: return "Täglich"
        case .weekdays: return "Jeden Werktag"
        case .weekly(let weekday): return "Jeden \(weekday.germanName)"
        case .biweekly(let weekday): return "Alle zwei Wochen am \(weekday.germanName)"
        case .monthlyNthWeekday(let ordinal, let weekday):
            let ordinalText = ordinal == -1 ? "letzten" : "\(ordinal)."
            return "Monatlich am \(ordinalText) \(weekday.germanName)"
        case .monthlyDay(let day): return "Monatlich am \(day)."
        }
    }
}

enum Palette {
    static let colors: [Color] = [.teal, .orange, .indigo, .pink, .green, .purple, .brown, .cyan, .mint, .red]
    static func color(_ index: Int) -> Color { colors[abs(index) % colors.count] }
}

enum Symbols {
    static let choices = ["person.2", "cup.and.saucer", "sparkles", "car", "birthday.cake", "leaf", "trash", "tshirt", "house", "sportscourt", "fork.knife", "star"]
}

struct AvatarView: View {
    let member: Member
    var size: CGFloat = 28

    var body: some View {
        Text(member.initials)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(Palette.color(member.colorIndex), in: Circle())
            .accessibilityHidden(true)
    }
}
