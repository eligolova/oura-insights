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
    @Environment(AppContainer.self) private var appContainer
    @Query(sort: \SleepSession.startDate, order: .reverse) private var sleepSessions: [SleepSession]
    @Query(sort: \ReadinessScore.date, order: .reverse) private var readinessScores: [ReadinessScore]
    @Query private var rawSleepRecords: [RawOuraSleepRecord]
    @Query private var rawReadinessRecords: [RawOuraReadinessRecord]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today")
                        .font(.largeTitle.weight(.semibold))
                    Text("Your daily summary now reflects live Oura connection state and the first imported sleep and readiness datasets.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                AppCard(title: "Oura status", message: appContainer.ouraSessionViewModel.connectionSummary)
                AppCard(title: "Sync status", message: appContainer.ouraSessionViewModel.syncSummary)
                AppCard(title: "Latest sleep", message: appContainer.ouraSessionViewModel.latestSleepSummary)
                AppCard(title: "Latest readiness", message: appContainer.ouraSessionViewModel.latestReadinessSummary)
                AppCard(
                    title: "Stored records",
                    message: "Raw sleep records: \(rawSleepRecords.count)\nRaw readiness records: \(rawReadinessRecords.count)\nNormalised sleep sessions: \(sleepSessions.count)\nNormalised readiness entries: \(readinessScores.count)"
                )
            }
            .padding(24)
            .frame(maxWidth: 900, alignment: .leading)
        }
        .navigationTitle("Today")
    }
}

struct TrendsView: View {
    var body: some View {
        AppScreen(
            title: "Trends",
            subtitle: "Trend charts will visualise long-term changes across sleep, HRV, readiness, and other imported signals.",
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
    @Environment(AppContainer.self) private var appContainer

    var body: some View {
        OuraSettingsView(viewModel: appContainer.ouraSessionViewModel)
    }
}

struct OuraSettingsView: View {
    @Bindable var viewModel: OuraSessionViewModel
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Settings")
                        .font(.largeTitle.weight(.semibold))
                    Text("Configure Oura sign-in, keep tokens on-device in the keychain, and run a manual sync when you need fresh sleep and readiness data.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Oura client ID")
                        .font(.headline)
                    TextField("Enter your Oura developer client ID", text: $viewModel.clientID)
                        .textFieldStyle(.roundedBorder)
                    SecureField("Enter your Oura developer client secret", text: $viewModel.clientSecret)
                        .textFieldStyle(.roundedBorder)
                    Text("Redirect URI: \(viewModel.redirectURI.absoluteString)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text("Requested scopes: \(viewModel.scopeSummary)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                VStack(alignment: .leading, spacing: 12) {
                    Text("Connection")
                        .font(.headline)
                    Text(viewModel.connectionSummary)
                        .foregroundStyle(.secondary)
                    HStack {
                        Button(viewModel.isAuthorising ? "Waiting for Oura…" : "Connect Oura") {
                            do {
                                let authorisationURL = try viewModel.makeAuthorisationURL()
                                openURL(authorisationURL)
                            } catch {
                                viewModel.lastErrorMessage = error.localizedDescription
                            }
                        }
                        .disabled(
                            viewModel.isAuthorising ||
                                viewModel.clientID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                                viewModel.clientSecret.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        )

                        Button(viewModel.isSyncing ? "Syncing…" : "Sync now") {
                            Task {
                                await viewModel.refresh()
                            }
                        }
                        .disabled(viewModel.isSyncing || viewModel.isConnected == false)

                        Button("Disconnect") {
                            viewModel.disconnect()
                        }
                        .disabled(viewModel.isConnected == false && viewModel.isAuthorising == false)
                    }
                    Text(viewModel.syncSummary)
                        .foregroundStyle(.secondary)
                    if let lastAuthorisationURLString = viewModel.lastAuthorisationURLString {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Last Oura authorize URL")
                                .font(.caption.weight(.semibold))
                            Text(lastAuthorisationURLString)
                                .font(.caption.monospaced())
                                .textSelection(.enabled)
                                .foregroundStyle(.secondary)
                        }
                    }
                    if let lastErrorMessage = viewModel.lastErrorMessage {
                        Text(lastErrorMessage)
                            .foregroundStyle(.red)
                    }
                }
                .padding(20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .padding(24)
            .frame(maxWidth: 900, alignment: .leading)
        }
        .navigationTitle("Settings")
    }
}

private struct AppCard: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            Text(message)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
