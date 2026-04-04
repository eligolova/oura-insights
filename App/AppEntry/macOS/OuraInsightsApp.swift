import SwiftUI

@main
struct OuraInsightsMacOSApp: App {
    private let appContainer = AppContainer.shared

    var body: some Scene {
        WindowGroup {
            RootAppView()
                .environment(appContainer)
                .modelContainer(appContainer.modelContainer)
                .frame(minWidth: 960, minHeight: 640)
        }
        .windowResizability(.contentSize)
    }
}
