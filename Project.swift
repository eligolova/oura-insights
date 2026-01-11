// This file documents the Xcode project structure for OuraInsights
// To create the actual Xcode project, use: xcodegen generate
// Or create manually in Xcode with the following settings:

/*
Project: OuraInsights
Platforms: iOS 17.0+, macOS 14.0+
Swift Version: 5.9+
Architecture: SwiftUI + SwiftData

Target: OuraInsights
- Type: Application
- Platforms: iOS, macOS
- Deployment: iOS 17.0, macOS 14.0
- Frameworks: SwiftUI, SwiftData, Charts, CoreLocation

Target: OuraInsightsTests
- Type: Unit Test Bundle
- Host Application: OuraInsights

Directory Structure:
OuraInsights/
├── OuraInsightsApp.swift (App entry point)
├── ContentView.swift (Main navigation)
├── Data/
│   └── Models/
│       ├── SleepSession.swift
│       ├── ReadinessScore.swift
│       ├── ActivityDay.swift
│       ├── HeartMetrics.swift
│       ├── LocationSample.swift
│       ├── WeatherSnapshot.swift
│       ├── DerivedInsight.swift
│       └── OuraToken.swift
├── Views/
│   ├── DashboardView.swift
│   ├── TrendsView.swift
│   ├── ExploreView.swift
│   └── SettingsView.swift
├── Services/ (Phase 1-2)
│   ├── OuraClient/
│   ├── WeatherClient/
│   └── LocationService/
└── Analysis/ (Phase 3)
    ├── Metrics/
    └── Correlations/

OuraInsightsTests/
└── OuraInsightsTests.swift
*/
