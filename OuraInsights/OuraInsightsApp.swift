import SwiftUI
import SwiftData

@main
struct OuraInsightsApp: App {
    let modelContainer: ModelContainer
    @State private var ouraManager = OuraManager()
    
    init() {
        print("🚀 Oura Insights App initializing...")
        do {
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
                isStoredInMemoryOnly: false
            )
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            print("✅ SwiftData ModelContainer initialized successfully")
        } catch {
            print("❌ FATAL: Could not initialize ModelContainer: \(error)")
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(ouraManager)
        }
        .modelContainer(modelContainer)
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1000, height: 700)
        #endif
    }
}
