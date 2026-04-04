import XCTest
@testable import OuraInsightsCore

final class ActivityDayTests: XCTestCase {
    
    func testActivityDayCreation() {
        let activity = ActivityDay(
            id: "test-activity-1",
            date: Date(),
            score: 85,
            activeCalories: 500,
            steps: 10000
        )
        
        XCTAssertEqual(activity.id, "test-activity-1")
        XCTAssertEqual(activity.score, 85)
        XCTAssertEqual(activity.steps, 10000)
        XCTAssertEqual(activity.activeCalories, 500)
    }
    
    func testFormattedSteps() {
        let activity = ActivityDay(id: "test-1", date: Date(), steps: 12345)
        XCTAssertEqual(activity.formattedSteps, "12,345")
    }
    
    func testFormattedStepsNil() {
        let activity = ActivityDay(id: "test-2", date: Date())
        XCTAssertEqual(activity.formattedSteps, "—")
    }
    
    func testTotalActiveMinutes() {
        let activity = ActivityDay(
            id: "test-3",
            date: Date(),
            highActivityTime: 1800,    // 30 min in seconds
            mediumActivityTime: 2700,  // 45 min
            lowActivityTime: 3600      // 60 min
        )
        
        XCTAssertEqual(activity.totalActiveMinutes, 135)
    }
    
    func testTotalActiveMinutesNil() {
        let activity = ActivityDay(id: "test-4", date: Date(), highActivityTime: 1800)
        XCTAssertNil(activity.totalActiveMinutes)
    }
    
    func testCodable() throws {
        let activity = ActivityDay(
            id: "test-encode",
            date: Date(),
            activeCalories: 500,
            steps: 10000
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(activity)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ActivityDay.self, from: data)
        
        XCTAssertEqual(decoded.id, activity.id)
        XCTAssertEqual(decoded.steps, activity.steps)
        XCTAssertEqual(decoded.activeCalories, activity.activeCalories)
    }
}
