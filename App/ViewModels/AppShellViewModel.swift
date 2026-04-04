import Observation

enum AppDestination: String, CaseIterable, Codable, Hashable, Identifiable {
    case dashboard
    case trends
    case explore
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard:
            "Dashboard"
        case .trends:
            "Trends"
        case .explore:
            "Explore"
        case .settings:
            "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard:
            "heart.text.square"
        case .trends:
            "chart.xyaxis.line"
        case .explore:
            "point.3.connected.trianglepath.dotted"
        case .settings:
            "gearshape"
        }
    }
}

@Observable
final class AppShellViewModel {
    var selectedDestination: AppDestination

    init(selectedDestination: AppDestination = .dashboard) {
        self.selectedDestination = selectedDestination
    }

    var destinations: [AppDestination] {
        AppDestination.allCases
    }
}
