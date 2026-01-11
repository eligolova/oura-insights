import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SleepSession.date, order: .reverse) private var sleepSessions: [SleepSession]
    @Query(sort: \ReadinessScore.date, order: .reverse) private var readinessScores: [ReadinessScore]
    @Query(sort: \ActivityDay.date, order: .reverse) private var activityDays: [ActivityDay]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    todaySummarySection
                    lastNightSleepSection
                    readinessSection
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
    }
    
    private var todaySummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Summary")
                .font(.headline)
            
            if let latestReadiness = readinessScores.first,
               let score = latestReadiness.score {
                SummaryCard(
                    title: "Readiness",
                    value: "\(score)",
                    subtitle: "Ready to take on the day",
                    color: scoreColor(score)
                )
            } else {
                EmptyStateCard(message: "No readiness data available")
            }
        }
    }
    
    private var lastNightSleepSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last Night's Sleep")
                .font(.headline)
            
            if let latestSleep = sleepSessions.first {
                HStack(spacing: 16) {
                    if let score = latestSleep.sleepScore {
                        MetricCard(
                            title: "Score",
                            value: "\(score)",
                            color: scoreColor(score)
                        )
                    }
                    
                    if let duration = latestSleep.totalSleepDuration {
                        MetricCard(
                            title: "Duration",
                            value: formatDuration(duration),
                            color: .blue
                        )
                    }
                    
                    if let efficiency = latestSleep.efficiency {
                        MetricCard(
                            title: "Efficiency",
                            value: "\(efficiency)%",
                            color: .purple
                        )
                    }
                }
            } else {
                EmptyStateCard(message: "No sleep data available")
            }
        }
    }
    
    private var readinessSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity")
                .font(.headline)
            
            if let latestActivity = activityDays.first {
                HStack(spacing: 16) {
                    if let steps = latestActivity.steps {
                        MetricCard(
                            title: "Steps",
                            value: formatNumber(steps),
                            color: .green
                        )
                    }
                    
                    if let calories = latestActivity.activeCalories {
                        MetricCard(
                            title: "Calories",
                            value: formatNumber(calories),
                            color: .orange
                        )
                    }
                }
            } else {
                EmptyStateCard(message: "No activity data available")
            }
        }
    }
    
    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 85...100: return .green
        case 70..<85: return .yellow
        case 50..<70: return .orange
        default: return .red
        }
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct EmptyStateCard: View {
    let message: String
    
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "tray")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 24)
            Spacer()
        }
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [SleepSession.self, ReadinessScore.self, ActivityDay.self])
}
