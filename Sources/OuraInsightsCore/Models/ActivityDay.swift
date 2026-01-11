import Foundation

public struct ActivityDay: Identifiable, Codable, Equatable {
    public let id: String
    public var date: Date
    public var score: Int?
    public var activeCalories: Int?
    public var totalCalories: Int?
    public var steps: Int?
    public var equivalentWalkingDistance: Int?
    public var highActivityTime: Int?
    public var mediumActivityTime: Int?
    public var lowActivityTime: Int?
    public var sedentaryTime: Int?
    public var restingTime: Int?
    public var inactivityAlerts: Int?
    public var meetDailyTargets: Int?
    public var moveEveryHour: Int?
    public var recoveryTime: Int?
    public var trainingFrequency: Int?
    public var trainingVolume: Int?
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
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
    
    public var formattedSteps: String {
        guard let steps = steps else { return "—" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: steps)) ?? "\(steps)"
    }
    
    public var totalActiveMinutes: Int? {
        guard let high = highActivityTime, let medium = mediumActivityTime, let low = lowActivityTime else {
            return nil
        }
        return (high + medium + low) / 60
    }
}
