import Foundation

enum OuraAuthError: LocalizedError, Equatable {
    case missingClientID
    case missingClientSecret
    case invalidRedirect
    case accessDenied
    case invalidState
    case missingAuthorisationCode
    case invalidTokenResponse
    case tokenExchangeFailed(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .missingClientID:
            "Add your Oura client ID before starting sign-in."
        case .missingClientSecret:
            "Add your Oura client secret before starting sign-in."
        case .invalidRedirect:
            "The Oura callback could not be understood."
        case .accessDenied:
            "Oura sign-in was cancelled."
        case .invalidState:
            "The Oura callback state did not match the pending sign-in request."
        case .missingAuthorisationCode:
            "Oura did not return an authorisation code."
        case .invalidTokenResponse:
            "Oura returned an invalid token response."
        case let .tokenExchangeFailed(statusCode, message):
            "Oura token exchange failed with status \(statusCode): \(message)"
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

struct OuraAuthorisationCode: Equatable, Sendable {
    let code: String
    let scopes: [String]
    let state: String?
}

struct OuraTokenExchangeRequest: Equatable, Sendable {
    let code: String
    let clientID: String
    let clientSecret: String
    let redirectURI: URL
}

struct OuraAuthClient {
    static let defaultRedirectURI = URL(string: "https://eligolova.github.io/oura-insights/oauth/callback/")!
    static let defaultScopes = ["daily"]

    private let authoriseURL = URL(string: "https://cloud.ouraring.com/oauth/authorize")!
    private let tokenURL = URL(string: "https://api.ouraring.com/oauth/token")!
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func makeAuthorisationURL(request: OuraAuthorisationRequest) throws -> URL {
        guard request.clientID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw OuraAuthError.missingClientID
        }

        var components = URLComponents(url: authoriseURL, resolvingAgainstBaseURL: false)
        components?.percentEncodedQuery = Self.percentEncodedQuery([
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: request.clientID),
            URLQueryItem(name: "redirect_uri", value: request.redirectURI.absoluteString),
            URLQueryItem(name: "scope", value: request.scopes.joined(separator: " ")),
            URLQueryItem(name: "state", value: request.state)
        ])

        guard let url = components?.url else {
            throw OuraAuthError.invalidRedirect
        }

        return url
    }

    func parseAuthorisationCallback(url: URL, expectedState: String?) throws -> OuraAuthorisationCode {
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
           queryItems.contains(where: { $0.name == "error" && $0.value == "access_denied" }) {
            throw OuraAuthError.accessDenied
        }

        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        let values = Dictionary(uniqueKeysWithValues: queryItems.map { ($0.name, $0.value ?? "") })
        guard let code = values["code"], code.isEmpty == false else {
            throw OuraAuthError.missingAuthorisationCode
        }

        let state = values["state"]
        if let expectedState, state != expectedState {
            throw OuraAuthError.invalidState
        }

        let scopes = (values["scope"] ?? "")
            .split(separator: " ")
            .map(String.init)
            .filter { $0.isEmpty == false }

        return OuraAuthorisationCode(code: code, scopes: scopes, state: state)
    }

    func exchangeCodeForToken(request: OuraTokenExchangeRequest) async throws -> OuraSessionToken {
        guard request.clientID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw OuraAuthError.missingClientID
        }
        guard request.clientSecret.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw OuraAuthError.missingClientSecret
        }

        var urlRequest = URLRequest(url: tokenURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.httpBody = Self.formEncodedBody([
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: request.code),
            URLQueryItem(name: "redirect_uri", value: request.redirectURI.absoluteString),
            URLQueryItem(name: "client_id", value: request.clientID),
            URLQueryItem(name: "client_secret", value: request.clientSecret)
        ])

        let (data, response) = try await session.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OuraAuthError.invalidTokenResponse
        }

        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OuraAuthError.tokenExchangeFailed(statusCode: httpResponse.statusCode, message: message)
        }

        let tokenResponse = try decoder.decode(OuraTokenResponse.self, from: data)
        let scopes = tokenResponse.scope?
            .split(separator: " ")
            .map(String.init)
            .filter { $0.isEmpty == false } ?? []

        return OuraSessionToken(
            accessToken: tokenResponse.accessToken,
            refreshToken: tokenResponse.refreshToken,
            tokenType: tokenResponse.tokenType,
            scopes: scopes,
            expiresAt: .now.addingTimeInterval(TimeInterval(tokenResponse.expiresIn))
        )
    }

    private static func formEncodedBody(_ items: [URLQueryItem]) -> Data? {
        percentEncodedQuery(items).data(using: .utf8)
    }

    private static func percentEncodedQuery(_ items: [URLQueryItem]) -> String {
        items
            .compactMap { item in
                guard let encodedName = item.name.addingPercentEncoding(withAllowedCharacters: .ouraQueryAllowed) else {
                    return nil
                }

                let encodedValue = item.value?
                    .addingPercentEncoding(withAllowedCharacters: .ouraQueryAllowed) ?? ""
                return "\(encodedName)=\(encodedValue)"
            }
            .joined(separator: "&")
    }
}

private extension CharacterSet {
    static let ouraQueryAllowed: CharacterSet = {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: ":/?#[]@!$&'()*+,;=% ")
        return allowed
    }()
}

private struct OuraTokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String?
    let tokenType: String
    let expiresIn: Int
    let scope: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case scope
    }
}
