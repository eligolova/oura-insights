import Foundation
import os.log

public enum OuraAPIError: Error, LocalizedError {
    case invalidURL
    case unauthorized
    case rateLimited(retryAfter: Int?)
    case serverError(statusCode: Int, message: String?)
    case networkError(Error)
    case decodingError(Error)
    case noData
    case tokenExpired
    case invalidDateRange
    
    public var errorDescription: String? {
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
    
    public var isRetryable: Bool {
        switch self {
        case .rateLimited:
            return true
        case .serverError(let code, _) where code >= 500:
            return true
        case .networkError:
            return true
        default:
            return false
        }
    }
}

public protocol OuraAPIClientProtocol {
    func fetchDailySleep(startDate: Date, endDate: Date) async throws -> DailySleepResponse
    func fetchDailyReadiness(startDate: Date, endDate: Date) async throws -> DailyReadinessResponse
    func fetchDailyActivity(startDate: Date, endDate: Date) async throws -> DailyActivityResponse
    func fetchHeartRate(startDate: Date, endDate: Date) async throws -> HeartRateResponse
}

public final class OuraAPIClient: OuraAPIClientProtocol {
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
    
    private lazy var isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            if let date = ISO8601DateFormatter().date(from: dateString) {
                return date
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date: \(dateString)")
        }
        return decoder
    }()
    
    public init(
        session: URLSession = .shared,
        authProvider: @escaping () -> String?,
        tokenRefresher: (() async throws -> Void)? = nil
    ) {
        self.session = session
        self.authProvider = authProvider
        self.tokenRefresher = tokenRefresher
    }
    
    public func fetchDailySleep(startDate: Date, endDate: Date) async throws -> DailySleepResponse {
        let endpoint = "/daily_sleep"
        return try await fetchWithDateRange(endpoint: endpoint, startDate: startDate, endDate: endDate)
    }
    
    public func fetchDailyReadiness(startDate: Date, endDate: Date) async throws -> DailyReadinessResponse {
        let endpoint = "/daily_readiness"
        return try await fetchWithDateRange(endpoint: endpoint, startDate: startDate, endDate: endDate)
    }
    
    public func fetchDailyActivity(startDate: Date, endDate: Date) async throws -> DailyActivityResponse {
        let endpoint = "/daily_activity"
        return try await fetchWithDateRange(endpoint: endpoint, startDate: startDate, endDate: endDate)
    }
    
    public func fetchHeartRate(startDate: Date, endDate: Date) async throws -> HeartRateResponse {
        let endpoint = "/heartrate"
        return try await fetchWithDateTimeRange(endpoint: endpoint, startDate: startDate, endDate: endDate)
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
    
    private func fetchWithDateTimeRange<T: Decodable>(
        endpoint: String,
        startDate: Date,
        endDate: Date
    ) async throws -> T {
        guard startDate <= endDate else {
            throw OuraAPIError.invalidDateRange
        }
        
        var components = URLComponents(string: baseURL + endpoint)!
        components.queryItems = [
            URLQueryItem(name: "start_datetime", value: isoFormatter.string(from: startDate)),
            URLQueryItem(name: "end_datetime", value: isoFormatter.string(from: endDate))
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
    
    public func fetchAllPages<T: Decodable & PaginatedResponse>(
        fetch: (String?) async throws -> T
    ) async throws -> [T.Item] {
        var allItems: [T.Item] = []
        var nextToken: String? = nil
        
        repeat {
            let response = try await fetch(nextToken)
            allItems.append(contentsOf: response.data)
            nextToken = response.nextToken
        } while nextToken != nil
        
        return allItems
    }
}

public protocol PaginatedResponse {
    associatedtype Item
    var data: [Item] { get }
    var nextToken: String? { get }
}
