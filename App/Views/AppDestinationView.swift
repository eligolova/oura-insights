import SwiftData
import SwiftUI

struct AppDestinationView: View {
    let destination: AppDestination

    var body: some View {
        switch destination {
        case .dashboard:
            DashboardView()
        case .trends:
            TrendsView()
        case .explore:
            ExploreView()
        case .settings:
            SettingsView()
        }
    }
}

struct DashboardView: View {
    @Query(sort: \SleepSession.startDate, order: .reverse) private var sleepSessions: [SleepSession]
    @Query(sort: \ReadinessScore.date, order: .reverse) private var readinessScores: [ReadinessScore]

    var body: some View {
        AppScreen(
            title: "Today",
            subtitle: "Your daily summary will surface sleep, readiness, and recent sync health here.",
            sections: [
                AppScreenSection(
                    title: "Phase 0 status",
                    body: "SwiftData is active and ready for local-first ingestion. The dashboard is intentionally seeded with empty-state scaffolding for the next phases."
                ),
                AppScreenSection(
                    title: "Current data",
                    body: "Sleep sessions: \(sleepSessions.count)\nReadiness entries: \(readinessScores.count)"
                )
            ]
        )
    }
}

struct TrendsView: View {
    var body: some View {
        AppScreen(
            title: "Trends",
            subtitle: "Trend charts will visualize long-term changes across sleep, HRV, readiness, and other imported signals.",
            sections: [
                AppScreenSection(
                    title: "Planned charts",
                    body: "Sleep duration vs time\nHRV vs time\nReadiness vs time"
                ),
                AppScreenSection(
                    title: "Phase 0 shell",
                    body: "The chart screen is part of the navigation flow now so Phase 3 can focus on metrics instead of navigation scaffolding."
                )
            ]
        )
    }
}

struct ExploreView: View {
    var body: some View {
        AppScreen(
            title: "Explore",
            subtitle: "Correlation views will help compare Oura metrics with contextual signals like weather and travel variance.",
            sections: [
                AppScreenSection(
                    title: "Planned exploration",
                    body: "Sleep vs temperature\nHRV vs location variance"
                ),
                AppScreenSection(
                    title: "Phase 0 shell",
                    body: "This placeholder keeps the information architecture stable while the import and analysis layers are still being built."
                )
            ]
        )
    }
}

struct SettingsView: View {
    var body: some View {
        AppScreen(
            title: "Settings",
            subtitle: "Privacy-first controls, Oura authentication, and manual sync actions will live here.",
            sections: [
                AppScreenSection(
                    title: "Coming next",
                    body: "Oura login\nLocation permissions\nFace ID / Touch ID toggle\nManual refresh"
                ),
                AppScreenSection(
                    title: "Storage",
                    body: "All app data is configured for on-device storage with SwiftData, ready for local persistence in later phases."
                )
            ]
        )
    }
}
