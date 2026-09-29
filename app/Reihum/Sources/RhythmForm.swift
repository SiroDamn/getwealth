import SwiftUI
import ReihumCore

/// Editable representation of a rhythm, shared by the creation flow and the plan editor.
struct RhythmDraft: Equatable {
    enum Kind: String, CaseIterable, Identifiable {
        case daily, weekdays, weekly, biweekly, monthlyNthWeekday, monthlyDay
        var id: String { rawValue }
        var label: String {
            switch self {
            case .daily: return "Täglich"
            case .weekdays: return "Jeden Werktag"
            case .weekly: return "Wöchentlich"
            case .biweekly: return "Alle zwei Wochen"
            case .monthlyNthWeekday: return "Monatlich (Wochentag)"
            case .monthlyDay: return "Monatlich (Datum)"
            }
        }
    }

    var kind: Kind = .weekly
    var weekday: Weekday = .friday
    var ordinal: Int = 1
    var monthDay: Int = 1

    init() {}

    init(_ rhythm: Rhythm) {
        switch rhythm {
        case .daily: kind = .daily
        case .weekdays: kind = .weekdays
        case .weekly(let weekday): kind = .weekly; self.weekday = weekday
        case .biweekly(let weekday): kind = .biweekly; self.weekday = weekday
        case .monthlyNthWeekday(let ordinal, let weekday): kind = .monthlyNthWeekday; self.ordinal = ordinal; self.weekday = weekday
        case .monthlyDay(let day): kind = .monthlyDay; monthDay = day
        }
    }

    var rhythm: Rhythm {
        switch kind {
        case .daily: return .daily
        case .weekdays: return .weekdays
        case .weekly: return .weekly(weekday)
        case .biweekly: return .biweekly(weekday)
        case .monthlyNthWeekday: return .monthlyNthWeekday(ordinal: ordinal, weekday: weekday)
        case .monthlyDay: return .monthlyDay(monthDay)
        }
    }
}

struct RhythmForm: View {
    @Binding var draft: RhythmDraft
    @Binding var slotSize: Int

    var body: some View {
        Picker("Rhythmus", selection: $draft.kind) {
            ForEach(RhythmDraft.Kind.allCases) { kind in Text(kind.label).tag(kind) }
        }
        if draft.kind == .weekly || draft.kind == .biweekly || draft.kind == .monthlyNthWeekday {
            Picker("Wochentag", selection: $draft.weekday) {
                ForEach(Weekday.orderedForPicker, id: \.self) { Text($0.germanName).tag($0) }
            }
        }
        if draft.kind == .monthlyNthWeekday {
            Picker("Welcher", selection: $draft.ordinal) {
                Text("Erster").tag(1)
                Text("Zweiter").tag(2)
                Text("Dritter").tag(3)
                Text("Vierter").tag(4)
                Text("Letzter").tag(-1)
            }
        }
        if draft.kind == .monthlyDay {
            Stepper("Tag des Monats: \(draft.monthDay)", value: $draft.monthDay, in: 1...31)
            Text("In kürzeren Monaten wird der letzte Tag verwendet.")
                .font(.footnote).foregroundStyle(.secondary)
        }
        Stepper("Personen pro Termin: \(slotSize)", value: $slotSize, in: 1...2)
    }
}
