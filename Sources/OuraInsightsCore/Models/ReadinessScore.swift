import Foundation

public struct ReadinessScore: Identifiable, Codable, Equatable {
    public let id: String
    public var date: Date
    public var score: Int?
    public var temperatureDeviation: Double?
    public var activityBalance: Int?
    public var bodyTemperature: Int?
    public var hrvBalance: Int?
    public var previousDayActivity: Int?
    public var previousNight: Int?
    public var recoveryIndex: Int?
    public var restingHeartRate: Int?
    public var sleepBalance: Int?
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: String,
        date: Date,
        score: Int? = nil,
        temperatureDeviation: Double? = nil,
        activityBalance: Int? = nil,
        bodyTemperature: Int? = nil,
        hrvBalance: Int? = nil,
        previousDayActivity: Int? = nil,
        previousNight: Int? = nil,
        recoveryIndex: Int? = nil,
        restingHeartRate: Int? = nil,
        sleepBalance: Int? = nil
    ) {
        self.id = id
        self.date = date
        self.score = score
        self.temperatureDeviation = temperatureDeviation
        self.activityBalance = activityBalance
        self.bodyTemperature = bodyTemperature
        self.hrvBalance = hrvBalance
        self.previousDayActivity = previousDayActivity
        self.previousNight = previousNight
        self.recoveryIndex = recoveryIndex
        self.restingHeartRate = restingHeartRate
        self.sleepBalance = sleepBalance
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    public var scoreCategory: ScoreCategory {
        guard let score = score else { return .unknown }
        switch score {
        case 85...100: return .optimal
        case 70..<85: return .good
        case 50..<70: return .payAttention
        default: return .takeItEasy
        }
    }
}

public enum ScoreCategory: String, Codable {
    case optimal = "Optimal"
    case good = "Good"
    case payAttention = "Pay Attention"
    case takeItEasy = "Take It Easy"
    case unknown = "Unknown"
}
