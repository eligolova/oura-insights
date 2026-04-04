import SwiftUI
import SwiftData
import OuraInsightsCore

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var importService = DataImportService()
    
    @State private var showingPATEntry = false
    @State private var showingDeleteConfirmation = false
    @State private var showingDisconnectConfirmation = false
    @State private var patInput = ""
    @State private var isValidating = false
    @State private var validationError: String?
    @State private var showingImportError = false
    
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
            .sheet(isPresented: $showingPATEntry) {
                patEntrySheet
            }
            .alert("Import Error", isPresented: $showingImportError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(importService.lastError?.localizedDescription ?? "Unknown error occurred")
            }
        }
    }
    
    private var ouraConnectionSection: some View {
        Section {
            if importService.hasToken {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Connected to Oura")
                    Spacer()
                }
                
                Button("Disconnect", role: .destructive) {
                    showingDisconnectConfirmation = true
                }
                .confirmationDialog(
                    "Disconnect from Oura?",
                    isPresented: $showingDisconnectConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Disconnect", role: .destructive) {
                        disconnectOura()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Your Personal Access Token will be removed. You can reconnect at any time.")
                }
            } else {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.red)
                    Text("Not connected")
                }
                
                Button("Connect Oura Ring") {
                    patInput = ""
                    validationError = nil
                    showingPATEntry = true
                }
            }
        } header: {
            Text("Oura Connection")
        } footer: {
            Text("Connect your Oura Ring to sync sleep, readiness, and activity data. You'll need a Personal Access Token from cloud.ouraring.com")
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
                    if importService.isImporting {
                        ProgressView()
                    }
                }
            }
            .disabled(!importService.hasToken || importService.isImporting)
            
            if importService.isImporting {
                Text(importService.importProgress)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if let lastImport = importService.lastImportDate {
                HStack {
                    Text("Last Import")
                    Spacer()
                    Text(lastImport, style: .relative)
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
            }
            
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
    
    private var patEntrySheet: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("Personal Access Token", text: $patInput)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
                    
                    if let error = validationError {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                } header: {
                    Text("Enter Your Token")
                } footer: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("To get your Personal Access Token:")
                        Text("1. Go to cloud.ouraring.com")
                        Text("2. Sign in to your Oura account")
                        Text("3. Navigate to Personal Access Tokens")
                        Text("4. Create a new token and copy it here")
                    }
                    .font(.caption)
                }
                
                Section {
                    Button {
                        validateAndSaveToken()
                    } label: {
                        HStack {
                            Text("Connect")
                            Spacer()
                            if isValidating {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(patInput.isEmpty || isValidating)
                }
            }
            .navigationTitle("Connect Oura")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingPATEntry = false
                    }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 400, minHeight: 350)
        #endif
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
        try? importService.deleteToken()
    }
    
    private func validateAndSaveToken() {
        isValidating = true
        validationError = nil
        
        Task {
            do {
                try importService.saveToken(patInput)
                let isValid = try await importService.validateToken()
                
                await MainActor.run {
                    isValidating = false
                    if isValid {
                        showingPATEntry = false
                        refreshData()
                    }
                }
            } catch {
                await MainActor.run {
                    isValidating = false
                    validationError = error.localizedDescription
                    try? importService.deleteToken()
                }
            }
        }
    }
    
    private func refreshData() {
        Task {
            do {
                try await importService.importRecentData(days: 30, modelContext: modelContext)
            } catch {
                showingImportError = true
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
        .modelContainer(for: [SleepSession.self, ReadinessScore.self, ActivityDay.self, HeartMetrics.self, LocationSample.self, WeatherSnapshot.self, DerivedInsight.self])
}
