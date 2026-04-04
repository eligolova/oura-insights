// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "OuraInsightsPackage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "OuraInsightsFeature",
            targets: ["OuraInsightsFeature"]
        )
    ],
    targets: [
        .target(
            name: "OuraInsightsFeature",
            path: ".",
            exclude: [
                ".build",
                ".git",
                "App/AppEntry",
                "Scripts",
                "Tests",
                "README.md",
                "spec.md",
                "project.yml"
            ],
            sources: [
                "App/Views",
                "App/ViewModels",
                "App/Charts",
                "Data/Models",
                "Data/Persistence",
                "Data/Importers",
                "Data/Normalisation",
                "Services/OuraClient",
                "Services/WeatherClient",
                "Services/LocationService",
                "Analysis/Metrics",
                "Analysis/Correlations"
            ]
        ),
        .testTarget(
            name: "OuraInsightsTests",
            dependencies: ["OuraInsightsFeature"],
            path: "Tests/OuraInsightsTests"
        )
    ]
)
