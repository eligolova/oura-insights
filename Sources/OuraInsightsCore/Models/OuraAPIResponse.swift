import Foundation

// MARK: - Generic API Response Wrapper
public struct OuraAPIResponse<T: Codable>: Codable {
    public let data: [T]
    public let nextToken: String?
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextToken = "next_token"
    }
}

// MARK: - Daily Sleep Response
public struct DailySleepResponse: Codable {
    public let id: String
    public let day: String
    public let score: Int?
    public let timestamp: String?
    public let contributors: SleepContributors?
    
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
}

// MARK: - Sleep Document (detailed sleep data)
public struct SleepDocumentResponse: Codable {
    public let id: String
    public let day: String
    public let bedtimeStart: String?
    public let bedtimeEnd: String?
    public let averageBreath: Double?
    public let averageHeartRate: Double?
    public let averageHrv: Int?
    public let awakeTime: Int?
    public let deepSleepDuration: Int?
    public let efficiency: Int?
    public let latency: Int?
    public let lightSleepDuration: Int?
    public let lowBatteryAlert: Bool?
    public let lowestHeartRate: Int?
    public let period: Int?
    public let readinessScoreDelta: Double?
    public let remSleepDuration: Int?
    public let restlessPeriods: Int?
    public let sleepPhase5Min: String?
    public let sleepAlgorithmVersion: String?
    public let timeInBed: Int?
    public let totalSleepDuration: Int?
    public let type: String?
    
    enum CodingKeys: String, CodingKey {
        case id, day
        case bedtimeStart = "bedtime_start"
        case bedtimeEnd = "bedtime_end"
        case averageBreath = "average_breath"
        case averageHeartRate = "average_heart_rate"
        case averageHrv = "average_hrv"
        case awakeTime = "awake_time"
        case deepSleepDuration = "deep_sleep_duration"
        case efficiency, latency
        case lightSleepDuration = "light_sleep_duration"
        case lowBatteryAlert = "low_battery_alert"
        case lowestHeartRate = "lowest_heart_rate"
        case period
        case readinessScoreDelta = "readiness_score_delta"
        case remSleepDuration = "rem_sleep_duration"
        case restlessPeriods = "restless_periods"
        case sleepPhase5Min = "sleep_phase_5_min"
        case sleepAlgorithmVersion = "sleep_algorithm_version"
        case timeInBed = "time_in_bed"
        case totalSleepDuration = "total_sleep_duration"
        case type
    }
}

// MARK: - Daily Readiness Response
public struct DailyReadinessResponse: Codable {
    public let id: String
    public let day: String
    public let score: Int?
    public let temperatureDeviation: Double?
    public let temperatureTrendDeviation: Double?
    public let timestamp: String?
    public let contributors: ReadinessContributors?
    
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
    
    enum CodingKeys: String, CodingKey {
        case id, day, score
        case temperatureDeviation = "temperature_deviation"
        case temperatureTrendDeviation = "temperature_trend_deviation"
        case timestamp, contributors
    }
}

// MARK: - Daily Activity Response
public struct DailyActivityResponse: Codable {
    public let id: String
    public let day: String
    public let score: Int?
    public let activeCalories: Int?
    public let averageMetMinutes: Double?
    public let equivalentWalkingDistance: Int?
    public let highActivityMetMinutes: Int?
    public let highActivityTime: Int?
    public let inactivityAlerts: Int?
    public let lowActivityMetMinutes: Int?
    public let lowActivityTime: Int?
    public let mediumActivityMetMinutes: Int?
    public let mediumActivityTime: Int?
    public let metersToTarget: Int?
    public let nonWearTime: Int?
    public let restingTime: Int?
    public let sedentaryMetMinutes: Int?
    public let sedentaryTime: Int?
    public let steps: Int?
    public let targetCalories: Int?
    public let targetMeters: Int?
    public let totalCalories: Int?
    public let timestamp: String?
    public let contributors: ActivityContributors?
    
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
    
    enum CodingKeys: String, CodingKey {
        case id, day, score
        case activeCalories = "active_calories"
        case averageMetMinutes = "average_met_minutes"
        case equivalentWalkingDistance = "equivalent_walking_distance"
        case highActivityMetMinutes = "high_activity_met_minutes"
        case highActivityTime = "high_activity_time"
        case inactivityAlerts = "inactivity_alerts"
        case lowActivityMetMinutes = "low_activity_met_minutes"
        case lowActivityTime = "low_activity_time"
        case mediumActivityMetMinutes = "medium_activity_met_minutes"
        case mediumActivityTime = "medium_activity_time"
        case metersToTarget = "meters_to_target"
        case nonWearTime = "non_wear_time"
        case restingTime = "resting_time"
        case sedentaryMetMinutes = "sedentary_met_minutes"
        case sedentaryTime = "sedentary_time"
        case steps
        case targetCalories = "target_calories"
        case targetMeters = "target_meters"
        case totalCalories = "total_calories"
        case timestamp, contributors
    }
}

// MARK: - Personal Info Response (for PAT validation)
public struct PersonalInfoResponse: Codable {
    public let id: String
    public let age: Int?
    public let weight: Double?
    public let height: Double?
    public let biologicalSex: String?
    public let email: String?
    
    enum CodingKeys: String, CodingKey {
        case id, age, weight, height
        case biologicalSex = "biological_sex"
        case email
    }
}
