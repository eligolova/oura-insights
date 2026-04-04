import SwiftData
import Foundation

final class PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer

    init() {
        let schema = Schema([
            SleepSession.self,
            ReadinessScore.self,
            ActivityDay.self,
            HeartMetrics.self,
            LocationSample.self,
            WeatherSnapshot.self,
        ])
        do {
            container = try ModelContainer(for: schema)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
