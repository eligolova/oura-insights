import Foundation

public struct DailySleepResponse: Codable, PaginatedResponse {
    public let data: [DailySleepData]
    public let nextToken: String?
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextToken = "next_token"
    }
}

public struct DailySleepData: Codable, Identifiable {
    public let id: String
    public let day: String
    public let score: Int?
    public let contributors: SleepContributors?
    public let timestamp: String?
    
    public var dayDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: day)
    }
}

public struct SleepContributors: Codable {
    public let deepSleep: Int?
    public let efficiency: Int?
    public let latency: Int?
    public let remSleep: Int?
    public let restfulness: Int?
    public let timing: Int?
    public let totalSleep: Int?
    
    enum CodingKeys: String, CodingKey {
        case deepSleep = "deep_sleep"
        case efficiency
        case latency
        case remSleep = "rem_sleep"
        case restfulness
        case timing
        case totalSleep = "total_sleep"
    }
}

public struct DailyReadinessResponse: Codable, PaginatedResponse {
    public let data: [DailyReadinessData]
    public let nextToken: String?
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextToken = "next_token"
    }
}

public struct DailyReadinessData: Codable, Identifiable {
    public let id: String
    public let day: String
    public let score: Int?
    public let temperatureDeviation: Double?
    public let temperatureTrendDeviation: Double?
    public let contributors: ReadinessContributors?
    public let timestamp: String?
    
    enum CodingKeys: String, CodingKey {
        case id, day, score, timestamp
        case temperatureDeviation = "temperature_deviation"
        case temperatureTrendDeviation = "temperature_trend_deviation"
        case contributors
    }
    
    public var dayDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: day)
    }
}

public struct ReadinessContributors: Codable {
    public let activityBalance: Int?
    public let bodyTemperature: Int?
    public let hrvBalance: Int?
    public let previousDayActivity: Int?
    public let previousNight: Int?
    public let recoveryIndex: Int?
    public let restingHeartRate: Int?
    public let sleepBalance: Int?
    
    enum CodingKeys: String, CodingKey {
        case activityBalance = "activity_balance"
        case bodyTemperature = "body_temperature"
        case hrvBalance = "hrv_balance"
        case previousDayActivity = "previous_day_activity"
        case previousNight = "previous_night"
        case recoveryIndex = "recovery_index"
        case restingHeartRate = "resting_heart_rate"
        case sleepBalance = "sleep_balance"
    }
}

public struct DailyActivityResponse: Codable, PaginatedResponse {
    public let data: [DailyActivityData]
    public let nextToken: String?
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextToken = "next_token"
    }
}

public struct DailyActivityData: Codable, Identifiable {
    public let id: String
    public let day: String
    public let score: Int?
    public let activeCalories: Int?
    public let totalCalories: Int?
    public let steps: Int?
    public let equivalentWalkingDistance: Int?
    public let highActivityTime: Int?
    public let mediumActivityTime: Int?
    public let lowActivityTime: Int?
    public let sedentaryTime: Int?
    public let restingTime: Int?
    public let inactivityAlerts: Int?
    public let contributors: ActivityContributors?
    public let timestamp: String?
    
    enum CodingKeys: String, CodingKey {
        case id, day, score, steps, timestamp, contributors
        case activeCalories = "active_calories"
        case totalCalories = "total_calories"
        case equivalentWalkingDistance = "equivalent_walking_distance"
        case highActivityTime = "high_activity_time"
        case mediumActivityTime = "medium_activity_time"
        case lowActivityTime = "low_activity_time"
        case sedentaryTime = "sedentary_time"
        case restingTime = "resting_time"
        case inactivityAlerts = "inactivity_alerts"
    }
    
    public var dayDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: day)
    }
}

public struct ActivityContributors: Codable {
    public let meetDailyTargets: Int?
    public let moveEveryHour: Int?
    public let recoveryTime: Int?
    public let stayActive: Int?
    public let trainingFrequency: Int?
    public let trainingVolume: Int?
    
    enum CodingKeys: String, CodingKey {
        case meetDailyTargets = "meet_daily_targets"
        case moveEveryHour = "move_every_hour"
        case recoveryTime = "recovery_time"
        case stayActive = "stay_active"
        case trainingFrequency = "training_frequency"
        case trainingVolume = "training_volume"
    }
}

public struct HeartRateResponse: Codable, PaginatedResponse {
    public let data: [HeartRateData]
    public let nextToken: String?
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextToken = "next_token"
    }
}

public struct HeartRateData: Codable, Identifiable {
    public var id: String { timestamp }
    public let bpm: Int
    public let source: String
    public let timestamp: String
    
    public var timestampDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: timestamp) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: timestamp)
    }
}

public struct SleepSessionResponse: Codable, PaginatedResponse {
    public let data: [SleepSessionData]
    public let nextToken: String?
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextToken = "next_token"
    }
}

public struct SleepSessionData: Codable, Identifiable {
    public let id: String
    public let day: String
    public let bedtimeStart: String?
    public let bedtimeEnd: String?
    public let totalSleepDuration: Int?
    public let awakeTime: Int?
    public let remSleepDuration: Int?
    public let lightSleepDuration: Int?
    public let deepSleepDuration: Int?
    public let efficiency: Int?
    public let latency: Int?
    public let type: String?
    
    enum CodingKeys: String, CodingKey {
        case id, day, efficiency, latency, type
        case bedtimeStart = "bedtime_start"
        case bedtimeEnd = "bedtime_end"
        case totalSleepDuration = "total_sleep_duration"
        case awakeTime = "awake_time"
        case remSleepDuration = "rem_sleep_duration"
        case lightSleepDuration = "light_sleep_duration"
        case deepSleepDuration = "deep_sleep_duration"
    }
    
    public var dayDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: day)
    }
    
    public var bedtimeStartDate: Date? {
        guard let bedtimeStart = bedtimeStart else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: bedtimeStart) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: bedtimeStart)
    }
    
    public var bedtimeEndDate: Date? {
        guard let bedtimeEnd = bedtimeEnd else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: bedtimeEnd) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: bedtimeEnd)
    }
}
