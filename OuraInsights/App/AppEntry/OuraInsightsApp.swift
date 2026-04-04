import SwiftUI
import SwiftData

@main
struct OuraInsightsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(PersistenceController.shared.container)
    }
}
