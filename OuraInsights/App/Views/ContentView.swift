import SwiftUI

struct ContentView: View {
    @AppStorage("isOnboarded") private var isOnboarded = false

    var body: some View {
        if isOnboarded {
            MainTabView()
        } else {
            OnboardingView(isOnboarded: $isOnboarded)
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "heart.text.square")
                }
            TrendsView()
                .tabItem {
                    Label("Trends", systemImage: "chart.line.uptrend.xyaxis")
                }
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    ContentView()
}
