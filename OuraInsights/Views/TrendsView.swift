import SwiftUI
import SwiftData
import Charts

struct TrendsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SleepSession.date, order: .forward) private var sleepSessions: [SleepSession]
    @Query(sort: \ReadinessScore.date, order: .forward) private var readinessScores: [ReadinessScore]
    @Query(sort: \HeartMetrics.date, order: .forward) private var heartMetrics: [HeartMetrics]
    
    @State private var selectedPeriod: TrendPeriod = .week
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    periodPicker
                    sleepTrendChart
                    readinessTrendChart
                    hrvTrendChart
                }
                .padding()
            }
            .navigationTitle("Trends")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
    }
    
    private var periodPicker: some View {
        Picker("Period", selection: $selectedPeriod) {
            ForEach(TrendPeriod.allCases) { period in
                Text(period.title).tag(period)
            }
        }
        .pickerStyle(.segmented)
    }
    
    private var sleepTrendChart: some View {
        TrendChartCard(title: "Sleep Duration") {
            if filteredSleepSessions.isEmpty {
                emptyChartPlaceholder
            } else {
                Chart(filteredSleepSessions) { session in
                    if let duration = session.totalSleepDuration {
                        BarMark(
                            x: .value("Date", session.date, unit: .day),
                            y: .value("Hours", Double(duration) / 3600.0)
                        )
                        .foregroundStyle(.blue.gradient)
                    }
                }
                .chartYAxisLabel("Hours")
                .frame(height: 200)
            }
        }
    }
    
    private var readinessTrendChart: some View {
        TrendChartCard(title: "Readiness Score") {
            if filteredReadinessScores.isEmpty {
                emptyChartPlaceholder
            } else {
                Chart(filteredReadinessScores) { score in
                    if let value = score.score {
                        LineMark(
                            x: .value("Date", score.date, unit: .day),
                            y: .value("Score", value)
                        )
                        .foregroundStyle(.green.gradient)
                        .symbol(Circle())
                    }
                }
                .chartYScale(domain: 0...100)
                .chartYAxisLabel("Score")
                .frame(height: 200)
            }
        }
    }
    
    private var hrvTrendChart: some View {
        TrendChartCard(title: "HRV") {
            if filteredHeartMetrics.isEmpty {
                emptyChartPlaceholder
            } else {
                Chart(filteredHeartMetrics) { metrics in
                    if let hrv = metrics.averageHRV {
                        LineMark(
                            x: .value("Date", metrics.date, unit: .day),
                            y: .value("HRV", hrv)
                        )
                        .foregroundStyle(.purple.gradient)
                        .symbol(Circle())
                    }
                }
                .chartYAxisLabel("ms")
                .frame(height: 200)
            }
        }
    }
    
    private var emptyChartPlaceholder: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No data available")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
    
    private var startDate: Date {
        Calendar.current.date(byAdding: selectedPeriod.dateComponent, to: Date()) ?? Date()
    }
    
    private var filteredSleepSessions: [SleepSession] {
        sleepSessions.filter { $0.date >= startDate }
    }
    
    private var filteredReadinessScores: [ReadinessScore] {
        readinessScores.filter { $0.date >= startDate }
    }
    
    private var filteredHeartMetrics: [HeartMetrics] {
        heartMetrics.filter { $0.date >= startDate }
    }
}

enum TrendPeriod: String, CaseIterable, Identifiable {
    case week
    case month
    case quarter
    case year
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .week: return "Week"
        case .month: return "Month"
        case .quarter: return "3 Months"
        case .year: return "Year"
        }
    }
    
    var dateComponent: DateComponents {
        switch self {
        case .week: return DateComponents(day: -7)
        case .month: return DateComponents(month: -1)
        case .quarter: return DateComponents(month: -3)
        case .year: return DateComponents(year: -1)
        }
    }
}

struct TrendChartCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    TrendsView()
        .modelContainer(for: [SleepSession.self, ReadinessScore.self, HeartMetrics.self])
}
