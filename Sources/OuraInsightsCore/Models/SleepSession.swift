import Foundation

public struct SleepSession: Identifiable, Codable, Equatable {
    public let id: String
    public var date: Date
    public var bedtimeStart: Date?
    public var bedtimeEnd: Date?
    public var totalSleepDuration: Int?
    public var remSleepDuration: Int?
    public var deepSleepDuration: Int?
    public var lightSleepDuration: Int?
    public var awakeTime: Int?
    public var sleepScore: Int?
    public var efficiency: Int?
    public var latency: Int?
    public var restfulness: Int?
    public var timing: Int?
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
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
    
    public var sleepDurationHours: Double? {
        guard let duration = totalSleepDuration else { return nil }
        return Double(duration) / 3600.0
    }
    
    public var formattedDuration: String? {
        guard let duration = totalSleepDuration else { return nil }
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}
