import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .dashboard
    
    var body: some View {
        #if os(iOS)
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "heart.text.square")
                }
                .tag(Tab.dashboard)
            
            TrendsView()
                .tabItem {
                    Label("Trends", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(Tab.trends)
            
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }
                .tag(Tab.explore)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(Tab.settings)
        }
        #else
        NavigationSplitView {
            Sidebar(selectedTab: $selectedTab)
        } detail: {
            switch selectedTab {
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
        #endif
    }
}

enum Tab: String, CaseIterable, Identifiable {
    case dashboard
    case trends
    case explore
    case settings
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .trends: return "Trends"
        case .explore: return "Explore"
        case .settings: return "Settings"
        }
    }
    
    var icon: String {
        switch self {
        case .dashboard: return "heart.text.square"
        case .trends: return "chart.line.uptrend.xyaxis"
        case .explore: return "magnifyingglass"
        case .settings: return "gear"
        }
    }
}

#if os(macOS)
struct Sidebar: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        List(Tab.allCases, selection: $selectedTab) { tab in
            Label(tab.title, systemImage: tab.icon)
                .tag(tab)
        }
        .listStyle(.sidebar)
        .navigationTitle("Oura Insights")
    }
}
#endif

#Preview {
    ContentView()
}
