import Foundation
import UserNotifications
import ReihumCore

/// Local notifications for the organiser only. Nothing is sent to anyone else.
final class ReminderManager {
    static let shared = ReminderManager()
    private let center = UNUserNotificationCenter.current()
    /// iOS keeps at most 64 pending requests per app; leave headroom.
    private let maximumPending = 60
    private let perPlanLimit = 8

    func setEnabled(_ enabled: Bool, plans: [Plan], completion: @escaping (Bool) -> Void) {
        guard enabled else {
            center.removeAllPendingNotificationRequests()
            completion(true)
            return
        }
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            DispatchQueue.main.async {
                if granted { self.reschedule(plans: plans) }
                completion(granted)
            }
        }
    }

    func reschedule(plans: [Plan]) {
        center.removeAllPendingNotificationRequests()
        let today = DayDate.today()
        var scheduled = 0
        for plan in plans {
            var perPlan = 0
            for slot in plan.sortedSlots where slot.date > today && !slot.isSkipped {
                guard scheduled < maximumPending, perPlan < perPlanLimit else { break }
                let names = plan.names(for: slot)
                let who = names.isEmpty ? "niemand (offen)" : names.joined(separator: " und ")
                let content = UNMutableNotificationContent()
                content.title = plan.name
                content.body = "Morgen: \(who) ist dran."
                content.sound = .default

                let dayBefore = slot.date.adding(days: -1)
                var components = DateComponents()
                components.year = dayBefore.year
                components.month = dayBefore.month
                components.day = dayBefore.day
                components.hour = 18
                components.minute = 0
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let request = UNNotificationRequest(identifier: "\(plan.id.uuidString)-\(slot.date.iso)", content: content, trigger: trigger)
                center.add(request)
                scheduled += 1
                perPlan += 1
            }
        }
    }
}
