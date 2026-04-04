import XCTest
@testable import OuraInsightsCore

final class SleepSessionTests: XCTestCase {
    
    func testSleepSessionCreation() {
        let session = SleepSession(
            id: "test-sleep-1",
            date: Date(),
            bedtimeStart: Date(),
            bedtimeEnd: Date().addingTimeInterval(28800),
            totalSleepDuration: 25200,
            sleepScore: 85
        )
        
        XCTAssertEqual(session.id, "test-sleep-1")
        XCTAssertEqual(session.sleepScore, 85)
        XCTAssertEqual(session.totalSleepDuration, 25200)
    }
    
    func testSleepDurationHours() throws {
        let session = SleepSession(
            id: "test-1",
            date: Date(),
            totalSleepDuration: 25200 // 7 hours
        )
        
        let hours = try XCTUnwrap(session.sleepDurationHours)
        XCTAssertEqual(hours, 7.0, accuracy: 0.01)
    }
    
    func testSleepDurationHoursNil() {
        let session = SleepSession(id: "test-2", date: Date())
        XCTAssertNil(session.sleepDurationHours)
    }
    
    func testFormattedDuration() {
        let session = SleepSession(
            id: "test-3",
            date: Date(),
            totalSleepDuration: 27900 // 7h 45m
        )
        
        XCTAssertEqual(session.formattedDuration, "7h 45m")
    }
    
    func testFormattedDurationNil() {
        let session = SleepSession(id: "test-4", date: Date())
        XCTAssertNil(session.formattedDuration)
    }
    
    func testEquatable() {
        let date = Date()
        let session1 = SleepSession(id: "same-id", date: date, sleepScore: 80)
        let session2 = SleepSession(id: "same-id", date: date, sleepScore: 80)
        
        XCTAssertEqual(session1.id, session2.id)
    }
    
    func testCodable() throws {
        let session = SleepSession(
            id: "test-encode",
            date: Date(),
            totalSleepDuration: 25200,
            sleepScore: 85
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(session)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(SleepSession.self, from: data)
        
        XCTAssertEqual(decoded.id, session.id)
        XCTAssertEqual(decoded.sleepScore, session.sleepScore)
        XCTAssertEqual(decoded.totalSleepDuration, session.totalSleepDuration)
    }
}
