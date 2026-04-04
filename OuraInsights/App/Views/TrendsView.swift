import SwiftUI

struct TrendsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("No trends yet")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Text("Trends will appear once data has been synced.")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
            }
            .navigationTitle("Trends")
        }
    }
}

#Preview {
    TrendsView()
}
