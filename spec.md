# Personal Health & Context Analytics App

## 1. Overview

This project is a **personal-first health analytics application** that ingests data from the **Oura Ring**, enriches it with **weather** and **location context**, performs **on-device analysis**, and presents insights via a **native SwiftUI app** running on **iPhone and macOS (shared codebase)**.

Primary intent:

* Deep personal insight (sleep, readiness, HRV) rather than social or gamified use
* Privacy-first
* Architected cleanly so future data sources (e.g. calendar, workouts, travel) can be added

This document is written to be used directly as an **AI coding tool specification** — a shared baseline for parallel implementations across different AI tools (see branches).

---

## 2. Key Product Decisions (locked from questionnaire)

### Platforms

* iPhone + macOS
* Single shared SwiftUI codebase
* iOS Simulator + macOS app supported during development

### Frontend

* **SwiftUI** (pure native)
* MV-style state management (Observable / @StateObject)
* Shared UI with platform-specific affordances where needed

### Scope

* Personal use only (not App Store–ready initially)
* Offline-first
* Long-term data retention (keep everything)

### Privacy & Security

* All data stored **on-device only**
* No third-party analytics
* Optional FaceID / TouchID app lock

---

## 3. Data Sources

### 3.1 Oura Ring

**Auth**

* OAuth2 flow via Oura Cloud API v2
* Secure token storage in Keychain

**Initial datasets**

* Sleep (timing, stages, score)
* Readiness
* Activity (steps, calories)
* Heart rate, HRV, temperature deviation
* Cycle insights

**Ingestion cadence**

* On app open
* Manual refresh

**Notes**

* Incremental sync using `start_date` / `end_date`
* Idempotent writes (safe to re-run imports)

---

### 3.2 Weather

**Provider**

* Open-Meteo (no API key)

**Features captured**

* Temperature
* Humidity
* Precipitation
* Wind
* Pressure

**Matching strategy**

* GPS-based: match weather to where the user was
* Daily resolution initially (hourly later if needed)

---

### 3.3 Location

**Level**

* Precise location while app is open
* No background tracking

**Storage**

* On-device only
* Reduced precision when persisting (e.g. rounded lat/lon)

---

## 4. Data Architecture

### 4.1 Storage

**Local persistence**

* SwiftData

**Core entities**

```text
User
 └── OuraToken

SleepSession
ReadinessScore
ActivityDay
HeartMetrics

LocationSample
WeatherSnapshot

DerivedInsight
```

* All entities keyed by date/time
* Foreign-key–like relationships via IDs

### 4.2 Sync & Integrity

* Import layer writes raw data
* Normalisation layer cleans / aligns
* Analysis layer reads only normalised tables

---

## 5. Analysis & Insights

### Initial analytics (MVP)

1. **Trend views**

   * Sleep duration vs time
   * HRV vs time
   * Readiness vs time

2. **Correlation exploration**

   * Sleep vs temperature
   * HRV vs travel/location variance

3. **Derived metrics**

   * Rolling averages (7d / 30d)
   * Sleep consistency score

All analytics run **on-device**.

No ML in v1 — pure statistical summaries.

---

## 6. UI / UX

### Core Screens

1. **Onboarding**

   * Intro
   * Oura login
   * Permissions (location, FaceID)

2. **Dashboard**

   * Today summary
   * Last night’s sleep
   * Readiness

3. **Trends**

   * Time series charts (weeks / months)

4. **Explore**

   * Scatter plots
   * Simple correlation indicators

5. **Settings**

   * Re-auth Oura
   * Privacy controls
   * Data refresh

### Charts

* Swift Charts
* No third-party charting libs initially

---

## 7. Security

* Oura tokens in Keychain
* App lock via FaceID / TouchID
* No network calls except:

  * Oura API
  * Weather API

---

## 8. Developer Workflow

* GitHub repo
* Swift Package Manager only
* Target AI coding tool: see branch (each branch is a separate AI implementation)
* Use a TDD approach to build the app.
* **Language: UK English throughout** — use British spellings in all code comments, user-facing strings, and documentation (e.g. *colour* not *color*, *organise* not *organize*, *authorisation* not *authorization*, *initialise* not *initialize*).

Directory structure:

```text
App/
 ├── AppEntry
 ├── Views/
 ├── ViewModels/
 ├── Charts/

Data/
 ├── Models/
 ├── Persistence/
 ├── Importers/
 ├── Normalisation/

Services/
 ├── OuraClient
 ├── WeatherClient
 ├── LocationService

Analysis/
 ├── Metrics
 ├── Correlations
```

---

## 9. Build Plan (phased)

### Phase 0 – Repo & skeleton (½ day)

* Create SwiftUI app (iOS + macOS)
* Add SwiftData stack
* Navigation shell

### Phase 1 – Oura ingestion (1–2 days)

* OAuth flow
* Token storage
* Import sleep + readiness
* Persist raw + normalised data

### Phase 2 – Weather + location (1 day)

* Location permission + sampling
* Open-Meteo client
* Daily weather snapshots

### Phase 3 – Analytics (1–2 days)

* Rolling averages
* Simple correlations
* Derived metrics table

### Phase 4 – UI polish (1–2 days)

* Dashboard
* Trend charts
* Explore screen

### Phase 5 – Hardening (1 day)

* Error handling
* Re-sync logic
* FaceID lock

---

## 10. Explicit Non‑Goals (for v1)

* Cloud sync
* Multi-user
* Background GPS tracking
* Machine learning models
* App Store distribution

---

## 11. Future Extensions

* Calendar + travel detection
* Workout data (Apple Health)
* On-device ML insights
* Natural-language queries over your own data

---

**End of specification**
