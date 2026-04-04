import SwiftUI

struct TrendChartPlaceholder: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(.quaternary)
            .overlay {
                VStack(spacing: 10) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title2)
                    Text("Charts arrive in Phase 3")
                        .font(.headline)
                }
                .foregroundStyle(.secondary)
            }
            .frame(height: 220)
    }
}
