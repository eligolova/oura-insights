import Foundation

enum OuraAuthError: LocalizedError, Equatable {
    case missingClientID
    case invalidRedirect
    case accessDenied
    case invalidState
    case missingAccessToken

    var errorDescription: String? {
        switch self {
        case .missingClientID:
            "Add your Oura client ID before starting sign-in."
        case .invalidRedirect:
            "The Oura callback could not be understood."
        case .accessDenied:
            "Oura sign-in was cancelled."
        case .invalidState:
            "The Oura callback state did not match the pending sign-in request."
        case .missingAccessToken:
            "Oura did not return an access token."
        }
    }
}

struct OuraSessionToken: Codable, Equatable, Sendable {
    let accessToken: String
    let refreshToken: String?
    let tokenType: String
    let scopes: [String]
    let expiresAt: Date

    var hasExpired: Bool {
        expiresAt <= .now
    }
}

struct OuraAuthorisationRequest: Equatable, Sendable {
    let clientID: String
    let redirectURI: URL
    let scopes: [String]
    let state: String
}

struct OuraAuthorisationResult: Equatable, Sendable {
    let token: OuraSessionToken
    let state: String?
}

struct OuraAuthClient {
    static let defaultRedirectURI = URL(string: "oura-insights://oauth/callback")!
    static let defaultScopes = ["daily"]
    private let authoriseURL = URL(string: "https://cloud.ouraring.com/oauth/authorize")!

    func makeAuthorisationURL(request: OuraAuthorisationRequest) throws -> URL {
        guard request.clientID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw OuraAuthError.missingClientID
        }

        var components = URLComponents(url: authoriseURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "client_id", value: request.clientID),
            URLQueryItem(name: "redirect_uri", value: request.redirectURI.absoluteString),
            URLQueryItem(name: "scope", value: request.scopes.joined(separator: " ")),
            URLQueryItem(name: "state", value: request.state)
        ]

        guard let url = components?.url else {
            throw OuraAuthError.invalidRedirect
        }

        return url
    }

    func parseAuthorisationCallback(url: URL, expectedState: String?) throws -> OuraAuthorisationResult {
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
           queryItems.contains(where: { $0.name == "error" && $0.value == "access_denied" }) {
            throw OuraAuthError.accessDenied
        }

        let fragmentItems = Self.parseURLEncodedFragment(url.fragment)
        guard let accessToken = fragmentItems["access_token"], accessToken.isEmpty == false else {
            throw OuraAuthError.missingAccessToken
        }

        let state = fragmentItems["state"]
        if let expectedState, state != expectedState {
            throw OuraAuthError.invalidState
        }

        let expiresIn = Double(fragmentItems["expires_in"] ?? "") ?? 0
        let scopes = (fragmentItems["scope"] ?? "")
            .split(separator: " ")
            .map(String.init)
            .filter { $0.isEmpty == false }

        let token = OuraSessionToken(
            accessToken: accessToken,
            refreshToken: fragmentItems["refresh_token"],
            tokenType: fragmentItems["token_type"] ?? "bearer",
            scopes: scopes,
            expiresAt: .now.addingTimeInterval(expiresIn)
        )

        return OuraAuthorisationResult(token: token, state: state)
    }

    private static func parseURLEncodedFragment(_ fragment: String?) -> [String: String] {
        guard let fragment else {
            return [:]
        }

        return fragment
            .split(separator: "&")
            .reduce(into: [String: String]()) { partialResult, pair in
                let components = pair.split(separator: "=", maxSplits: 1).map(String.init)
                guard let name = components.first?.removingPercentEncoding else {
                    return
                }

                let value = components.count > 1 ? components[1].removingPercentEncoding ?? components[1] : ""
                partialResult[name] = value.replacingOccurrences(of: "+", with: " ")
            }
    }
}
