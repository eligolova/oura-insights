import XCTest
@testable import OuraInsightsFeature

final class OuraAuthClientTests: XCTestCase {
    func testBuildsAuthorisationCodeURL() throws {
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
        XCTAssertEqual(queryItems["response_type"], "code")
        XCTAssertEqual(queryItems["client_id"], "client123")
        XCTAssertEqual(queryItems["redirect_uri"], "https://eligolova.github.io/oura-insights/oauth/callback/")
        XCTAssertEqual(queryItems["scope"], "daily")
        XCTAssertEqual(queryItems["state"], "state-1")
        XCTAssertTrue(url.absoluteString.contains("redirect_uri=https%3A%2F%2Feligolova.github.io%2Foura-insights%2Foauth%2Fcallback%2F"))
    }

    func testParsesCallbackQueryIntoAuthorisationCode() throws {
        let client = OuraAuthClient()
        let callback = try XCTUnwrap(URL(string: "oura-insights://oauth/callback?code=code123&scope=daily&state=state-1"))

        let result = try client.parseAuthorisationCallback(url: callback, expectedState: "state-1")

        XCTAssertEqual(result.code, "code123")
        XCTAssertEqual(result.scopes, ["daily"])
        XCTAssertEqual(result.state, "state-1")
    }
}
