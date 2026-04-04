import XCTest
@testable import OuraInsightsCore

final class OuraAPIResponseTests: XCTestCase {
    
    let decoder = JSONDecoder()
    
    // MARK: - Daily Sleep Response Tests
    
    func testDecodeDailySleepResponse() throws {
        let json = """
        {
            "data": [
                {
                    "id": "sleep-123",
                    "day": "2024-01-15",
                    "score": 85,
                    "timestamp": "2024-01-15T08:00:00+00:00",
                    "contributors": {
                        "deep_sleep": 80,
                        "efficiency": 90,
                        "latency": 75,
                        "rem_sleep": 85,
                        "restfulness": 82,
                        "timing": 78,
                        "total_sleep": 88
                    }
                }
            ],
            "next_token": null
        }
        """.data(using: .utf8)!
        
        let response = try decoder.decode(OuraAPIResponse<DailySleepResponse>.self, from: json)
        
        XCTAssertEqual(response.data.count, 1)
        XCTAssertNil(response.nextToken)
        
        let sleep = response.data[0]
        XCTAssertEqual(sleep.id, "sleep-123")
        XCTAssertEqual(sleep.day, "2024-01-15")
        XCTAssertEqual(sleep.score, 85)
        XCTAssertEqual(sleep.contributors?.deepSleep, 80)
        XCTAssertEqual(sleep.contributors?.efficiency, 90)
    }
    
    // MARK: - Sleep Document Response Tests
    
    func testDecodeSleepDocumentResponse() throws {
        let json = """
        {
            "data": [
                {
                    "id": "doc-456",
                    "day": "2024-01-15",
                    "bedtime_start": "2024-01-14T23:30:00+00:00",
                    "bedtime_end": "2024-01-15T07:30:00+00:00",
                    "average_breath": 14.5,
                    "average_heart_rate": 58.2,
                    "average_hrv": 45,
                    "awake_time": 1800,
                    "deep_sleep_duration": 5400,
                    "efficiency": 92,
                    "latency": 600,
                    "light_sleep_duration": 14400,
                    "lowest_heart_rate": 52,
                    "rem_sleep_duration": 7200,
                    "total_sleep_duration": 27000,
                    "type": "long_sleep"
                }
            ]
        }
        """.data(using: .utf8)!
        
        let response = try decoder.decode(OuraAPIResponse<SleepDocumentResponse>.self, from: json)
        
        XCTAssertEqual(response.data.count, 1)
        
        let doc = response.data[0]
        XCTAssertEqual(doc.id, "doc-456")
        XCTAssertEqual(doc.day, "2024-01-15")
        XCTAssertEqual(doc.bedtimeStart, "2024-01-14T23:30:00+00:00")
        XCTAssertEqual(doc.bedtimeEnd, "2024-01-15T07:30:00+00:00")
        XCTAssertEqual(doc.totalSleepDuration, 27000)
        XCTAssertEqual(doc.deepSleepDuration, 5400)
        XCTAssertEqual(doc.remSleepDuration, 7200)
        XCTAssertEqual(doc.efficiency, 92)
    }
    
    // MARK: - Daily Readiness Response Tests
    
    func testDecodeDailyReadinessResponse() throws {
        let json = """
        {
            "data": [
                {
                    "id": "readiness-789",
                    "day": "2024-01-15",
                    "score": 78,
                    "temperature_deviation": 0.12,
                    "temperature_trend_deviation": 0.05,
                    "contributors": {
                        "activity_balance": 85,
                        "body_temperature": 90,
                        "hrv_balance": 72,
                        "previous_day_activity": 80,
                        "previous_night": 88,
                        "recovery_index": 75,
                        "resting_heart_rate": 82,
                        "sleep_balance": 78
                    }
                }
            ]
        }
        """.data(using: .utf8)!
        
        let response = try decoder.decode(OuraAPIResponse<DailyReadinessResponse>.self, from: json)
        
        XCTAssertEqual(response.data.count, 1)
        
        let readiness = response.data[0]
        XCTAssertEqual(readiness.id, "readiness-789")
        XCTAssertEqual(readiness.day, "2024-01-15")
        XCTAssertEqual(readiness.score, 78)
        XCTAssertEqual(readiness.temperatureDeviation ?? 0, 0.12, accuracy: 0.001)
        XCTAssertEqual(readiness.contributors?.activityBalance, 85)
        XCTAssertEqual(readiness.contributors?.hrvBalance, 72)
    }
    
    // MARK: - Daily Activity Response Tests
    
    func testDecodeDailyActivityResponse() throws {
        let json = """
        {
            "data": [
                {
                    "id": "activity-101",
                    "day": "2024-01-15",
                    "score": 92,
                    "active_calories": 450,
                    "total_calories": 2200,
                    "steps": 12500,
                    "equivalent_walking_distance": 9800,
                    "high_activity_time": 1800,
                    "medium_activity_time": 3600,
                    "low_activity_time": 7200,
                    "sedentary_time": 28800,
                    "resting_time": 18000,
                    "inactivity_alerts": 2,
                    "contributors": {
                        "meet_daily_targets": 95,
                        "move_every_hour": 88,
                        "recovery_time": 100,
                        "stay_active": 85,
                        "training_frequency": 90,
                        "training_volume": 82
                    }
                }
            ],
            "next_token": "abc123"
        }
        """.data(using: .utf8)!
        
        let response = try decoder.decode(OuraAPIResponse<DailyActivityResponse>.self, from: json)
        
        XCTAssertEqual(response.data.count, 1)
        XCTAssertEqual(response.nextToken, "abc123")
        
        let activity = response.data[0]
        XCTAssertEqual(activity.id, "activity-101")
        XCTAssertEqual(activity.day, "2024-01-15")
        XCTAssertEqual(activity.score, 92)
        XCTAssertEqual(activity.steps, 12500)
        XCTAssertEqual(activity.activeCalories, 450)
        XCTAssertEqual(activity.contributors?.meetDailyTargets, 95)
    }
    
    // MARK: - Personal Info Response Tests
    
    func testDecodePersonalInfoResponse() throws {
        let json = """
        {
            "id": "user-xyz",
            "age": 35,
            "weight": 75.5,
            "height": 180.0,
            "biological_sex": "male",
            "email": "user@example.com"
        }
        """.data(using: .utf8)!
        
        let info = try decoder.decode(PersonalInfoResponse.self, from: json)
        
        XCTAssertEqual(info.id, "user-xyz")
        XCTAssertEqual(info.age, 35)
        XCTAssertEqual(info.weight ?? 0, 75.5, accuracy: 0.1)
        XCTAssertEqual(info.height ?? 0, 180.0, accuracy: 0.1)
        XCTAssertEqual(info.biologicalSex, "male")
        XCTAssertEqual(info.email, "user@example.com")
    }
    
    // MARK: - Empty Response Tests
    
    func testDecodeEmptyDataArray() throws {
        let json = """
        {
            "data": []
        }
        """.data(using: .utf8)!
        
        let response = try decoder.decode(OuraAPIResponse<DailySleepResponse>.self, from: json)
        
        XCTAssertTrue(response.data.isEmpty)
        XCTAssertNil(response.nextToken)
    }
    
    // MARK: - Partial Data Tests
    
    func testDecodePartialSleepData() throws {
        let json = """
        {
            "data": [
                {
                    "id": "sleep-partial",
                    "day": "2024-01-15"
                }
            ]
        }
        """.data(using: .utf8)!
        
        let response = try decoder.decode(OuraAPIResponse<DailySleepResponse>.self, from: json)
        
        XCTAssertEqual(response.data.count, 1)
        let sleep = response.data[0]
        XCTAssertEqual(sleep.id, "sleep-partial")
        XCTAssertNil(sleep.score)
        XCTAssertNil(sleep.contributors)
    }
}
