import XCTest
@testable import OuraInsightsFeature

final class AppShellViewModelTests: XCTestCase {
    func testDefaultsToDashboardSelection() {
        let viewModel = AppShellViewModel()

        XCTAssertEqual(viewModel.selectedDestination, .dashboard)
    }

    func testExposesAllNavigationDestinationsInOrder() {
        let viewModel = AppShellViewModel()

        XCTAssertEqual(viewModel.destinations, [.dashboard, .trends, .explore, .settings])
    }
}
