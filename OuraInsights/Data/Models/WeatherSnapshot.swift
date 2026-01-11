import Foundation
import SwiftData

@Model
final class WeatherSnapshot {
    @Attribute(.unique) var id: String
    var date: Date
    var latitude: Double
    var longitude: Double
    var temperatureMax: Double?
    var temperatureMin: Double?
    var temperatureMean: Double?
    var humidity: Double?
    var precipitation: Double?
    var windSpeedMax: Double?
    var pressure: Double?
    var createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        date: Date,
        latitude: Double,
        longitude: Double,
        temperatureMax: Double? = nil,
        temperatureMin: Double? = nil,
        temperatureMean: Double? = nil,
        humidity: Double? = nil,
        precipitation: Double? = nil,
        windSpeedMax: Double? = nil,
        pressure: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.latitude = latitude
        self.longitude = longitude
        self.temperatureMax = temperatureMax
        self.temperatureMin = temperatureMin
        self.temperatureMean = temperatureMean
        self.humidity = humidity
        self.precipitation = precipitation
        self.windSpeedMax = windSpeedMax
        self.pressure = pressure
        self.createdAt = Date()
    }
}
