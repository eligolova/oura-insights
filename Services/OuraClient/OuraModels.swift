import Foundation

struct OuraCollectionPage<T: Decodable>: Decodable {
    let data: [T]
    let nextToken: String?

    enum CodingKeys: String, CodingKey {
        case data
        case nextToken = "next_token"
    }
}

struct OuraDailySleepRecord: Decodable, Equatable, Sendable {
    let id: String
    let day: String
    let bedtimeStart: String?
    let bedtimeEnd: String?
    let score: Int?
    let totalSleepDuration: Int?
    let deepSleepDuration: Int?
    let remSleepDuration: Int?
    let lightSleepDuration: Int?
    let awakeTime: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case day
        case bedtimeStart = "bedtime_start"
        case bedtimeEnd = "bedtime_end"
        case score
        case totalSleepDuration = "total_sleep_duration"
        case deepSleepDuration = "deep_sleep_duration"
        case remSleepDuration = "rem_sleep_duration"
        case lightSleepDuration = "light_sleep_duration"
        case awakeTime = "awake_time"
    }
}

struct OuraDailyReadinessRecord: Decodable, Equatable, Sendable {
    let id: String
    let day: String
    let score: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case day
        case score
    }
}

enum OuraDateParser {
    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_GB")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let internetDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let fallbackInternetDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    static func parseDay(_ value: String) -> Date? {
        dayFormatter.date(from: value)
    }

    static func parseTimestamp(_ value: String?) -> Date? {
        guard let value else {
            return nil
        }

        return internetDateFormatter.date(from: value) ?? fallbackInternetDateFormatter.date(from: value)
    }
}
