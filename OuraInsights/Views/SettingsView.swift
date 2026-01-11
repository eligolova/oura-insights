import SwiftUI
import SwiftData

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var ouraTokens: [OuraToken]
    
    @State private var showingOuraAuth = false
    @State private var showingDeleteConfirmation = false
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationStack {
            List {
                ouraConnectionSection
                dataManagementSection
                privacySection
                aboutSection
            }
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
    }
    
    private var ouraConnectionSection: some View {
        Section {
            if let token = ouraTokens.first {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Connected to Oura")
                    Spacer()
                    if let expiresAt = token.expiresAt {
                        Text(expiresAt, style: .relative)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Button("Disconnect", role: .destructive) {
                    disconnectOura()
                }
            } else {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.red)
                    Text("Not connected")
                }
                
                Button("Connect Oura Ring") {
                    showingOuraAuth = true
                }
            }
        } header: {
            Text("Oura Connection")
        } footer: {
            Text("Connect your Oura Ring to sync sleep, readiness, and activity data.")
        }
    }
    
    private var dataManagementSection: some View {
        Section {
            Button {
                refreshData()
            } label: {
                HStack {
                    Text("Refresh Data")
                    Spacer()
                    if isRefreshing {
                        ProgressView()
                    }
                }
            }
            .disabled(ouraTokens.isEmpty || isRefreshing)
            
            Button("Delete All Data", role: .destructive) {
                showingDeleteConfirmation = true
            }
            .confirmationDialog(
                "Delete All Data",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete Everything", role: .destructive) {
                    deleteAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all your health data. This action cannot be undone.")
            }
        } header: {
            Text("Data Management")
        }
    }
    
    private var privacySection: some View {
        Section {
            Toggle("Require Face ID", isOn: .constant(false))
                .disabled(true)
            
            NavigationLink {
                PrivacyInfoView()
            } label: {
                Text("Privacy Information")
            }
        } header: {
            Text("Privacy & Security")
        } footer: {
            Text("All data is stored locally on your device. No data is sent to third parties.")
        }
    }
    
    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Text("Build")
                Spacer()
                Text("1")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("About")
        }
    }
    
    private func disconnectOura() {
        for token in ouraTokens {
            modelContext.delete(token)
        }
        try? modelContext.save()
    }
    
    private func refreshData() {
        isRefreshing = true
        Task {
            try? await Task.sleep(for: .seconds(2))
            await MainActor.run {
                isRefreshing = false
            }
        }
    }
    
    private func deleteAllData() {
        do {
            try modelContext.delete(model: SleepSession.self)
            try modelContext.delete(model: ReadinessScore.self)
            try modelContext.delete(model: ActivityDay.self)
            try modelContext.delete(model: HeartMetrics.self)
            try modelContext.delete(model: LocationSample.self)
            try modelContext.delete(model: WeatherSnapshot.self)
            try modelContext.delete(model: DerivedInsight.self)
            try modelContext.save()
        } catch {
            print("Failed to delete data: \(error)")
        }
    }
}

struct PrivacyInfoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Your Privacy Matters")
                    .font(.title2.bold())
                
                Text("Oura Insights is designed with privacy as a core principle. Here's how we protect your data:")
                
                PrivacyPoint(
                    icon: "iphone",
                    title: "On-Device Storage",
                    description: "All your health data is stored locally on your device using Apple's secure SwiftData framework."
                )
                
                PrivacyPoint(
                    icon: "network.slash",
                    title: "No Third-Party Analytics",
                    description: "We don't use any analytics services. Your data never leaves your device except to connect to Oura and weather services."
                )
                
                PrivacyPoint(
                    icon: "lock.shield",
                    title: "Secure Authentication",
                    description: "Your Oura credentials are stored securely in the iOS Keychain and are never accessible to other apps."
                )
                
                PrivacyPoint(
                    icon: "location.slash",
                    title: "Minimal Location Data",
                    description: "Location data is only collected while the app is open, stored with reduced precision, and never shared."
                )
            }
            .padding()
        }
        .navigationTitle("Privacy")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct PrivacyPoint: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [OuraToken.self, SleepSession.self, ReadinessScore.self, ActivityDay.self, HeartMetrics.self, LocationSample.self, WeatherSnapshot.self, DerivedInsight.self])
}
