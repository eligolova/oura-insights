import XCTest
@testable import OuraInsightsCore

final class OuraTokenTests: XCTestCase {
    
    func testOuraTokenCreation() {
        let token = OuraToken(
            accessToken: "test-access-token",
            refreshToken: "test-refresh-token",
            expiresAt: Date().addingTimeInterval(3600)
        )
        
        XCTAssertEqual(token.accessToken, "test-access-token")
        XCTAssertEqual(token.refreshToken, "test-refresh-token")
        XCTAssertEqual(token.tokenType, "Bearer")
    }
    
    func testTokenNotExpired() {
        let token = OuraToken(
            accessToken: "valid-token",
            expiresAt: Date().addingTimeInterval(3600)
        )
        
        XCTAssertFalse(token.isExpired)
    }
    
    func testTokenExpired() {
        let token = OuraToken(
            accessToken: "expired-token",
            expiresAt: Date().addingTimeInterval(-3600)
        )
        
        XCTAssertTrue(token.isExpired)
    }
    
    func testTokenNoExpiry() {
        let token = OuraToken(accessToken: "no-expiry-token")
        XCTAssertFalse(token.isExpired)
    }
    
    func testExpiresIn() {
        let token = OuraToken(
            accessToken: "test-token",
            expiresAt: Date().addingTimeInterval(3600)
        )
        
        guard let expiresIn = token.expiresIn else {
            XCTFail("expiresIn should not be nil")
            return
        }
        
        XCTAssertEqual(expiresIn, 3600, accuracy: 1)
    }
    
    func testExpiresInNil() {
        let token = OuraToken(accessToken: "test-token")
        XCTAssertNil(token.expiresIn)
    }
    
    func testAuthorizationHeader() {
        let token = OuraToken(accessToken: "my-access-token")
        XCTAssertEqual(token.authorizationHeader, "Bearer my-access-token")
    }
    
    func testCodable() throws {
        let token = OuraToken(
            accessToken: "test-encode",
            refreshToken: "test-refresh",
            expiresAt: Date().addingTimeInterval(3600)
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(token)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(OuraToken.self, from: data)
        
        XCTAssertEqual(decoded.accessToken, token.accessToken)
        XCTAssertEqual(decoded.refreshToken, token.refreshToken)
    }
}
