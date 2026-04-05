import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var createdAt: Date

    init(id: UUID = UUID(), createdAt: Date = .now) {
        self.id = id
        self.createdAt = createdAt
    }
}

@Model
final class OuraToken {
    @Attribute(.unique) var userID: UUID
    var keychainAccount: String
    var scopeSummary: String
    var tokenType: String
    var expiresAt: Date
    var lastSyncedAt: Date?
    var updatedAt: Date

    init(
        userID: UUID,
        keychainAccount: String = "default",
        scopeSummary: String = "",
        tokenType: String = "bearer",
        expiresAt: Date = .distantPast,
        lastSyncedAt: Date? = nil,
        updatedAt: Date = .now
    ) {
        self.userID = userID
        self.keychainAccount = keychainAccount
        self.scopeSummary = scopeSummary
        self.tokenType = tokenType
        self.expiresAt = expiresAt
        self.lastSyncedAt = lastSyncedAt
        self.updatedAt = updatedAt
    }
}

@Model
final class SleepSession {
    @Attribute(.unique) var sourceRecordID: String
    var day: Date
    var startDate: Date
    var endDate: Date
    var totalSleepSeconds: Int
    var score: Int

    init(
        sourceRecordID: String,
        day: Date,
        startDate: Date,
        endDate: Date,
        totalSleepSeconds: Int = 0,
        score: Int = 0
    ) {
        self.sourceRecordID = sourceRecordID
        self.day = day
        self.startDate = startDate
        self.endDate = endDate
        self.totalSleepSeconds = totalSleepSeconds
        self.score = score
    }
}

@Model
final class ReadinessScore {
    @Attribute(.unique) var sourceRecordID: String
    var date: Date
    var score: Int

    init(sourceRecordID: String, date: Date, score: Int = 0) {
        self.sourceRecordID = sourceRecordID
        self.date = date
        self.score = score
    }
}

@Model
final class ActivityDay {
    @Attribute(.unique) var date: Date
    var steps: Int
    var calories: Double

    init(date: Date, steps: Int = 0, calories: Double = 0) {
        self.date = date
        self.steps = steps
        self.calories = calories
    }
}

@Model
final class HeartMetrics {
    @Attribute(.unique) var date: Date
    var restingHeartRate: Double
    var hrv: Double
    var temperatureDeviation: Double

    init(date: Date, restingHeartRate: Double = 0, hrv: Double = 0, temperatureDeviation: Double = 0) {
        self.date = date
        self.restingHeartRate = restingHeartRate
        self.hrv = hrv
        self.temperatureDeviation = temperatureDeviation
    }
}

@Model
final class LocationSample {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var latitude: Double
    var longitude: Double

    init(id: UUID = UUID(), timestamp: Date, latitude: Double, longitude: Double) {
        self.id = id
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
    }
}

@Model
final class WeatherSnapshot {
    @Attribute(.unique) var id: UUID
    var date: Date
    var latitude: Double
    var longitude: Double
    var temperatureCelsius: Double
    var humidityPercent: Double
    var precipitationMillimeters: Double
    var windSpeedKph: Double
    var pressureHPa: Double

    init(
        id: UUID = UUID(),
        date: Date,
        latitude: Double,
        longitude: Double,
        temperatureCelsius: Double = 0,
        humidityPercent: Double = 0,
        precipitationMillimeters: Double = 0,
        windSpeedKph: Double = 0,
        pressureHPa: Double = 0
    ) {
        self.id = id
        self.date = date
        self.latitude = latitude
        self.longitude = longitude
        self.temperatureCelsius = temperatureCelsius
        self.humidityPercent = humidityPercent
        self.precipitationMillimeters = precipitationMillimeters
        self.windSpeedKph = windSpeedKph
        self.pressureHPa = pressureHPa
    }
}

@Model
final class DerivedInsight {
    @Attribute(.unique) var id: UUID
    var generatedAt: Date
    var title: String
    var summary: String

    init(id: UUID = UUID(), generatedAt: Date = .now, title: String, summary: String) {
        self.id = id
        self.generatedAt = generatedAt
        self.title = title
        self.summary = summary
    }
}

@Model
final class RawOuraSleepRecord {
    @Attribute(.unique) var ouraID: String
    var day: Date
    var bedtimeStart: Date?
    var bedtimeEnd: Date?
    var totalSleepSeconds: Int
    var deepSleepSeconds: Int
    var remSleepSeconds: Int
    var lightSleepSeconds: Int
    var awakeSeconds: Int
    var score: Int
    var importedAt: Date

    init(
        ouraID: String,
        day: Date,
        bedtimeStart: Date? = nil,
        bedtimeEnd: Date? = nil,
        totalSleepSeconds: Int = 0,
        deepSleepSeconds: Int = 0,
        remSleepSeconds: Int = 0,
        lightSleepSeconds: Int = 0,
        awakeSeconds: Int = 0,
        score: Int = 0,
        importedAt: Date = .now
    ) {
        self.ouraID = ouraID
        self.day = day
        self.bedtimeStart = bedtimeStart
        self.bedtimeEnd = bedtimeEnd
        self.totalSleepSeconds = totalSleepSeconds
        self.deepSleepSeconds = deepSleepSeconds
        self.remSleepSeconds = remSleepSeconds
        self.lightSleepSeconds = lightSleepSeconds
        self.awakeSeconds = awakeSeconds
        self.score = score
        self.importedAt = importedAt
    }
}

@Model
final class RawOuraReadinessRecord {
    @Attribute(.unique) var ouraID: String
    var day: Date
    var score: Int
    var importedAt: Date

    init(
        ouraID: String,
        day: Date,
        score: Int = 0,
        importedAt: Date = .now
    ) {
        self.ouraID = ouraID
        self.day = day
        self.score = score
        self.importedAt = importedAt
    }
}
