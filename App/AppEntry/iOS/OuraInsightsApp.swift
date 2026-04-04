import SwiftUI

@main
struct OuraInsightsIOSApp: App {
    private let appContainer = AppContainer.shared

    var body: some Scene {
        WindowGroup {
            RootAppView()
                .environment(appContainer)
                .modelContainer(appContainer.modelContainer)
        }
    }
}
