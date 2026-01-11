import XCTest
@testable import OuraInsightsCore

final class ReadinessScoreTests: XCTestCase {
    
    func testReadinessScoreCreation() {
        let readiness = ReadinessScore(
            id: "test-readiness-1",
            date: Date(),
            score: 78,
            temperatureDeviation: 0.2
        )
        
        XCTAssertEqual(readiness.id, "test-readiness-1")
        XCTAssertEqual(readiness.score, 78)
        XCTAssertEqual(readiness.temperatureDeviation, 0.2)
    }
    
    func testScoreCategoryOptimal() {
        let readiness = ReadinessScore(id: "test-1", date: Date(), score: 90)
        XCTAssertEqual(readiness.scoreCategory, .optimal)
    }
    
    func testScoreCategoryGood() {
        let readiness = ReadinessScore(id: "test-2", date: Date(), score: 75)
        XCTAssertEqual(readiness.scoreCategory, .good)
    }
    
    func testScoreCategoryPayAttention() {
        let readiness = ReadinessScore(id: "test-3", date: Date(), score: 60)
        XCTAssertEqual(readiness.scoreCategory, .payAttention)
    }
    
    func testScoreCategoryTakeItEasy() {
        let readiness = ReadinessScore(id: "test-4", date: Date(), score: 40)
        XCTAssertEqual(readiness.scoreCategory, .takeItEasy)
    }
    
    func testScoreCategoryUnknown() {
        let readiness = ReadinessScore(id: "test-5", date: Date())
        XCTAssertEqual(readiness.scoreCategory, .unknown)
    }
    
    func testCodable() throws {
        let readiness = ReadinessScore(
            id: "test-encode",
            date: Date(),
            score: 85,
            temperatureDeviation: 0.15
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(readiness)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ReadinessScore.self, from: data)
        
        XCTAssertEqual(decoded.id, readiness.id)
        XCTAssertEqual(decoded.score, readiness.score)
        XCTAssertEqual(decoded.temperatureDeviation, readiness.temperatureDeviation)
    }
}
