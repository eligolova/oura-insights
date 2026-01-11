import Foundation
import SwiftData

@Model
final class SleepSession {
    @Attribute(.unique) var id: String
    var date: Date
    var bedtimeStart: Date?
    var bedtimeEnd: Date?
    var totalSleepDuration: Int?
    var remSleepDuration: Int?
    var deepSleepDuration: Int?
    var lightSleepDuration: Int?
    var awakeTime: Int?
    var sleepScore: Int?
    var efficiency: Int?
    var latency: Int?
    var restfulness: Int?
    var timing: Int?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: String,
        date: Date,
        bedtimeStart: Date? = nil,
        bedtimeEnd: Date? = nil,
        totalSleepDuration: Int? = nil,
        remSleepDuration: Int? = nil,
        deepSleepDuration: Int? = nil,
        lightSleepDuration: Int? = nil,
        awakeTime: Int? = nil,
        sleepScore: Int? = nil,
        efficiency: Int? = nil,
        latency: Int? = nil,
        restfulness: Int? = nil,
        timing: Int? = nil
    ) {
        self.id = id
        self.date = date
        self.bedtimeStart = bedtimeStart
        self.bedtimeEnd = bedtimeEnd
        self.totalSleepDuration = totalSleepDuration
        self.remSleepDuration = remSleepDuration
        self.deepSleepDuration = deepSleepDuration
        self.lightSleepDuration = lightSleepDuration
        self.awakeTime = awakeTime
        self.sleepScore = sleepScore
        self.efficiency = efficiency
        self.latency = latency
        self.restfulness = restfulness
        self.timing = timing
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
