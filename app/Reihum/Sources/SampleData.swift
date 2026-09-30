import Foundation
import ReihumCore

enum SampleData {
    /// Fictional first names only; no relation to real persons.
    static func plan() -> Plan {
        let names = ["Alex", "Bea", "Chris", "Dana", "Eli"]
        let members = names.enumerated().map { Member(name: $0.element, colorIndex: $0.offset) }
        var start = DayDate.today()
        while start.weekday != .friday { start = start.adding(days: 1) }
        return Plan(
            name: "Beispiel: Znüni-Dienst",
            symbolName: "cup.and.saucer",
            colorIndex: 1,
            rhythm: .weekly(.friday),
            startDate: start,
            endDate: start.adding(days: 12 * 7 - 1),
            members: members
        )
    }
}
