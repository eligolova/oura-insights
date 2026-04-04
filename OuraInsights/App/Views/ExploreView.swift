import SwiftUI

struct ExploreView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("Nothing to explore yet")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Text("Correlation and scatter plots will appear here after data is synced.")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
            }
            .navigationTitle("Explore")
        }
    }
}

#Preview {
    ExploreView()
}
