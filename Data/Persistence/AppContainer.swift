import Foundation
import SwiftData

@Observable
final class AppContainer {
    static let shared = AppContainer()

    let modelContainer: ModelContainer
    let appShellViewModel: AppShellViewModel

    init(
        modelContainer: ModelContainer = AppContainer.makeModelContainer(),
        appShellViewModel: AppShellViewModel = AppShellViewModel()
    ) {
        self.modelContainer = modelContainer
        self.appShellViewModel = appShellViewModel
    }

    static var schema: Schema {
        Schema([
            User.self,
            OuraToken.self,
            SleepSession.self,
            ReadinessScore.self,
            ActivityDay.self,
            HeartMetrics.self,
            LocationSample.self,
            WeatherSnapshot.self,
            DerivedInsight.self
        ])
    }

    static func makeModelContainer(isStoredInMemoryOnly: Bool = false) -> ModelContainer {
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
