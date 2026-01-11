import Foundation
import SwiftData

@Model
final class ReadinessScore {
    @Attribute(.unique) var id: String
    var date: Date
    var score: Int?
    var temperatureDeviation: Double?
    var activityBalance: Int?
    var bodyTemperature: Int?
    var hrvBalance: Int?
    var previousDayActivity: Int?
    var previousNight: Int?
    var recoveryIndex: Int?
    var restingHeartRate: Int?
    var sleepBalance: Int?
    var createdAt: Date
    var updatedAt: Date
    
    init(
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
}
