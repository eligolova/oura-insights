import XCTest
@testable import OuraInsightsCore

final class DerivedInsightTests: XCTestCase {
    
    func testDerivedInsightCreation() {
        let insight = DerivedInsight(
            date: Date(),
            metricType: "sleep_duration_7d_avg",
            value: 7.5,
            period: "7d"
        )
        
        XCTAssertEqual(insight.metricType, "sleep_duration_7d_avg")
        XCTAssertEqual(insight.value, 7.5)
        XCTAssertEqual(insight.period, "7d")
    }
    
    func testDerivedInsightWithEnum() {
        let insight = DerivedInsight(
            date: Date(),
            metricType: .sleepDuration7DayAvg,
            value: 7.5
        )
        
        XCTAssertEqual(insight.metricType, InsightMetricType.sleepDuration7DayAvg.rawValue)
    }
    
    func testInsightMetricTypeDisplayName() {
        XCTAssertEqual(InsightMetricType.sleepDuration7DayAvg.displayName, "7-Day Sleep Average")
        XCTAssertEqual(InsightMetricType.hrv30DayAvg.displayName, "30-Day HRV Average")
        XCTAssertEqual(InsightMetricType.sleepConsistencyScore.displayName, "Sleep Consistency")
    }
    
    func testAllMetricTypes() {
        XCTAssertEqual(InsightMetricType.allCases.count, 9)
    }
    
    func testCodable() throws {
        let insight = DerivedInsight(
            date: Date(),
            metricType: .hrvLocationVariance,
            value: 0.75
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(insight)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DerivedInsight.self, from: data)
        
        XCTAssertEqual(decoded.metricType, insight.metricType)
        XCTAssertEqual(decoded.value, insight.value)
    }
}
