import Foundation

/// Plain-text list for chats, e.g. "Fr., 02.10.2026 – Anna".
public enum TextExporter {
    public static func export(_ plan: Plan, memberID: UUID? = nil, locale: Locale = Locale(identifier: "de_CH")) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "EE, dd.MM.yyyy"

        var lines: [String] = [plan.name, ""]
        for slot in plan.sortedSlots where !slot.isSkipped {
            if let memberID, !slot.assignedMemberIDs.contains(memberID) { continue }
            let names = plan.names(for: slot)
            let who = names.isEmpty ? "offen" : names.joined(separator: " & ")
            lines.append("\(formatter.string(from: slot.date.referenceDate)) – \(who)")
        }
        return lines.joined(separator: "\n")
    }
}
