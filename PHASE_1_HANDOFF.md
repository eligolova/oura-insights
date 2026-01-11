# Oura Insights - Phase 1 Handoff

## Project Overview
Personal health analytics app that ingests data from Oura Ring, enriches with weather/location context, and presents insights via native SwiftUI app for iPhone and macOS.

## Current Status: Phase 0 Complete ✅

### What Was Built

#### Project Structure
```
oura-insights/
├── OuraInsights/                    # SwiftUI app (iOS + macOS)
│   ├── OuraInsightsApp.swift       # App entry point, SwiftData setup
│   ├── ContentView.swift           # Navigation shell
│   ├── Data/Models/                # SwiftData @Model classes
│   │   ├── SleepSession.swift
│   │   ├── ReadinessScore.swift
│   │   ├── ActivityDay.swift
│   │   ├── HeartMetrics.swift
│   │   ├── LocationSample.swift
│   │   ├── WeatherSnapshot.swift
│   │   ├── DerivedInsight.swift
│   │   └── OuraToken.swift
│   ├── Views/                      # SwiftUI views
│   │   ├── DashboardView.swift
│   │   ├── TrendsView.swift
│   │   ├── ExploreView.swift
│   │   └── SettingsView.swift
│   ├── Info.plist                  # App permissions
│   └── Package.swift               # SPM config
├── Sources/OuraInsightsCore/       # Shared Swift Package
│   ├── Models/                     # Codable structs
│   └── Services/
│       └── KeychainService.swift   # Token storage
├── Tests/OuraInsightsCoreTests/    # Unit tests
├── OuraInsights.xcodeproj/         # Xcode project
└── Package.swift                   # Root SPM manifest
```

#### Models (SwiftData)
All models use `@Model` decorator and are configured for SwiftData persistence:

- **SleepSession**: Sleep duration, scores, stages, efficiency
- **ReadinessScore**: Daily readiness (0-100) with category enum
- **ActivityDay**: Steps, calories, active time, training metrics
- **HeartMetrics**: HRV, heart rate data with category enum
- **LocationSample**: GPS coordinates, Haversine distance calculation
- **WeatherSnapshot**: Temperature, humidity, conditions with enum
- **DerivedInsight**: Analytical insights with metric type enum
- **OuraToken**: OAuth access/refresh tokens with expiration logic

#### Views Implemented
- **DashboardView**: Summary cards for sleep, readiness, activity
- **TrendsView**: Time-series charts using Swift Charts
- **ExploreView**: Correlation scatter plots (sleep vs temp, HRV vs location)
- **SettingsView**: Data management, Oura connection placeholder

#### Testing
- ✅ 10 unit tests passing (XCTest)
- ✅ Build succeeds on iOS Simulator and macOS
- ✅ No compilation errors or warnings

## Configuration Details

### Build Settings
- **Platforms**: iOS 17.0+, macOS 14.0+
- **Swift Version**: 5.0
- **SUPPORTED_PLATFORMS**: `iphoneos iphonesimulator macosx`
- **TARGETED_DEVICE_FAMILY**: `1,2` (iPhone + iPad)
- **Code Signing**: Automatic
- **Entitlements**: Removed (iOS doesn't need macOS sandbox)

### Key Files
- `OuraInsights.xcodeproj/project.pbxproj` - Xcode project configuration
- `OuraInsights/Info.plist` - Privacy permissions (location, Face ID)
- `Package.swift` - SPM configuration for `OuraInsightsCore`
- `.gitignore` - Excludes build artifacts

### Build Commands
```bash
# Swift Package (core library)
swift build

# Xcode - iOS Simulator
xcodebuild -scheme OuraInsights -destination 'platform=iOS Simulator,name=iPhone 15' build

# Xcode - Tests
xcodebuild test -scheme OuraInsights -destination 'platform=iOS Simulator,name=iPhone 15'

# Xcode - macOS
xcodebuild -scheme OuraInsights -destination 'platform=macOS' build
```

## Important Technical Decisions

### Color System
- Using `Color.secondary.opacity(0.1)` for cross-platform compatibility
- Avoided `Color(.systemBackground)` which requires UIKit/AppKit context

### Entitlements
- Removed `CODE_SIGN_ENTITLEMENTS` from Xcode project
- iOS apps get appropriate sandboxing automatically
- macOS sandbox entitlements were causing build issues on iOS

### Data Architecture
- **SwiftData models**: In `OuraInsights/Data/Models/` for app persistence
- **Core models**: In `Sources/OuraInsightsCore/Models/` as Codable structs for SPM
- Both model sets serve different purposes (persistence vs. data transfer)

### Logging
- Minimal logging in `OuraInsightsApp.swift` for startup verification
- No view-level logging to avoid console spam

## Next Steps: Phase 1 - Oura Ingestion

### Tasks
1. **OAuth Flow Implementation**
   - Create OAuth2 client for Oura API
   - Implement authorization code flow
   - Handle redirect URI: `oura-insights://oauth-callback`
   - Exchange authorization code for access/refresh tokens

2. **Keychain Token Storage**
   - `KeychainService.swift` already created
   - Store access token, refresh token, expiration
   - Implement token refresh logic

3. **Oura API Client**
   - Create HTTP client for Oura API v2
   - Base URL: `https://api.ouraring.com/v2/`
   - Implement retry logic and error handling
   - Add request/response logging

4. **Data Import**
   - Fetch Daily Sleep data
   - Fetch Daily Readiness data
   - Fetch Daily Activity data
   - Parse API responses into SwiftData models

5. **Data Persistence**
   - Save imported data to SwiftData
   - Handle duplicate data (upsert logic)
   - Implement incremental sync (date range queries)

### Oura API Details

#### Authentication
- **Type**: OAuth2 Authorization Code Flow
- **Auth URL**: `https://cloud.ouraring.com/oauth/authorize`
- **Token URL**: `https://api.ouraring.com/v2/oauth/token`
- **Scopes**: `daily_activity daily_readiness daily_sleep heartrite session`
- **Personal Access Tokens**: Deprecated (use OAuth2)

#### Key Endpoints
```
GET /v2/usercollection/daily_sleep?start_date={date}&end_date={date}
GET /v2/usercollection/daily_readiness?start_date={date}&end_date={date}
GET /v2/usercollection/daily_activity?start_date={date}&end_date={date}
GET /v2/usercollection/heartrite?start_datetime={datetime}&end_datetime={datetime}
```

#### Response Format
```json
{
  "data": [
    {
      "id": "string",
      "day": "YYYY-MM-DD",
      "score": 85,
      // ... other fields
    }
  ],
  "next_token": "string"
}
```

### Existing Foundation
- ✅ `KeychainService.swift` - Ready for token storage
- ✅ `OuraToken` model - Has computed properties for expiration and auth header
- ✅ `SettingsView` - Has placeholder for Oura connection UI
- ✅ SwiftData models - Ready for data persistence

### Implementation Order
1. Create `OuraAPIClient` with OAuth flow
2. Implement token storage/retrieval using `KeychainService`
3. Create data models for API responses (if different from SwiftData models)
4. Implement data fetching for one endpoint (e.g., sleep)
5. Parse and save to SwiftData
6. Repeat for other endpoints
7. Add error handling and retry logic
8. Update `SettingsView` with OAuth trigger button

### Testing Strategy
- **Unit Tests**: Mock API responses, test parsing logic
- **Integration Tests**: Test OAuth flow with test credentials
- **Persistence Tests**: Verify data saved to SwiftData correctly
- **Error Handling**: Test network failures, invalid tokens, rate limits

### Known Requirements
- Privacy-first: All data stored on-device
- No third-party analytics
- On-device analysis only
- Support both iOS and macOS

## Development Environment
- **Xcode**: Installed and licensed
- **Xcode CLI**: Configured (`xcode-select` pointing to Xcode)
- **Simulators**: iPhone SE, iPhone 15 available
- **Swift**: 5.0
- **iOS Deployment**: 17.0+
- **macOS Deployment**: 14.0+

## Potential Issues to Watch
- OAuth redirect URI handling on macOS vs iOS
- Token refresh timing (before expiration)
- API rate limiting (implement backoff)
- Date/time zone handling for API queries
- Large data sets (pagination handling)

## Files to Create/Modify in Phase 1

### New Files
- `Sources/OuraInsightsCore/Services/OuraAPIClient.swift`
- `Sources/OuraInsightsCore/Services/OuraAuthService.swift`
- `Sources/OuraInsightsCore/Models/OuraAPIResponse.swift`
- `OuraInsights/Services/DataImportService.swift`

### Files to Modify
- `OuraInsights/Views/SettingsView.swift` - Add OAuth trigger
- `OuraInsights/OuraInsightsApp.swift` - Handle OAuth callback
- `OuraInsights/Info.plist` - Add URL scheme for OAuth callback
- `Tests/OuraInsightsCoreTests/` - Add API client tests

## Success Criteria for Phase 1
- ✅ User can authorize with Oura API
- ✅ Access/refresh tokens stored securely in Keychain
- ✅ App can fetch sleep data from Oura API
- ✅ App can fetch readiness data from Oura API
- ✅ App can fetch activity data from Oura API
- ✅ Data saved to SwiftData correctly
- ✅ Token refresh works automatically
- ✅ Error handling for network failures
- ✅ Unit tests for API client
- ✅ Manual testing instructions provided

## References
- [Oura API Documentation](https://cloud.ouraring.com/v2/docs)
- [Oura OpenAPI Spec](https://cloud.ouraring.com/v2/static/json/openapi-1.27.json)
- [spec.md](./spec.md) - Full project specification
