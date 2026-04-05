import SwiftData
import XCTest
@testable import OuraInsightsFeature

final class AppContainerTests: XCTestCase {
    func testCreatesInMemorySwiftDataContainerWithExpectedSchema() throws {
        let container = AppContainer.makeModelContainer(isStoredInMemoryOnly: true)
        let context = ModelContext(container)
        let session = SleepSession(
            sourceRecordID: "sleep_1",
            day: .now,
            startDate: .now.addingTimeInterval(-28_800),
            endDate: .now,
            totalSleepSeconds: 28_800,
            score: 85
        )

        context.insert(session)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<SleepSession>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.score, 85)
    }
}
