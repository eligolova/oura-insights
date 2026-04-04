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
    var accessToken: String
    var refreshToken: String
    var expiresAt: Date

    init(
        userID: UUID,
        accessToken: String = "",
        refreshToken: String = "",
        expiresAt: Date = .distantPast
    ) {
        self.userID = userID
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
    }
}

@Model
final class SleepSession {
    @Attribute(.unique) var id: UUID
    var startDate: Date
    var endDate: Date
    var score: Int

    init(id: UUID = UUID(), startDate: Date, endDate: Date, score: Int = 0) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.score = score
    }
}

@Model
final class ReadinessScore {
    @Attribute(.unique) var id: UUID
    var date: Date
    var score: Int

    init(id: UUID = UUID(), date: Date, score: Int = 0) {
        self.id = id
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
