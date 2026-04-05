import SwiftUI

@MainActor
@main
struct OuraInsightsIOSApp: App {
    private let appContainer = AppContainer.shared

    var body: some Scene {
        WindowGroup {
            RootAppView()
                .environment(appContainer)
                .modelContainer(appContainer.modelContainer)
                .task {
                    await appContainer.ouraSessionViewModel.bootstrap()
                }
                .onOpenURL { url in
                    Task {
                        await appContainer.ouraSessionViewModel.handleIncomingURL(url)
                    }
                }
        }
    }
}
