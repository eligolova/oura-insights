import XCTest
@testable import OuraInsightsCore

final class WeatherSnapshotTests: XCTestCase {
    
    func testWeatherSnapshotCreation() {
        let weather = WeatherSnapshot(
            date: Date(),
            latitude: 51.5074,
            longitude: -0.1278,
            temperatureMax: 22.0,
            temperatureMin: 14.0,
            temperatureMean: 18.0,
            humidity: 65.0
        )
        
        XCTAssertEqual(weather.temperatureMax, 22.0)
        XCTAssertEqual(weather.temperatureMin, 14.0)
        XCTAssertEqual(weather.temperatureMean, 18.0)
        XCTAssertEqual(weather.humidity, 65.0)
    }
    
    func testTemperatureRange() {
        let weather = WeatherSnapshot(
            date: Date(),
            latitude: 0,
            longitude: 0,
            temperatureMax: 25.0,
            temperatureMin: 15.0
        )
        
        XCTAssertEqual(weather.temperatureRange, 10.0)
    }
    
    func testTemperatureRangeNil() {
        let weather = WeatherSnapshot(date: Date(), latitude: 0, longitude: 0, temperatureMax: 25.0)
        XCTAssertNil(weather.temperatureRange)
    }
    
    func testFormattedTemperature() {
        let weather = WeatherSnapshot(
            date: Date(),
            latitude: 0,
            longitude: 0,
            temperatureMean: 18.5
        )
        
        XCTAssertEqual(weather.formattedTemperature, "18.5°C")
    }
    
    func testFormattedTemperatureNil() {
        let weather = WeatherSnapshot(date: Date(), latitude: 0, longitude: 0)
        XCTAssertEqual(weather.formattedTemperature, "—")
    }
    
    func testWeatherConditionRainy() {
        let weather = WeatherSnapshot(date: Date(), latitude: 0, longitude: 0, precipitation: 10.0)
        XCTAssertEqual(weather.weatherCondition, .rainy)
    }
    
    func testWeatherConditionLightRain() {
        let weather = WeatherSnapshot(date: Date(), latitude: 0, longitude: 0, precipitation: 2.0)
        XCTAssertEqual(weather.weatherCondition, .lightRain)
    }
    
    func testWeatherConditionHumid() {
        let weather = WeatherSnapshot(date: Date(), latitude: 0, longitude: 0, humidity: 85.0)
        XCTAssertEqual(weather.weatherCondition, .humid)
    }
    
    func testWeatherConditionHot() {
        let weather = WeatherSnapshot(date: Date(), latitude: 0, longitude: 0, temperatureMean: 30.0)
        XCTAssertEqual(weather.weatherCondition, .hot)
    }
    
    func testWeatherConditionCold() {
        let weather = WeatherSnapshot(date: Date(), latitude: 0, longitude: 0, temperatureMean: 0.0)
        XCTAssertEqual(weather.weatherCondition, .cold)
    }
    
    func testWeatherConditionModerate() {
        let weather = WeatherSnapshot(date: Date(), latitude: 0, longitude: 0, temperatureMean: 18.0)
        XCTAssertEqual(weather.weatherCondition, .moderate)
    }
    
    func testCodable() throws {
        let weather = WeatherSnapshot(
            date: Date(),
            latitude: 51.5074,
            longitude: -0.1278,
            temperatureMean: 18.0
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(weather)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(WeatherSnapshot.self, from: data)
        
        XCTAssertEqual(decoded.temperatureMean, weather.temperatureMean)
    }
}
