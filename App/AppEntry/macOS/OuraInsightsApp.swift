import SwiftUI

@MainActor
@main
struct OuraInsightsMacOSApp: App {
    private let appContainer = AppContainer.shared

    var body: some Scene {
        Window("Oura Insights", id: "main") {
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
                .frame(minWidth: 960, minHeight: 640)
        }
        .windowResizability(.contentSize)
    }
}
