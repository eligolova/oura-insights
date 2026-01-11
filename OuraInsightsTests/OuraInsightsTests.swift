import XCTest
import SwiftData
@testable import OuraInsights

final class OuraInsightsTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    override func setUpWithError() throws {
        let schema = Schema([
            SleepSession.self,
            ReadinessScore.self,
            ActivityDay.self,
            HeartMetrics.self,
            LocationSample.self,
            WeatherSnapshot.self,
            DerivedInsight.self,
            OuraToken.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = ModelContext(modelContainer)
    }
    
    override func tearDownWithError() throws {
        modelContainer = nil
        modelContext = nil
    }
    
    // MARK: - SleepSession Tests
    
    func testSleepSessionCreation() throws {
        let session = SleepSession(
            id: "test-sleep-1",
            date: Date(),
            bedtimeStart: Date(),
            bedtimeEnd: Date().addingTimeInterval(28800),
            totalSleepDuration: 25200,
            sleepScore: 85
        )
        
        modelContext.insert(session)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<SleepSession>(
            predicate: #Predicate { $0.id == "test-sleep-1" }
        )
        let fetched = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.sleepScore, 85)
        XCTAssertEqual(fetched.first?.totalSleepDuration, 25200)
    }
    
    func testSleepSessionUniqueId() throws {
        let session1 = SleepSession(id: "unique-id", date: Date(), sleepScore: 80)
        let session2 = SleepSession(id: "unique-id", date: Date(), sleepScore: 90)
        
        modelContext.insert(session1)
        try modelContext.save()
        
        modelContext.insert(session2)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<SleepSession>(
            predicate: #Predicate { $0.id == "unique-id" }
        )
        let fetched = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(fetched.count, 1)
    }
    
    // MARK: - ReadinessScore Tests
    
    func testReadinessScoreCreation() throws {
        let readiness = ReadinessScore(
            id: "test-readiness-1",
            date: Date(),
            score: 78,
            temperatureDeviation: 0.2
        )
        
        modelContext.insert(readiness)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<ReadinessScore>(
            predicate: #Predicate { $0.id == "test-readiness-1" }
        )
        let fetched = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.score, 78)
        XCTAssertEqual(fetched.first?.temperatureDeviation, 0.2)
    }
    
    // MARK: - ActivityDay Tests
    
    func testActivityDayCreation() throws {
        let activity = ActivityDay(
            id: "test-activity-1",
            date: Date(),
            score: 85,
            activeCalories: 500,
            steps: 10000
        )
        
        modelContext.insert(activity)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<ActivityDay>(
            predicate: #Predicate { $0.id == "test-activity-1" }
        )
        let fetched = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.steps, 10000)
        XCTAssertEqual(fetched.first?.activeCalories, 500)
    }
    
    // MARK: - HeartMetrics Tests
    
    func testHeartMetricsCreation() throws {
        let metrics = HeartMetrics(
            id: "test-heart-1",
            date: Date(),
            averageHRV: 45.5,
            restingHeartRate: 58.0
        )
        
        modelContext.insert(metrics)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<HeartMetrics>(
            predicate: #Predicate { $0.id == "test-heart-1" }
        )
        let fetched = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.averageHRV, 45.5)
        XCTAssertEqual(fetched.first?.restingHeartRate, 58.0)
    }
    
    // MARK: - LocationSample Tests
    
    func testLocationSampleCreation() throws {
        let location = LocationSample(
            date: Date(),
            latitude: 51.5074,
            longitude: -0.1278,
            altitude: 11.0
        )
        
        modelContext.insert(location)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<LocationSample>()
        let fetched = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.latitude, 51.5074)
        XCTAssertEqual(fetched.first?.longitude, -0.1278)
    }
    
    // MARK: - WeatherSnapshot Tests
    
    func testWeatherSnapshotCreation() throws {
        let weather = WeatherSnapshot(
            date: Date(),
            latitude: 51.5074,
            longitude: -0.1278,
            temperatureMax: 22.0,
            temperatureMin: 14.0,
            temperatureMean: 18.0,
            humidity: 65.0
        )
        
        modelContext.insert(weather)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<WeatherSnapshot>()
        let fetched = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.temperatureMean, 18.0)
        XCTAssertEqual(fetched.first?.humidity, 65.0)
    }
    
    // MARK: - DerivedInsight Tests
    
    func testDerivedInsightCreation() throws {
        let insight = DerivedInsight(
            date: Date(),
            metricType: InsightMetricType.sleepDuration7DayAvg.rawValue,
            value: 7.5,
            period: "7d"
        )
        
        modelContext.insert(insight)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<DerivedInsight>()
        let fetched = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.value, 7.5)
        XCTAssertEqual(fetched.first?.metricType, "sleep_duration_7d_avg")
    }
    
    // MARK: - OuraToken Tests
    
    func testOuraTokenCreation() throws {
        let token = OuraToken(
            accessToken: "test-access-token",
            refreshToken: "test-refresh-token",
            expiresAt: Date().addingTimeInterval(3600)
        )
        
        modelContext.insert(token)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<OuraToken>()
        let fetched = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.accessToken, "test-access-token")
        XCTAssertFalse(fetched.first?.isExpired ?? true)
    }
    
    func testOuraTokenExpiration() throws {
        let expiredToken = OuraToken(
            accessToken: "expired-token",
            expiresAt: Date().addingTimeInterval(-3600)
        )
        
        XCTAssertTrue(expiredToken.isExpired)
        
        let validToken = OuraToken(
            accessToken: "valid-token",
            expiresAt: Date().addingTimeInterval(3600)
        )
        
        XCTAssertFalse(validToken.isExpired)
    }
}
