import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "heart.text.square")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("No data yet")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Text("Connect your Oura Ring in Settings to get started.")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
            }
            .navigationTitle("Dashboard")
        }
    }
}

#Preview {
    DashboardView()
}
