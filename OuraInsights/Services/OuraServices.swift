import Foundation
import AuthenticationServices
import os.log

enum OuraAuthError: Error, LocalizedError {
    case invalidURL
    case missingCode
    case tokenExchangeFailed(String)
    case invalidResponse
    case networkError(Error)
    case cancelled
    case missingCredentials
    
    var errorDescription: String? {
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

enum OuraAPIError: Error, LocalizedError {
    case invalidURL
    case unauthorized
    case rateLimited(retryAfter: Int?)
    case serverError(statusCode: Int, message: String?)
    case networkError(Error)
    case decodingError(Error)
    case noData
    case tokenExpired
    case invalidDateRange
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .unauthorized:
            return "Unauthorized - please reconnect your Oura account"
        case .rateLimited(let retryAfter):
            if let seconds = retryAfter {
                return "Rate limited - please wait \(seconds) seconds"
            }
            return "Rate limited - please try again later"
        case .serverError(let statusCode, let message):
            return "Server error (\(statusCode)): \(message ?? "Unknown error")"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .noData:
            return "No data returned from API"
        case .tokenExpired:
            return "Access token has expired"
        case .invalidDateRange:
            return "Invalid date range specified"
        }
    }
}

struct OuraOAuthConfig {
    let clientId: String
    let clientSecret: String
    let redirectUri: String
    let scopes: [String]
    
    static let authorizationURL = "https://cloud.ouraring.com/oauth/authorize"
    static let tokenURL = "https://api.ouraring.com/oauth/token"
    
    static let defaultScopes = [
        "daily_activity",
        "daily_readiness", 
        "daily_sleep",
        "heartrate",
        "session"
    ]
    
    init(
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

struct TokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let refreshToken: String?
    let scope: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope
    }
}

final class OuraAuthService {
    private let session: URLSession
    
    static let shared = OuraAuthService()
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func buildAuthorizationURL(config: OuraOAuthConfig, state: String) throws -> URL {
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
    
    func exchangeCodeForToken(code: String, config: OuraOAuthConfig) async throws -> TokenResponse {
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
    
    func refreshAccessToken(refreshToken: String, config: OuraOAuthConfig) async throws -> TokenResponse {
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
    
    func extractAuthorizationCode(from url: URL, expectedState: String) throws -> String {
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

@MainActor
final class OuraWebAuthenticator: NSObject {
    private var authSession: ASWebAuthenticationSession?
    private var continuation: CheckedContinuation<URL, Error>?
    
    func authenticate(url: URL, callbackScheme: String) async throws -> URL {
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
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return ASPresentationAnchor()
        }
        return window
    }
}
#elseif os(macOS)
extension OuraWebAuthenticator: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return NSApplication.shared.windows.first ?? ASPresentationAnchor()
    }
}
#endif

final class OuraAPIClient {
    private let baseURL = "https://api.ouraring.com/v2/usercollection"
    private let session: URLSession
    private let authProvider: () -> String?
    private let tokenRefresher: (() async throws -> Void)?
    private let logger = Logger(subsystem: "com.personal.oura-insights", category: "OuraAPIClient")
    
    private let maxRetries = 3
    private let initialBackoff: TimeInterval = 1.0
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()
    
    init(
        session: URLSession = .shared,
        authProvider: @escaping () -> String?,
        tokenRefresher: (() async throws -> Void)? = nil
    ) {
        self.session = session
        self.authProvider = authProvider
        self.tokenRefresher = tokenRefresher
    }
    
    func fetchDailySleep(startDate: Date, endDate: Date) async throws -> DailySleepResponse {
        let endpoint = "/daily_sleep"
        return try await fetchWithDateRange(endpoint: endpoint, startDate: startDate, endDate: endDate)
    }
    
    func fetchDailyReadiness(startDate: Date, endDate: Date) async throws -> DailyReadinessResponse {
        let endpoint = "/daily_readiness"
        return try await fetchWithDateRange(endpoint: endpoint, startDate: startDate, endDate: endDate)
    }
    
    func fetchDailyActivity(startDate: Date, endDate: Date) async throws -> DailyActivityResponse {
        let endpoint = "/daily_activity"
        return try await fetchWithDateRange(endpoint: endpoint, startDate: startDate, endDate: endDate)
    }
    
    private func fetchWithDateRange<T: Decodable>(
        endpoint: String,
        startDate: Date,
        endDate: Date
    ) async throws -> T {
        guard startDate <= endDate else {
            throw OuraAPIError.invalidDateRange
        }
        
        var components = URLComponents(string: baseURL + endpoint)!
        components.queryItems = [
            URLQueryItem(name: "start_date", value: dateFormatter.string(from: startDate)),
            URLQueryItem(name: "end_date", value: dateFormatter.string(from: endDate))
        ]
        
        guard let url = components.url else {
            throw OuraAPIError.invalidURL
        }
        
        return try await performRequest(url: url)
    }
    
    private func performRequest<T: Decodable>(url: URL, attempt: Int = 0) async throws -> T {
        guard let authHeader = authProvider() else {
            throw OuraAPIError.unauthorized
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        logger.debug("API Request: \(url.absoluteString)")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw OuraAPIError.networkError(URLError(.badServerResponse))
            }
            
            logger.debug("API Response: \(httpResponse.statusCode)")
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    return try decoder.decode(T.self, from: data)
                } catch {
                    logger.error("Decoding error: \(error.localizedDescription)")
                    throw OuraAPIError.decodingError(error)
                }
                
            case 401:
                if attempt == 0, let refresher = tokenRefresher {
                    logger.info("Token expired, attempting refresh...")
                    try await refresher()
                    return try await performRequest(url: url, attempt: attempt + 1)
                }
                throw OuraAPIError.unauthorized
                
            case 429:
                let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After").flatMap { Int($0) }
                
                if attempt < maxRetries {
                    let delay = Double(retryAfter ?? Int(initialBackoff * pow(2, Double(attempt))))
                    logger.warning("Rate limited, waiting \(delay) seconds before retry...")
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    return try await performRequest(url: url, attempt: attempt + 1)
                }
                throw OuraAPIError.rateLimited(retryAfter: retryAfter)
                
            case 500...599:
                if attempt < maxRetries {
                    let delay = initialBackoff * pow(2, Double(attempt))
                    logger.warning("Server error, retrying in \(delay) seconds...")
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    return try await performRequest(url: url, attempt: attempt + 1)
                }
                let message = String(data: data, encoding: .utf8)
                throw OuraAPIError.serverError(statusCode: httpResponse.statusCode, message: message)
                
            default:
                let message = String(data: data, encoding: .utf8)
                throw OuraAPIError.serverError(statusCode: httpResponse.statusCode, message: message)
            }
        } catch let error as OuraAPIError {
            throw error
        } catch {
            if attempt < maxRetries && (error as? URLError)?.code != .cancelled {
                let delay = initialBackoff * pow(2, Double(attempt))
                logger.warning("Network error, retrying in \(delay) seconds: \(error.localizedDescription)")
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                return try await performRequest(url: url, attempt: attempt + 1)
            }
            throw OuraAPIError.networkError(error)
        }
    }
}

struct DailySleepResponse: Codable {
    let data: [DailySleepData]
    let nextToken: String?
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextToken = "next_token"
    }
}

struct DailySleepData: Codable, Identifiable {
    let id: String
    let day: String
    let score: Int?
    let contributors: SleepContributors?
    
    var dayDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: day)
    }
}

struct SleepContributors: Codable {
    let deepSleep: Int?
    let efficiency: Int?
    let latency: Int?
    let remSleep: Int?
    let restfulness: Int?
    let timing: Int?
    let totalSleep: Int?
    
    enum CodingKeys: String, CodingKey {
        case deepSleep = "deep_sleep"
        case efficiency
        case latency
        case remSleep = "rem_sleep"
        case restfulness
        case timing
        case totalSleep = "total_sleep"
    }
}

struct DailyReadinessResponse: Codable {
    let data: [DailyReadinessData]
    let nextToken: String?
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextToken = "next_token"
    }
}

struct DailyReadinessData: Codable, Identifiable {
    let id: String
    let day: String
    let score: Int?
    let temperatureDeviation: Double?
    let contributors: ReadinessContributors?
    
    enum CodingKeys: String, CodingKey {
        case id, day, score
        case temperatureDeviation = "temperature_deviation"
        case contributors
    }
    
    var dayDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: day)
    }
}

struct ReadinessContributors: Codable {
    let activityBalance: Int?
    let bodyTemperature: Int?
    let hrvBalance: Int?
    let previousDayActivity: Int?
    let previousNight: Int?
    let recoveryIndex: Int?
    let restingHeartRate: Int?
    let sleepBalance: Int?
    
    enum CodingKeys: String, CodingKey {
        case activityBalance = "activity_balance"
        case bodyTemperature = "body_temperature"
        case hrvBalance = "hrv_balance"
        case previousDayActivity = "previous_day_activity"
        case previousNight = "previous_night"
        case recoveryIndex = "recovery_index"
        case restingHeartRate = "resting_heart_rate"
        case sleepBalance = "sleep_balance"
    }
}

struct DailyActivityResponse: Codable {
    let data: [DailyActivityData]
    let nextToken: String?
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextToken = "next_token"
    }
}

struct DailyActivityData: Codable, Identifiable {
    let id: String
    let day: String
    let score: Int?
    let activeCalories: Int?
    let totalCalories: Int?
    let steps: Int?
    let equivalentWalkingDistance: Int?
    let highActivityTime: Int?
    let mediumActivityTime: Int?
    let lowActivityTime: Int?
    let sedentaryTime: Int?
    let restingTime: Int?
    let inactivityAlerts: Int?
    let contributors: ActivityContributors?
    
    enum CodingKeys: String, CodingKey {
        case id, day, score, steps, contributors
        case activeCalories = "active_calories"
        case totalCalories = "total_calories"
        case equivalentWalkingDistance = "equivalent_walking_distance"
        case highActivityTime = "high_activity_time"
        case mediumActivityTime = "medium_activity_time"
        case lowActivityTime = "low_activity_time"
        case sedentaryTime = "sedentary_time"
        case restingTime = "resting_time"
        case inactivityAlerts = "inactivity_alerts"
    }
    
    var dayDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: day)
    }
}

struct ActivityContributors: Codable {
    let meetDailyTargets: Int?
    let moveEveryHour: Int?
    let recoveryTime: Int?
    let stayActive: Int?
    let trainingFrequency: Int?
    let trainingVolume: Int?
    
    enum CodingKeys: String, CodingKey {
        case meetDailyTargets = "meet_daily_targets"
        case moveEveryHour = "move_every_hour"
        case recoveryTime = "recovery_time"
        case stayActive = "stay_active"
        case trainingFrequency = "training_frequency"
        case trainingVolume = "training_volume"
    }
}
