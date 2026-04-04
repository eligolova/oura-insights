import SwiftUI

struct RootAppView: View {
    @Environment(AppContainer.self) private var appContainer

    var body: some View {
        AppShellView(viewModel: appContainer.appShellViewModel)
    }
}
