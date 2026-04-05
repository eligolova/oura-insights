import XCTest
@testable import OuraInsightsFeature

final class OuraAuthClientTests: XCTestCase {
    func testBuildsClientSideAuthorisationURL() throws {
        let client = OuraAuthClient()
        let url = try client.makeAuthorisationURL(
            request: OuraAuthorisationRequest(
                clientID: "client123",
                redirectURI: OuraAuthClient.defaultRedirectURI,
                scopes: ["daily"],
                state: "state-1"
            )
        )

        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let queryItems = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value ?? "") })

        XCTAssertEqual(components.host, "cloud.ouraring.com")
        XCTAssertEqual(queryItems["response_type"], "token")
        XCTAssertEqual(queryItems["client_id"], "client123")
        XCTAssertEqual(queryItems["scope"], "daily")
        XCTAssertEqual(queryItems["state"], "state-1")
    }

    func testParsesCallbackFragmentIntoToken() throws {
        let client = OuraAuthClient()
        let callback = try XCTUnwrap(URL(string: "oura-insights://oauth/callback#token_type=bearer&access_token=abc123&expires_in=3600&scope=daily&state=state-1"))

        let result = try client.parseAuthorisationCallback(url: callback, expectedState: "state-1")

        XCTAssertEqual(result.token.accessToken, "abc123")
        XCTAssertEqual(result.token.tokenType, "bearer")
        XCTAssertEqual(result.token.scopes, ["daily"])
        XCTAssertEqual(result.state, "state-1")
    }
}
