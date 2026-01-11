// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OuraInsights",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "OuraInsightsCore",
            targets: ["OuraInsightsCore"]
        )
    ],
    targets: [
        .target(
            name: "OuraInsightsCore",
            dependencies: [],
            path: "Sources/OuraInsightsCore"
        ),
        .testTarget(
            name: "OuraInsightsCoreTests",
            dependencies: ["OuraInsightsCore"],
            path: "Tests/OuraInsightsCoreTests"
        )
    ]
)
