import Foundation

/// Plain-text list for chats, e.g. "Fr., 02.10.2026 – Anna".
public enum TextExporter {
    /// - Parameter from: when set, turns before this day are left out (for sharing only what is still ahead).
    public static func export(_ plan: Plan, memberID: UUID? = nil, from: DayDate? = nil, locale: Locale = Locale(identifier: "de_CH")) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "EE, dd.MM.yyyy"

        var lines: [String] = [plan.name, ""]
        for slot in plan.sortedSlots where !slot.isSkipped {
            if let from, slot.date < from { continue }
            if let memberID, !slot.assignedMemberIDs.contains(memberID) { continue }
            let names = plan.names(for: slot)
            let who = names.isEmpty ? "offen" : names.joined(separator: " & ")
            lines.append("\(formatter.string(from: slot.date.referenceDate)) – \(who)")
        }
        return lines.joined(separator: "\n")
    }
}
