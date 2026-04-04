import SwiftData
import Foundation

@Model
final class WeatherSnapshot {
    @Attribute(.unique) var id: String
    var date: Date
    var temperatureCelsius: Double?
    var humidity: Double?
    var precipitationMM: Double?
    var windSpeedKmh: Double?
    var pressureHpa: Double?

    init(
        id: String,
        date: Date,
        temperatureCelsius: Double? = nil,
        humidity: Double? = nil,
        precipitationMM: Double? = nil,
        windSpeedKmh: Double? = nil,
        pressureHpa: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.temperatureCelsius = temperatureCelsius
        self.humidity = humidity
        self.precipitationMM = precipitationMM
        self.windSpeedKmh = windSpeedKmh
        self.pressureHpa = pressureHpa
    }
}
