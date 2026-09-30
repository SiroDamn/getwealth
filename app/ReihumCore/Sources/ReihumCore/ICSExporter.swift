import Foundation

/// Exports a plan as an iCalendar file (RFC 5545) with one all-day event per turn.
public enum ICSExporter {
    public struct Options: Sendable {
        /// Only the turns of this member. `nil` exports every turn.
        public var memberID: UUID?
        public var includeAlarm: Bool
        /// Relative trigger; -PT6H fires at 18:00 on the day before an all-day event.
        public var alarmTrigger: String
        public var includeOpenSlots: Bool
        /// When set, turns before this day are left out.
        public var from: DayDate?
        public var productID: String
        public var uidSuffix: String

        public init(memberID: UUID? = nil, includeAlarm: Bool = true, alarmTrigger: String = "-PT6H", includeOpenSlots: Bool = true, from: DayDate? = nil, productID: String = "-//Reihum//Turnusplan//DE", uidSuffix: String = "reihum") {
            self.memberID = memberID
            self.includeAlarm = includeAlarm
            self.alarmTrigger = alarmTrigger
            self.includeOpenSlots = includeOpenSlots
            self.from = from
            self.productID = productID
            self.uidSuffix = uidSuffix
        }
    }

    public static func export(_ plan: Plan, options: Options = Options(), now: Date = Date()) -> String {
        var lines: [String] = [
            "BEGIN:VCALENDAR",
            "VERSION:2.0",
            "PRODID:\(options.productID)",
            "CALSCALE:GREGORIAN",
            "METHOD:PUBLISH",
            "X-WR-CALNAME:\(escape(plan.name))"
        ]
        let stamp = timestamp(now)

        for slot in plan.sortedSlots where !slot.isSkipped {
            if let from = options.from, slot.date < from { continue }
            if let memberID = options.memberID {
                guard slot.assignedMemberIDs.contains(memberID) else { continue }
            } else if slot.isOpen && !options.includeOpenSlots {
                continue
            }
            let names = plan.names(for: slot)
            let summary = names.isEmpty ? "\(plan.name): offen" : "\(plan.name): \(names.joined(separator: ", "))"

            lines.append("BEGIN:VEVENT")
            lines.append("UID:\(uid(plan: plan, slot: slot, suffix: options.uidSuffix))")
            lines.append("DTSTAMP:\(stamp)")
            lines.append("DTSTART;VALUE=DATE:\(compact(slot.date))")
            lines.append("DTEND;VALUE=DATE:\(compact(slot.date.adding(days: 1)))")
            lines.append("SUMMARY:\(escape(summary))")
            if let note = slot.note, !note.isEmpty {
                lines.append("DESCRIPTION:\(escape(note))")
            }
            lines.append("SEQUENCE:\(slot.sequence)")
            lines.append("TRANSP:TRANSPARENT")
            if options.includeAlarm {
                lines.append("BEGIN:VALARM")
                lines.append("TRIGGER:\(options.alarmTrigger)")
                lines.append("ACTION:DISPLAY")
                lines.append("DESCRIPTION:\(escape(summary))")
                lines.append("END:VALARM")
            }
            lines.append("END:VEVENT")
        }
        lines.append("END:VCALENDAR")
        return lines.map(fold).joined(separator: "\r\n") + "\r\n"
    }

    /// Stable per plan and date, so a re-import updates the existing event instead of duplicating it.
    public static func uid(plan: Plan, slot: Slot, suffix: String = "reihum") -> String {
        "\(plan.id.uuidString.lowercased())-\(slot.date.iso)@\(suffix)"
    }

    static func escape(_ text: String) -> String {
        text.replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: ";", with: "\\;")
            .replacingOccurrences(of: ",", with: "\\,")
            .replacingOccurrences(of: "\r\n", with: "\\n")
            .replacingOccurrences(of: "\n", with: "\\n")
    }

    static func compact(_ day: DayDate) -> String {
        String(format: "%04d%02d%02d", day.year, day.month, day.day)
    }

    static func timestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        return formatter.string(from: date)
    }

    /// RFC 5545 §3.1 line folding: at most 75 octets per physical line, continuation lines start
    /// with a single space, and a multi-byte UTF-8 character is never split.
    static func fold(_ line: String) -> String {
        var physicalLines: [String] = []
        var current = ""
        var currentOctets = 0
        for character in line {
            let octets = character.utf8.count
            let limit = physicalLines.isEmpty ? 75 : 74
            if currentOctets + octets > limit {
                physicalLines.append(current)
                current = ""
                currentOctets = 0
            }
            current.append(character)
            currentOctets += octets
        }
        physicalLines.append(current)
        return physicalLines.joined(separator: "\r\n ")
    }
}
