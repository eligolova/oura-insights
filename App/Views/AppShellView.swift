import SwiftUI

struct AppShellView: View {
    @Bindable var viewModel: AppShellViewModel

    var body: some View {
#if os(macOS)
        NavigationSplitView {
            List(viewModel.destinations, selection: $viewModel.selectedDestination) { destination in
                Label(destination.title, systemImage: destination.systemImage)
                    .tag(destination)
            }
            .navigationTitle("Oura Insights")
            .frame(minWidth: 220)
        } detail: {
            AppDestinationView(destination: viewModel.selectedDestination)
        }
#else
        TabView(selection: $viewModel.selectedDestination) {
            ForEach(viewModel.destinations) { destination in
                NavigationStack {
                    AppDestinationView(destination: destination)
                }
                .tabItem {
                    Label(destination.title, systemImage: destination.systemImage)
                }
                .tag(destination)
            }
        }
#endif
    }
}

#Preview {
    AppShellView(viewModel: AppShellViewModel())
}
