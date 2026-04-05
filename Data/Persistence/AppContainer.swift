import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class AppContainer {
    static let shared = AppContainer()

    let modelContainer: ModelContainer
    let appShellViewModel: AppShellViewModel
    let ouraSessionViewModel: OuraSessionViewModel

    init(
        modelContainer: ModelContainer = AppContainer.makeModelContainer(),
        appShellViewModel: AppShellViewModel = AppShellViewModel(),
        ouraSessionViewModel: OuraSessionViewModel? = nil
    ) {
        self.modelContainer = modelContainer
        self.appShellViewModel = appShellViewModel
        self.ouraSessionViewModel = ouraSessionViewModel ?? OuraSessionViewModel(modelContainer: modelContainer)
    }

    nonisolated static var schema: Schema {
        Schema([
            User.self,
            OuraToken.self,
            SleepSession.self,
            ReadinessScore.self,
            RawOuraSleepRecord.self,
            RawOuraReadinessRecord.self,
            ActivityDay.self,
            HeartMetrics.self,
            LocationSample.self,
            WeatherSnapshot.self,
            DerivedInsight.self
        ])
    }

    nonisolated static func makeModelContainer(isStoredInMemoryOnly: Bool = false) -> ModelContainer {
        let configuration = ModelConfiguration(
            "OuraInsights",
            schema: schema,
            isStoredInMemoryOnly: isStoredInMemoryOnly
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Unable to create SwiftData container: \(error)")
        }
    }
}
