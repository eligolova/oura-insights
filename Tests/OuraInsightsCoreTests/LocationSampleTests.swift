import XCTest
@testable import OuraInsightsCore

final class LocationSampleTests: XCTestCase {
    
    func testLocationSampleCreation() {
        let location = LocationSample(
            date: Date(),
            latitude: 51.5074,
            longitude: -0.1278,
            altitude: 11.0
        )
        
        XCTAssertEqual(location.latitude, 51.5074, accuracy: 0.0001)
        XCTAssertEqual(location.longitude, -0.1278, accuracy: 0.0001)
        XCTAssertEqual(location.altitude, 11.0)
    }
    
    func testReducedPrecision() {
        let location = LocationSample(
            date: Date(),
            latitude: 51.507456789,
            longitude: -0.127856789
        )
        
        XCTAssertEqual(location.reducedPrecisionLatitude, 51.51, accuracy: 0.001)
        XCTAssertEqual(location.reducedPrecisionLongitude, -0.13, accuracy: 0.001)
    }
    
    func testDistanceCalculation() {
        let london = LocationSample(date: Date(), latitude: 51.5074, longitude: -0.1278)
        let paris = LocationSample(date: Date(), latitude: 48.8566, longitude: 2.3522)
        
        let distance = london.distance(to: paris)
        
        // London to Paris is approximately 344 km
        XCTAssertEqual(distance, 344, accuracy: 5)
    }
    
    func testDistanceSameLocation() {
        let location1 = LocationSample(date: Date(), latitude: 51.5074, longitude: -0.1278)
        let location2 = LocationSample(date: Date(), latitude: 51.5074, longitude: -0.1278)
        
        let distance = location1.distance(to: location2)
        
        XCTAssertEqual(distance, 0, accuracy: 0.001)
    }
    
    func testCodable() throws {
        let location = LocationSample(
            date: Date(),
            latitude: 51.5074,
            longitude: -0.1278
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(location)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(LocationSample.self, from: data)
        
        XCTAssertEqual(decoded.latitude, location.latitude, accuracy: 0.0001)
        XCTAssertEqual(decoded.longitude, location.longitude, accuracy: 0.0001)
    }
}
