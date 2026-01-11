import XCTest
@testable import OuraInsightsCore

final class OuraAuthServiceTests: XCTestCase {
    
    var authService: OuraAuthService!
    var testConfig: OuraOAuthConfig!
    
    override func setUp() {
        super.setUp()
        authService = OuraAuthService()
        testConfig = OuraOAuthConfig(
            clientId: "test-client-id",
            clientSecret: "test-client-secret",
            redirectUri: "oura-insights://oauth-callback",
            scopes: ["daily_sleep", "daily_activity", "daily_readiness"]
        )
    }
    
    override func tearDown() {
        authService = nil
        testConfig = nil
        super.tearDown()
    }
    
    func testBuildAuthorizationURL() throws {
        let state = "test-state-123"
        let url = try authService.buildAuthorizationURL(config: testConfig, state: state)
        
        XCTAssertNotNil(url)
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        XCTAssertEqual(components?.host, "cloud.ouraring.com")
        XCTAssertEqual(components?.path, "/oauth/authorize")
        
        let queryItems = components?.queryItems ?? []
        let queryDict = Dictionary(uniqueKeysWithValues: queryItems.map { ($0.name, $0.value) })
        
        XCTAssertEqual(queryDict["client_id"], "test-client-id")
        XCTAssertEqual(queryDict["redirect_uri"], "oura-insights://oauth-callback")
        XCTAssertEqual(queryDict["response_type"], "code")
        XCTAssertEqual(queryDict["state"], "test-state-123")
        XCTAssertNotNil(queryDict["scope"])
    }
    
    func testBuildAuthorizationURLWithDefaultScopes() throws {
        let defaultConfig = OuraOAuthConfig(
            clientId: "test-id",
            clientSecret: "test-secret"
        )
        
        let url = try authService.buildAuthorizationURL(config: defaultConfig, state: "state")
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []
        let scopeItem = queryItems.first { $0.name == "scope" }
        
        XCTAssertNotNil(scopeItem?.value)
        XCTAssertTrue(scopeItem!.value!.contains("daily_sleep"))
        XCTAssertTrue(scopeItem!.value!.contains("daily_activity"))
        XCTAssertTrue(scopeItem!.value!.contains("daily_readiness"))
    }
    
    func testExtractAuthorizationCode() throws {
        let callbackURL = URL(string: "oura-insights://oauth-callback?code=auth-code-xyz&state=expected-state")!
        
        let code = try authService.extractAuthorizationCode(from: callbackURL, expectedState: "expected-state")
        
        XCTAssertEqual(code, "auth-code-xyz")
    }
    
    func testExtractAuthorizationCodeMissingCode() {
        let callbackURL = URL(string: "oura-insights://oauth-callback?state=expected-state")!
        
        XCTAssertThrowsError(try authService.extractAuthorizationCode(from: callbackURL, expectedState: "expected-state")) { error in
            guard let authError = error as? OuraAuthError else {
                XCTFail("Expected OuraAuthError")
                return
            }
            
            if case .missingCode = authError {
                // Expected
            } else {
                XCTFail("Expected missingCode error")
            }
        }
    }
    
    func testExtractAuthorizationCodeStateMismatch() {
        let callbackURL = URL(string: "oura-insights://oauth-callback?code=auth-code&state=wrong-state")!
        
        XCTAssertThrowsError(try authService.extractAuthorizationCode(from: callbackURL, expectedState: "expected-state")) { error in
            guard let authError = error as? OuraAuthError else {
                XCTFail("Expected OuraAuthError")
                return
            }
            
            if case .tokenExchangeFailed(let message) = authError {
                XCTAssertTrue(message.contains("State mismatch"))
            } else {
                XCTFail("Expected tokenExchangeFailed error")
            }
        }
    }
    
    func testExtractAuthorizationCodeAccessDenied() {
        let callbackURL = URL(string: "oura-insights://oauth-callback?error=access_denied&state=expected-state")!
        
        XCTAssertThrowsError(try authService.extractAuthorizationCode(from: callbackURL, expectedState: "expected-state")) { error in
            guard let authError = error as? OuraAuthError else {
                XCTFail("Expected OuraAuthError")
                return
            }
            
            if case .cancelled = authError {
                // Expected
            } else {
                XCTFail("Expected cancelled error, got \(authError)")
            }
        }
    }
    
    func testExtractAuthorizationCodeOtherError() {
        let callbackURL = URL(string: "oura-insights://oauth-callback?error=invalid_request&state=expected-state")!
        
        XCTAssertThrowsError(try authService.extractAuthorizationCode(from: callbackURL, expectedState: "expected-state")) { error in
            guard let authError = error as? OuraAuthError else {
                XCTFail("Expected OuraAuthError")
                return
            }
            
            if case .tokenExchangeFailed(let message) = authError {
                XCTAssertEqual(message, "invalid_request")
            } else {
                XCTFail("Expected tokenExchangeFailed error")
            }
        }
    }
    
    func testTokenResponseDecoding() throws {
        let json = """
        {
            "access_token": "test-access-token",
            "token_type": "Bearer",
            "expires_in": 86400,
            "refresh_token": "test-refresh-token",
            "scope": "daily_sleep daily_activity"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(TokenResponse.self, from: json)
        
        XCTAssertEqual(response.accessToken, "test-access-token")
        XCTAssertEqual(response.tokenType, "Bearer")
        XCTAssertEqual(response.expiresIn, 86400)
        XCTAssertEqual(response.refreshToken, "test-refresh-token")
        XCTAssertEqual(response.scope, "daily_sleep daily_activity")
    }
    
    func testTokenResponseDecodingMinimal() throws {
        let json = """
        {
            "access_token": "minimal-token",
            "token_type": "Bearer",
            "expires_in": 3600
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(TokenResponse.self, from: json)
        
        XCTAssertEqual(response.accessToken, "minimal-token")
        XCTAssertNil(response.refreshToken)
        XCTAssertNil(response.scope)
    }
    
    func testOAuthConfigDefaultValues() {
        let config = OuraOAuthConfig(
            clientId: "id",
            clientSecret: "secret"
        )
        
        XCTAssertEqual(config.redirectUri, "oura-insights://oauth-callback")
        XCTAssertEqual(config.scopes, OuraOAuthConfig.defaultScopes)
    }
    
    func testOAuthConfigStaticURLs() {
        XCTAssertEqual(OuraOAuthConfig.authorizationURL, "https://cloud.ouraring.com/oauth/authorize")
        XCTAssertEqual(OuraOAuthConfig.tokenURL, "https://api.ouraring.com/oauth/token")
    }
}
