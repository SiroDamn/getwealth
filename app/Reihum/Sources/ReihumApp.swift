import SwiftUI
import ReihumCore

@main
struct ReihumApp: App {
    @State private var store: PlanStore

    init() {
        let store = PlanStore()
        // Reminders are local notifications for the organiser only, and only if switched on in the settings.
        store.onDidSave = { plans in
            if UserDefaults.standard.bool(forKey: "remindersEnabled") {
                ReminderManager.shared.reschedule(plans: plans)
            }
        }
        _store = State(initialValue: store)
    }

    var body: some Scene {
        WindowGroup {
            PlanListView()
                .environment(store)
        }
    }
}
