import XCTest
@testable import OuraInsightsCore

final class OuraAPIResponseTests: XCTestCase {
    
    func testDailySleepDataDecoding() throws {
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
                        "rem_sleep": 82,
                        "restfulness": 88,
                        "timing": 70,
                        "total_sleep": 85
                    }
                }
            ],
            "next_token": null
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(DailySleepResponse.self, from: json)
        
        XCTAssertEqual(response.data.count, 1)
        XCTAssertNil(response.nextToken)
        
        let sleepData = response.data[0]
        XCTAssertEqual(sleepData.id, "sleep-123")
        XCTAssertEqual(sleepData.day, "2024-01-15")
        XCTAssertEqual(sleepData.score, 85)
        XCTAssertNotNil(sleepData.contributors)
        XCTAssertEqual(sleepData.contributors?.deepSleep, 80)
        XCTAssertEqual(sleepData.contributors?.efficiency, 90)
    }
    
    func testDailySleepDataDayDate() throws {
        let json = """
        {
            "data": [
                {
                    "id": "sleep-123",
                    "day": "2024-01-15",
                    "score": 85
                }
            ]
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(DailySleepResponse.self, from: json)
        
        let sleepData = response.data[0]
        XCTAssertNotNil(sleepData.dayDate)
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: sleepData.dayDate!)
        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 1)
        XCTAssertEqual(components.day, 15)
    }
    
    func testDailyReadinessDataDecoding() throws {
        let json = """
        {
            "data": [
                {
                    "id": "readiness-456",
                    "day": "2024-01-15",
                    "score": 78,
                    "temperature_deviation": 0.15,
                    "temperature_trend_deviation": 0.05,
                    "contributors": {
                        "activity_balance": 80,
                        "body_temperature": 85,
                        "hrv_balance": 72,
                        "previous_day_activity": 90,
                        "previous_night": 75,
                        "recovery_index": 88,
                        "resting_heart_rate": 82,
                        "sleep_balance": 70
                    }
                }
            ],
            "next_token": "abc123"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(DailyReadinessResponse.self, from: json)
        
        XCTAssertEqual(response.data.count, 1)
        XCTAssertEqual(response.nextToken, "abc123")
        
        let readinessData = response.data[0]
        XCTAssertEqual(readinessData.id, "readiness-456")
        XCTAssertEqual(readinessData.score, 78)
        XCTAssertEqual(readinessData.temperatureDeviation!, 0.15, accuracy: 0.001)
        XCTAssertNotNil(readinessData.contributors)
        XCTAssertEqual(readinessData.contributors?.hrvBalance, 72)
    }
    
    func testDailyActivityDataDecoding() throws {
        let json = """
        {
            "data": [
                {
                    "id": "activity-789",
                    "day": "2024-01-15",
                    "score": 92,
                    "active_calories": 450,
                    "total_calories": 2200,
                    "steps": 10500,
                    "equivalent_walking_distance": 8500,
                    "high_activity_time": 1800,
                    "medium_activity_time": 3600,
                    "low_activity_time": 7200,
                    "sedentary_time": 28800,
                    "resting_time": 36000,
                    "inactivity_alerts": 2,
                    "contributors": {
                        "meet_daily_targets": 95,
                        "move_every_hour": 80,
                        "recovery_time": 85,
                        "stay_active": 90,
                        "training_frequency": 75,
                        "training_volume": 88
                    }
                }
            ]
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(DailyActivityResponse.self, from: json)
        
        XCTAssertEqual(response.data.count, 1)
        
        let activityData = response.data[0]
        XCTAssertEqual(activityData.id, "activity-789")
        XCTAssertEqual(activityData.score, 92)
        XCTAssertEqual(activityData.steps, 10500)
        XCTAssertEqual(activityData.activeCalories, 450)
        XCTAssertEqual(activityData.highActivityTime, 1800)
        XCTAssertNotNil(activityData.contributors)
        XCTAssertEqual(activityData.contributors?.meetDailyTargets, 95)
    }
    
    func testHeartRateDataDecoding() throws {
        let json = """
        {
            "data": [
                {
                    "bpm": 72,
                    "source": "awake",
                    "timestamp": "2024-01-15T10:30:00+00:00"
                },
                {
                    "bpm": 58,
                    "source": "rest",
                    "timestamp": "2024-01-15T03:15:00+00:00"
                }
            ]
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(HeartRateResponse.self, from: json)
        
        XCTAssertEqual(response.data.count, 2)
        
        XCTAssertEqual(response.data[0].bpm, 72)
        XCTAssertEqual(response.data[0].source, "awake")
        XCTAssertEqual(response.data[1].bpm, 58)
        XCTAssertEqual(response.data[1].source, "rest")
    }
    
    func testSleepSessionDataDecoding() throws {
        let json = """
        {
            "data": [
                {
                    "id": "session-abc",
                    "day": "2024-01-15",
                    "bedtime_start": "2024-01-14T23:30:00+00:00",
                    "bedtime_end": "2024-01-15T07:15:00+00:00",
                    "total_sleep_duration": 25200,
                    "awake_time": 1800,
                    "rem_sleep_duration": 5400,
                    "light_sleep_duration": 12600,
                    "deep_sleep_duration": 7200,
                    "efficiency": 93,
                    "latency": 600,
                    "type": "long_sleep"
                }
            ]
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(SleepSessionResponse.self, from: json)
        
        XCTAssertEqual(response.data.count, 1)
        
        let sessionData = response.data[0]
        XCTAssertEqual(sessionData.id, "session-abc")
        XCTAssertEqual(sessionData.totalSleepDuration, 25200)
        XCTAssertEqual(sessionData.efficiency, 93)
        XCTAssertEqual(sessionData.type, "long_sleep")
        XCTAssertNotNil(sessionData.bedtimeStartDate)
        XCTAssertNotNil(sessionData.bedtimeEndDate)
    }
    
    func testEmptyResponseDecoding() throws {
        let json = """
        {
            "data": []
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(DailySleepResponse.self, from: json)
        
        XCTAssertTrue(response.data.isEmpty)
        XCTAssertNil(response.nextToken)
    }
    
    func testPartialDataDecoding() throws {
        let json = """
        {
            "data": [
                {
                    "id": "partial-123",
                    "day": "2024-01-15"
                }
            ]
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(DailySleepResponse.self, from: json)
        
        XCTAssertEqual(response.data.count, 1)
        XCTAssertEqual(response.data[0].id, "partial-123")
        XCTAssertNil(response.data[0].score)
        XCTAssertNil(response.data[0].contributors)
    }
}
