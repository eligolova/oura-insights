import XCTest
@testable import OuraInsightsCore

final class OuraAPIClientTests: XCTestCase {
    
    var apiClient: OuraAPIClient!
    
    override func setUp() {
        super.setUp()
        apiClient = OuraAPIClient()
    }
    
    override func tearDown() {
        apiClient = nil
        super.tearDown()
    }
    
    // MARK: - Token Management Tests
    
    func testSetToken() {
        apiClient.setToken("test-token-123")
        XCTAssertTrue(apiClient.hasToken)
    }
    
    func testClearToken() {
        apiClient.setToken("test-token-123")
        apiClient.clearToken()
        XCTAssertFalse(apiClient.hasToken)
    }
    
    func testHasTokenWhenEmpty() {
        XCTAssertFalse(apiClient.hasToken)
    }
    
    func testHasTokenWithEmptyString() {
        apiClient.setToken("")
        XCTAssertFalse(apiClient.hasToken)
    }
    
    // MARK: - Error Cases
    
    func testFetchWithoutToken() async {
        let startDate = Date()
        let endDate = Date()
        
        do {
            _ = try await apiClient.fetchDailySleep(startDate: startDate, endDate: endDate)
            XCTFail("Expected invalidToken error")
        } catch let error as OuraAPIError {
            switch error {
            case .invalidToken:
                break // Expected
            default:
                XCTFail("Expected invalidToken error, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Error Description Tests
    
    func testErrorDescriptions() {
        XCTAssertNotNil(OuraAPIError.invalidURL.errorDescription)
        XCTAssertNotNil(OuraAPIError.invalidToken.errorDescription)
        XCTAssertNotNil(OuraAPIError.unauthorized.errorDescription)
        XCTAssertNotNil(OuraAPIError.rateLimited(retryAfter: 60).errorDescription)
        XCTAssertNotNil(OuraAPIError.rateLimited(retryAfter: nil).errorDescription)
        XCTAssertNotNil(OuraAPIError.serverError(statusCode: 500).errorDescription)
        XCTAssertNotNil(OuraAPIError.noData.errorDescription)
        XCTAssertNotNil(OuraAPIError.unknown("test").errorDescription)
    }
    
    func testRateLimitedErrorDescription() {
        let errorWithRetry = OuraAPIError.rateLimited(retryAfter: 60)
        XCTAssertTrue(errorWithRetry.errorDescription?.contains("60") ?? false)
        
        let errorWithoutRetry = OuraAPIError.rateLimited(retryAfter: nil)
        XCTAssertTrue(errorWithoutRetry.errorDescription?.contains("later") ?? false)
    }
}
