import Foundation
import SwiftData

@Model
final class ActivityDay {
    @Attribute(.unique) var id: String
    var date: Date
    var score: Int?
    var activeCalories: Int?
    var totalCalories: Int?
    var steps: Int?
    var equivalentWalkingDistance: Int?
    var highActivityTime: Int?
    var mediumActivityTime: Int?
    var lowActivityTime: Int?
    var sedentaryTime: Int?
    var restingTime: Int?
    var inactivityAlerts: Int?
    var meetDailyTargets: Int?
    var moveEveryHour: Int?
    var recoveryTime: Int?
    var trainingFrequency: Int?
    var trainingVolume: Int?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: String,
        date: Date,
        score: Int? = nil,
        activeCalories: Int? = nil,
        totalCalories: Int? = nil,
        steps: Int? = nil,
        equivalentWalkingDistance: Int? = nil,
        highActivityTime: Int? = nil,
        mediumActivityTime: Int? = nil,
        lowActivityTime: Int? = nil,
        sedentaryTime: Int? = nil,
        restingTime: Int? = nil,
        inactivityAlerts: Int? = nil,
        meetDailyTargets: Int? = nil,
        moveEveryHour: Int? = nil,
        recoveryTime: Int? = nil,
        trainingFrequency: Int? = nil,
        trainingVolume: Int? = nil
    ) {
        self.id = id
        self.date = date
        self.score = score
        self.activeCalories = activeCalories
        self.totalCalories = totalCalories
        self.steps = steps
        self.equivalentWalkingDistance = equivalentWalkingDistance
        self.highActivityTime = highActivityTime
        self.mediumActivityTime = mediumActivityTime
        self.lowActivityTime = lowActivityTime
        self.sedentaryTime = sedentaryTime
        self.restingTime = restingTime
        self.inactivityAlerts = inactivityAlerts
        self.meetDailyTargets = meetDailyTargets
        self.moveEveryHour = moveEveryHour
        self.recoveryTime = recoveryTime
        self.trainingFrequency = trainingFrequency
        self.trainingVolume = trainingVolume
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
