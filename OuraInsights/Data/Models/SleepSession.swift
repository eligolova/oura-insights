import SwiftData
import Foundation

@Model
final class SleepSession {
    @Attribute(.unique) var id: String
    var date: Date
    var totalSleepDuration: Int
    var remSleepDuration: Int
    var deepSleepDuration: Int
    var lightSleepDuration: Int
    var score: Int?
    var bedtimeStart: Date?
    var bedtimeEnd: Date?

    init(
        id: String,
        date: Date,
        totalSleepDuration: Int = 0,
        remSleepDuration: Int = 0,
        deepSleepDuration: Int = 0,
        lightSleepDuration: Int = 0,
        score: Int? = nil,
        bedtimeStart: Date? = nil,
        bedtimeEnd: Date? = nil
    ) {
        self.id = id
        self.date = date
        self.totalSleepDuration = totalSleepDuration
        self.remSleepDuration = remSleepDuration
        self.deepSleepDuration = deepSleepDuration
        self.lightSleepDuration = lightSleepDuration
        self.score = score
        self.bedtimeStart = bedtimeStart
        self.bedtimeEnd = bedtimeEnd
    }
}
