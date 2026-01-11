import Foundation

public struct DerivedInsight: Identifiable, Codable, Equatable {
    public let id: String
    public var date: Date
    public var metricType: String
    public var value: Double
    public var period: String
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
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
    
    public init(
        id: String = UUID().uuidString,
        date: Date,
        metricType: InsightMetricType,
        value: Double,
        period: String = "daily"
    ) {
        self.id = id
        self.date = date
        self.metricType = metricType.rawValue
        self.value = value
        self.period = period
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

public enum InsightMetricType: String, CaseIterable, Codable {
    case sleepDuration7DayAvg = "sleep_duration_7d_avg"
    case sleepDuration30DayAvg = "sleep_duration_30d_avg"
    case hrv7DayAvg = "hrv_7d_avg"
    case hrv30DayAvg = "hrv_30d_avg"
    case readiness7DayAvg = "readiness_7d_avg"
    case readiness30DayAvg = "readiness_30d_avg"
    case sleepConsistencyScore = "sleep_consistency_score"
    case sleepTemperatureCorrelation = "sleep_temperature_correlation"
    case hrvLocationVariance = "hrv_location_variance"
    
    public var displayName: String {
        switch self {
        case .sleepDuration7DayAvg: return "7-Day Sleep Average"
        case .sleepDuration30DayAvg: return "30-Day Sleep Average"
        case .hrv7DayAvg: return "7-Day HRV Average"
        case .hrv30DayAvg: return "30-Day HRV Average"
        case .readiness7DayAvg: return "7-Day Readiness Average"
        case .readiness30DayAvg: return "30-Day Readiness Average"
        case .sleepConsistencyScore: return "Sleep Consistency"
        case .sleepTemperatureCorrelation: return "Sleep vs Temperature"
        case .hrvLocationVariance: return "HRV vs Travel"
        }
    }
}
