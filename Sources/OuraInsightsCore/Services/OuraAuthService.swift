import Foundation
import AuthenticationServices

public enum OuraAuthError: Error, LocalizedError {
    case invalidURL
    case missingCode
    case tokenExchangeFailed(String)
    case invalidResponse
    case networkError(Error)
    case cancelled
    case missingCredentials
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid OAuth URL"
        case .missingCode:
            return "Authorization code not found in callback"
        case .tokenExchangeFailed(let message):
            return "Token exchange failed: \(message)"
        case .invalidResponse:
            return "Invalid response from Oura API"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .cancelled:
            return "Authentication was cancelled"
        case .missingCredentials:
            return "OAuth credentials not configured"
        }
    }
}

public struct OuraOAuthConfig {
    public let clientId: String
    public let clientSecret: String
    public let redirectUri: String
    public let scopes: [String]
    
    public static let authorizationURL = "https://cloud.ouraring.com/oauth/authorize"
    public static let tokenURL = "https://api.ouraring.com/oauth/token"
    
    public static let defaultScopes = [
        "daily_activity",
        "daily_readiness", 
        "daily_sleep",
        "heartrate",
        "session"
    ]
    
    public init(
        clientId: String,
        clientSecret: String,
        redirectUri: String = "oura-insights://oauth-callback",
        scopes: [String] = OuraOAuthConfig.defaultScopes
    ) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectUri = redirectUri
        self.scopes = scopes
    }
}

public struct TokenResponse: Codable {
    public let accessToken: String
    public let tokenType: String
    public let expiresIn: Int
    public let refreshToken: String?
    public let scope: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope
    }
}

public protocol OuraAuthServiceProtocol {
    func buildAuthorizationURL(config: OuraOAuthConfig, state: String) throws -> URL
    func exchangeCodeForToken(code: String, config: OuraOAuthConfig) async throws -> TokenResponse
    func refreshAccessToken(refreshToken: String, config: OuraOAuthConfig) async throws -> TokenResponse
}

public final class OuraAuthService: OuraAuthServiceProtocol {
    private let session: URLSession
    
    public static let shared = OuraAuthService()
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func buildAuthorizationURL(config: OuraOAuthConfig, state: String) throws -> URL {
        var components = URLComponents(string: OuraOAuthConfig.authorizationURL)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: config.clientId),
            URLQueryItem(name: "redirect_uri", value: config.redirectUri),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: config.scopes.joined(separator: " ")),
            URLQueryItem(name: "state", value: state)
        ]
        
        guard let url = components.url else {
            throw OuraAuthError.invalidURL
        }
        
        return url
    }
    
    public func exchangeCodeForToken(code: String, config: OuraOAuthConfig) async throws -> TokenResponse {
        guard let url = URL(string: OuraOAuthConfig.tokenURL) else {
            throw OuraAuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyParams = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": config.redirectUri,
            "client_id": config.clientId,
            "client_secret": config.clientSecret
        ]
        
        request.httpBody = bodyParams
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw OuraAuthError.invalidResponse
            }
            
            if httpResponse.statusCode != 200 {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw OuraAuthError.tokenExchangeFailed("Status \(httpResponse.statusCode): \(errorMessage)")
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(TokenResponse.self, from: data)
        } catch let error as OuraAuthError {
            throw error
        } catch is DecodingError {
            throw OuraAuthError.invalidResponse
        } catch {
            throw OuraAuthError.networkError(error)
        }
    }
    
    public func refreshAccessToken(refreshToken: String, config: OuraOAuthConfig) async throws -> TokenResponse {
        guard let url = URL(string: OuraOAuthConfig.tokenURL) else {
            throw OuraAuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyParams = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": config.clientId,
            "client_secret": config.clientSecret
        ]
        
        request.httpBody = bodyParams
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw OuraAuthError.invalidResponse
            }
            
            if httpResponse.statusCode != 200 {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw OuraAuthError.tokenExchangeFailed("Status \(httpResponse.statusCode): \(errorMessage)")
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(TokenResponse.self, from: data)
        } catch let error as OuraAuthError {
            throw error
        } catch is DecodingError {
            throw OuraAuthError.invalidResponse
        } catch {
            throw OuraAuthError.networkError(error)
        }
    }
    
    public func extractAuthorizationCode(from url: URL, expectedState: String) throws -> String {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            throw OuraAuthError.missingCode
        }
        
        if let error = queryItems.first(where: { $0.name == "error" })?.value {
            if error == "access_denied" {
                throw OuraAuthError.cancelled
            }
            throw OuraAuthError.tokenExchangeFailed(error)
        }
        
        guard let state = queryItems.first(where: { $0.name == "state" })?.value,
              state == expectedState else {
            throw OuraAuthError.tokenExchangeFailed("State mismatch - possible CSRF attack")
        }
        
        guard let code = queryItems.first(where: { $0.name == "code" })?.value else {
            throw OuraAuthError.missingCode
        }
        
        return code
    }
}

#if canImport(UIKit) || canImport(AppKit)
import AuthenticationServices

@MainActor
public final class OuraWebAuthenticator: NSObject {
    private var authSession: ASWebAuthenticationSession?
    private var continuation: CheckedContinuation<URL, Error>?
    
    public func authenticate(url: URL, callbackScheme: String) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            authSession = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: callbackScheme
            ) { [weak self] callbackURL, error in
                guard let self = self else { return }
                
                if let error = error {
                    if let authError = error as? ASWebAuthenticationSessionError,
                       authError.code == .canceledLogin {
                        self.continuation?.resume(throwing: OuraAuthError.cancelled)
                    } else {
                        self.continuation?.resume(throwing: OuraAuthError.networkError(error))
                    }
                    self.continuation = nil
                    return
                }
                
                guard let callbackURL = callbackURL else {
                    self.continuation?.resume(throwing: OuraAuthError.missingCode)
                    self.continuation = nil
                    return
                }
                
                self.continuation?.resume(returning: callbackURL)
                self.continuation = nil
            }
            
            #if os(iOS)
            authSession?.presentationContextProvider = self
            #elseif os(macOS)
            authSession?.presentationContextProvider = self
            #endif
            authSession?.prefersEphemeralWebBrowserSession = false
            authSession?.start()
        }
    }
}

#if os(iOS)
extension OuraWebAuthenticator: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return ASPresentationAnchor()
        }
        return window
    }
}
#elseif os(macOS)
extension OuraWebAuthenticator: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return NSApplication.shared.windows.first ?? ASPresentationAnchor()
    }
}
#endif
#endif
