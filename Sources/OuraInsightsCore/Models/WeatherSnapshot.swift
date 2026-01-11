import Foundation

public struct WeatherSnapshot: Identifiable, Codable, Equatable {
    public let id: String
    public var date: Date
    public var latitude: Double
    public var longitude: Double
    public var temperatureMax: Double?
    public var temperatureMin: Double?
    public var temperatureMean: Double?
    public var humidity: Double?
    public var precipitation: Double?
    public var windSpeedMax: Double?
    public var pressure: Double?
    public var createdAt: Date
    
    public init(
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
    
    public var temperatureRange: Double? {
        guard let max = temperatureMax, let min = temperatureMin else { return nil }
        return max - min
    }
    
    public var formattedTemperature: String {
        guard let temp = temperatureMean else { return "—" }
        return String(format: "%.1f°C", temp)
    }
    
    public var weatherCondition: WeatherCondition {
        if let precipitation = precipitation, precipitation > 0 {
            return precipitation > 5 ? .rainy : .lightRain
        }
        if let humidity = humidity, humidity > 80 {
            return .humid
        }
        if let temp = temperatureMean {
            if temp > 25 { return .hot }
            if temp < 5 { return .cold }
        }
        return .moderate
    }
}

public enum WeatherCondition: String, Codable {
    case hot = "Hot"
    case moderate = "Moderate"
    case cold = "Cold"
    case rainy = "Rainy"
    case lightRain = "Light Rain"
    case humid = "Humid"
}
