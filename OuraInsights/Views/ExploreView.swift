import SwiftUI
import SwiftData
import Charts

struct ExploreView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var sleepSessions: [SleepSession]
    @Query private var weatherSnapshots: [WeatherSnapshot]
    @Query private var heartMetrics: [HeartMetrics]
    @Query private var locationSamples: [LocationSample]
    
    @State private var selectedCorrelation: CorrelationType = .sleepVsTemperature
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    correlationPicker
                    correlationChart
                    correlationInsight
                }
                .padding()
            }
            .navigationTitle("Explore")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
    }
    
    private var correlationPicker: some View {
        Picker("Correlation", selection: $selectedCorrelation) {
            ForEach(CorrelationType.allCases) { type in
                Text(type.title).tag(type)
            }
        }
        .pickerStyle(.segmented)
    }
    
    private var correlationChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(selectedCorrelation.chartTitle)
                .font(.headline)
            
            if hasDataForSelectedCorrelation {
                scatterChart
            } else {
                emptyChartPlaceholder
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    @ViewBuilder
    private var scatterChart: some View {
        switch selectedCorrelation {
        case .sleepVsTemperature:
            sleepTemperatureChart
        case .hrvVsLocation:
            hrvLocationChart
        }
    }
    
    private var sleepTemperatureChart: some View {
        Chart {
            ForEach(sleepTemperatureData, id: \.sleepId) { point in
                PointMark(
                    x: .value("Temperature (°C)", point.temperature),
                    y: .value("Sleep (hours)", point.sleepHours)
                )
                .foregroundStyle(.blue)
            }
        }
        .chartXAxisLabel("Temperature (°C)")
        .chartYAxisLabel("Sleep Duration (hours)")
        .frame(height: 250)
    }
    
    private var hrvLocationChart: some View {
        Chart {
            ForEach(hrvLocationData, id: \.hrvId) { point in
                PointMark(
                    x: .value("Location Variance", point.locationVariance),
                    y: .value("HRV (ms)", point.hrv)
                )
                .foregroundStyle(.purple)
            }
        }
        .chartXAxisLabel("Travel Distance (km)")
        .chartYAxisLabel("HRV (ms)")
        .frame(height: 250)
    }
    
    private var emptyChartPlaceholder: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.dots.scatter")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Not enough data to show correlations")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Keep syncing your data to discover insights")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(height: 250)
        .frame(maxWidth: .infinity)
    }
    
    private var correlationInsight: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Insight")
                .font(.headline)
            
            Text(selectedCorrelation.insightDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var hasDataForSelectedCorrelation: Bool {
        switch selectedCorrelation {
        case .sleepVsTemperature:
            return !sleepTemperatureData.isEmpty
        case .hrvVsLocation:
            return !hrvLocationData.isEmpty
        }
    }
    
    private var sleepTemperatureData: [(sleepId: String, temperature: Double, sleepHours: Double)] {
        var result: [(sleepId: String, temperature: Double, sleepHours: Double)] = []
        
        for sleep in sleepSessions {
            guard let duration = sleep.totalSleepDuration else { continue }
            
            let matchingWeather = weatherSnapshots.first { weather in
                Calendar.current.isDate(weather.date, inSameDayAs: sleep.date)
            }
            
            if let weather = matchingWeather, let temp = weather.temperatureMean {
                result.append((
                    sleepId: sleep.id,
                    temperature: temp,
                    sleepHours: Double(duration) / 3600.0
                ))
            }
        }
        
        return result
    }
    
    private var hrvLocationData: [(hrvId: String, locationVariance: Double, hrv: Double)] {
        var result: [(hrvId: String, locationVariance: Double, hrv: Double)] = []
        
        for metrics in heartMetrics {
            guard let hrv = metrics.averageHRV else { continue }
            
            let dayLocations = locationSamples.filter { location in
                Calendar.current.isDate(location.date, inSameDayAs: metrics.date)
            }
            
            if dayLocations.count >= 2 {
                let variance = calculateLocationVariance(dayLocations)
                result.append((
                    hrvId: metrics.id,
                    locationVariance: variance,
                    hrv: hrv
                ))
            }
        }
        
        return result
    }
    
    private func calculateLocationVariance(_ locations: [LocationSample]) -> Double {
        guard locations.count >= 2 else { return 0 }
        
        var totalDistance: Double = 0
        for i in 1..<locations.count {
            let dist = haversineDistance(
                lat1: locations[i-1].latitude,
                lon1: locations[i-1].longitude,
                lat2: locations[i].latitude,
                lon2: locations[i].longitude
            )
            totalDistance += dist
        }
        
        return totalDistance
    }
    
    private func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let R = 6371.0
        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180
        let a = sin(dLat/2) * sin(dLat/2) +
                cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
                sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        return R * c
    }
}

enum CorrelationType: String, CaseIterable, Identifiable {
    case sleepVsTemperature
    case hrvVsLocation
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .sleepVsTemperature: return "Sleep & Temp"
        case .hrvVsLocation: return "HRV & Travel"
        }
    }
    
    var chartTitle: String {
        switch self {
        case .sleepVsTemperature: return "Sleep Duration vs Temperature"
        case .hrvVsLocation: return "HRV vs Travel Distance"
        }
    }
    
    var insightDescription: String {
        switch self {
        case .sleepVsTemperature:
            return "This chart explores whether ambient temperature affects your sleep duration. Cooler temperatures typically promote better sleep."
        case .hrvVsLocation:
            return "This chart shows how travel and location changes correlate with your heart rate variability. Higher HRV generally indicates better recovery."
        }
    }
}

#Preview {
    ExploreView()
        .modelContainer(for: [SleepSession.self, WeatherSnapshot.self, HeartMetrics.self, LocationSample.self])
}
