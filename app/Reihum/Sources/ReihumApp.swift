import SwiftUI

@main
struct ReihumApp: App {
    @State private var store = PlanStore()

    var body: some Scene {
        WindowGroup {
            PlanListView()
                .environment(store)
        }
    }
}
