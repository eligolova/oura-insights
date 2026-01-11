import Foundation

public struct HeartMetrics: Identifiable, Codable, Equatable {
    public let id: String
    public var date: Date
    public var averageHRV: Double?
    public var lowestHRV: Double?
    public var highestHRV: Double?
    public var averageHeartRate: Double?
    public var lowestHeartRate: Double?
    public var highestHeartRate: Double?
    public var restingHeartRate: Double?
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: String,
        date: Date,
        averageHRV: Double? = nil,
        lowestHRV: Double? = nil,
        highestHRV: Double? = nil,
        averageHeartRate: Double? = nil,
        lowestHeartRate: Double? = nil,
        highestHeartRate: Double? = nil,
        restingHeartRate: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.averageHRV = averageHRV
        self.lowestHRV = lowestHRV
        self.highestHRV = highestHRV
        self.averageHeartRate = averageHeartRate
        self.lowestHeartRate = lowestHeartRate
        self.highestHeartRate = highestHeartRate
        self.restingHeartRate = restingHeartRate
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    public var hrvCategory: HRVCategory {
        guard let hrv = averageHRV else { return .unknown }
        switch hrv {
        case 50...: return .high
        case 30..<50: return .moderate
        case 0..<30: return .low
        default: return .unknown
        }
    }
}

public enum HRVCategory: String, Codable {
    case high = "High"
    case moderate = "Moderate"
    case low = "Low"
    case unknown = "Unknown"
}
