import XCTest
@testable import OuraInsightsCore

final class HeartMetricsTests: XCTestCase {
    
    func testHeartMetricsCreation() {
        let metrics = HeartMetrics(
            id: "test-heart-1",
            date: Date(),
            averageHRV: 45.5,
            restingHeartRate: 58.0
        )
        
        XCTAssertEqual(metrics.id, "test-heart-1")
        XCTAssertEqual(metrics.averageHRV, 45.5)
        XCTAssertEqual(metrics.restingHeartRate, 58.0)
    }
    
    func testHRVCategoryHigh() {
        let metrics = HeartMetrics(id: "test-1", date: Date(), averageHRV: 60.0)
        XCTAssertEqual(metrics.hrvCategory, .high)
    }
    
    func testHRVCategoryModerate() {
        let metrics = HeartMetrics(id: "test-2", date: Date(), averageHRV: 40.0)
        XCTAssertEqual(metrics.hrvCategory, .moderate)
    }
    
    func testHRVCategoryLow() {
        let metrics = HeartMetrics(id: "test-3", date: Date(), averageHRV: 20.0)
        XCTAssertEqual(metrics.hrvCategory, .low)
    }
    
    func testHRVCategoryUnknown() {
        let metrics = HeartMetrics(id: "test-4", date: Date())
        XCTAssertEqual(metrics.hrvCategory, .unknown)
    }
    
    func testCodable() throws {
        let metrics = HeartMetrics(
            id: "test-encode",
            date: Date(),
            averageHRV: 45.0,
            restingHeartRate: 60.0
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(metrics)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(HeartMetrics.self, from: data)
        
        XCTAssertEqual(decoded.id, metrics.id)
        XCTAssertEqual(decoded.averageHRV, metrics.averageHRV)
        XCTAssertEqual(decoded.restingHeartRate, metrics.restingHeartRate)
    }
}
