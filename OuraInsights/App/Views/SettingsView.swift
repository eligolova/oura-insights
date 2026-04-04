import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Oura") {
                    Label("Connect Oura Ring", systemImage: "link")
                        .foregroundStyle(.secondary)
                }

                Section("Privacy") {
                    Label("App Lock (Face ID / Touch ID)", systemImage: "faceid")
                        .foregroundStyle(.secondary)
                }

                Section("Data") {
                    Label("Refresh Data", systemImage: "arrow.clockwise")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
