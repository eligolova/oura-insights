# Oura Insights

A personal-first health analytics application that ingests data from the Oura Ring, enriches it with weather and location context, performs on-device analysis, and presents insights via a native SwiftUI app.

## Features

- **Privacy-first**: All data stored on-device only
- **Cross-platform**: Runs on iOS and macOS with shared codebase
- **Deep insights**: Sleep, readiness, HRV analytics with environmental correlations
- **Offline-first**: Works without internet, syncs when available

## Requirements

- macOS 14.0+ / iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (for project generation)

## Setup

### 1. Install XcodeGen (if not already installed)

```bash
brew install xcodegen
```

### 2. Generate the Xcode project

```bash
cd /path/to/oura-insights
xcodegen generate
```

### 3. Open in Xcode

```bash
open OuraInsights.xcodeproj
```

### 4. Build and Run

Select the iOS Simulator or Mac target and press Cmd+R.

## Project Structure

```
OuraInsights/
├── OuraInsightsApp.swift     # App entry point
├── ContentView.swift         # Main navigation
├── Data/
│   └── Models/               # SwiftData models
│       ├── SleepSession.swift
│       ├── ReadinessScore.swift
│       ├── ActivityDay.swift
│       ├── HeartMetrics.swift
│       ├── LocationSample.swift
│       ├── WeatherSnapshot.swift
│       ├── DerivedInsight.swift
│       └── OuraToken.swift
├── Views/
│   ├── DashboardView.swift   # Today summary
│   ├── TrendsView.swift      # Time series charts
│   ├── ExploreView.swift     # Correlation analysis
│   └── SettingsView.swift    # Configuration
├── Services/                 # (Phase 1-2)
│   ├── OuraClient/           # Oura API integration
│   ├── WeatherClient/        # Open-Meteo integration
│   └── LocationService/      # CoreLocation wrapper
└── Analysis/                 # (Phase 3)
    ├── Metrics/              # Rolling averages
    └── Correlations/         # Statistical analysis

OuraInsightsTests/
└── OuraInsightsTests.swift   # Unit tests
```

## Build Phases

- **Phase 0**: Repo & skeleton (current) ✓
- **Phase 1**: Oura ingestion (OAuth, data sync)
- **Phase 2**: Weather + location integration
- **Phase 3**: Analytics engine
- **Phase 4**: UI polish
- **Phase 5**: Hardening (error handling, FaceID)

## Testing

Run tests in Xcode with Cmd+U or:

```bash
xcodebuild test -scheme OuraInsights -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Privacy

- All data stored locally using SwiftData
- No third-party analytics
- Oura tokens stored in Keychain
- Location data stored with reduced precision
- Optional FaceID/TouchID app lock

## License

Personal use only. Not for distribution.
