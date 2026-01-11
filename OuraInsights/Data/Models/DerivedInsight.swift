import Foundation
import SwiftData

@Model
final class DerivedInsight {
    @Attribute(.unique) var id: String
    var date: Date
    var metricType: String
    var value: Double
    var period: String
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        date: Date,
        metricType: String,
        value: Double,
        period: String = "daily"
    ) {
        self.id = id
        self.date = date
        self.metricType = metricType
        self.value = value
        self.period = period
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum InsightMetricType: String, CaseIterable {
    case sleepDuration7DayAvg = "sleep_duration_7d_avg"
    case sleepDuration30DayAvg = "sleep_duration_30d_avg"
    case hrv7DayAvg = "hrv_7d_avg"
    case hrv30DayAvg = "hrv_30d_avg"
    case readiness7DayAvg = "readiness_7d_avg"
    case readiness30DayAvg = "readiness_30d_avg"
    case sleepConsistencyScore = "sleep_consistency_score"
    case sleepTemperatureCorrelation = "sleep_temperature_correlation"
    case hrvLocationVariance = "hrv_location_variance"
}
