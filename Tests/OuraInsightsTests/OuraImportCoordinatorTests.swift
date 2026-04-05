import SwiftData
import XCTest
@testable import OuraInsightsFeature

final class OuraImportCoordinatorTests: XCTestCase {
    func testRefreshImportsRawAndNormalisedRecordsIdempotently() async throws {
        let container = AppContainer.makeModelContainer(isStoredInMemoryOnly: true)
        let tokenStore = InMemoryOuraTokenStore()
        try tokenStore.save(
            OuraSessionToken(
                accessToken: "token",
                refreshToken: nil,
                tokenType: "bearer",
                scopes: ["daily"],
                expiresAt: .now.addingTimeInterval(3600)
            )
        )
        let client = StubOuraClient()
        let coordinator = OuraImportCoordinator(
            client: client,
            normalisationPipeline: NormalisationPipeline(),
            tokenStore: tokenStore
        )

        try await coordinator.refresh(modelContainer: container, today: referenceDate)
        try await coordinator.refresh(modelContainer: container, today: referenceDate)

        let context = ModelContext(container)
        XCTAssertEqual(try context.fetch(FetchDescriptor<RawOuraSleepRecord>()).count, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<RawOuraReadinessRecord>()).count, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<SleepSession>()).count, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<ReadinessScore>()).count, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<SleepSession>()).first?.score, 84)
        XCTAssertEqual(try context.fetch(FetchDescriptor<ReadinessScore>()).first?.score, 79)
    }

    private var referenceDate: Date {
        Date(timeIntervalSince1970: 1_710_000_000)
    }
}

private struct StubOuraClient: OuraAPIClient {
    func fetchDailySleep(accessToken: String, startDate: Date, endDate: Date) async throws -> [OuraDailySleepRecord] {
        [
            OuraDailySleepRecord(
                id: "sleep-day-1",
                day: "2026-04-04",
                bedtimeStart: "2026-04-03T22:30:00Z",
                bedtimeEnd: "2026-04-04T06:30:00Z",
                score: 84,
                totalSleepDuration: 28_800,
                deepSleepDuration: 4_200,
                remSleepDuration: 6_000,
                lightSleepDuration: 16_800,
                awakeTime: 1_800
            )
        ]
    }

    func fetchDailyReadiness(accessToken: String, startDate: Date, endDate: Date) async throws -> [OuraDailyReadinessRecord] {
        [
            OuraDailyReadinessRecord(
                id: "readiness-day-1",
                day: "2026-04-04",
                score: 79
            )
        ]
    }
}
