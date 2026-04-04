import Foundation

// MARK: - API Error Types
public enum OuraAPIError: Error, LocalizedError {
    case invalidURL
    case invalidToken
    case unauthorized
    case rateLimited(retryAfter: Int?)
    case serverError(statusCode: Int)
    case networkError(Error)
    case decodingError(Error)
    case noData
    case unknown(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidToken:
            return "Invalid or missing Personal Access Token"
        case .unauthorized:
            return "Unauthorized - please check your Personal Access Token"
        case .rateLimited(let retryAfter):
            if let seconds = retryAfter {
                return "Rate limited. Please try again in \(seconds) seconds"
            }
            return "Rate limited. Please try again later"
        case .serverError(let statusCode):
            return "Server error (HTTP \(statusCode))"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .noData:
            return "No data received from server"
        case .unknown(let message):
            return message
        }
    }
}

// MARK: - API Client Protocol
public protocol OuraAPIClientProtocol {
    func validateToken() async throws -> PersonalInfoResponse
    func fetchDailySleep(startDate: Date, endDate: Date) async throws -> [DailySleepResponse]
    func fetchSleepDocuments(startDate: Date, endDate: Date) async throws -> [SleepDocumentResponse]
    func fetchDailyReadiness(startDate: Date, endDate: Date) async throws -> [DailyReadinessResponse]
    func fetchDailyActivity(startDate: Date, endDate: Date) async throws -> [DailyActivityResponse]
}

// MARK: - Oura API Client
public final class OuraAPIClient: OuraAPIClientProtocol {
    private let baseURL = "https://api.ouraring.com/v2"
    private let session: URLSession
    private var token: String?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Token Management
    public func setToken(_ token: String) {
        self.token = token
    }
    
    public func clearToken() {
        self.token = nil
    }
    
    public var hasToken: Bool {
        return token != nil && !token!.isEmpty
    }
    
    // MARK: - API Methods
    
    /// Validates the PAT by fetching personal info
    public func validateToken() async throws -> PersonalInfoResponse {
        let url = try buildURL(path: "/usercollection/personal_info")
        return try await performRequest(url: url)
    }
    
    /// Fetch daily sleep scores
    public func fetchDailySleep(startDate: Date, endDate: Date) async throws -> [DailySleepResponse] {
        let url = try buildURL(
            path: "/usercollection/daily_sleep",
            queryItems: dateRangeQuery(start: startDate, end: endDate)
        )
        let response: OuraAPIResponse<DailySleepResponse> = try await performRequest(url: url)
        return response.data
    }
    
    /// Fetch detailed sleep documents
    public func fetchSleepDocuments(startDate: Date, endDate: Date) async throws -> [SleepDocumentResponse] {
        let url = try buildURL(
            path: "/usercollection/sleep",
            queryItems: dateRangeQuery(start: startDate, end: endDate)
        )
        let response: OuraAPIResponse<SleepDocumentResponse> = try await performRequest(url: url)
        return response.data
    }
    
    /// Fetch daily readiness scores
    public func fetchDailyReadiness(startDate: Date, endDate: Date) async throws -> [DailyReadinessResponse] {
        let url = try buildURL(
            path: "/usercollection/daily_readiness",
            queryItems: dateRangeQuery(start: startDate, end: endDate)
        )
        let response: OuraAPIResponse<DailyReadinessResponse> = try await performRequest(url: url)
        return response.data
    }
    
    /// Fetch daily activity data
    public func fetchDailyActivity(startDate: Date, endDate: Date) async throws -> [DailyActivityResponse] {
        let url = try buildURL(
            path: "/usercollection/daily_activity",
            queryItems: dateRangeQuery(start: startDate, end: endDate)
        )
        let response: OuraAPIResponse<DailyActivityResponse> = try await performRequest(url: url)
        return response.data
    }
    
    // MARK: - Private Helpers
    
    private func buildURL(path: String, queryItems: [URLQueryItem]? = nil) throws -> URL {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw OuraAPIError.invalidURL
        }
        return url
    }
    
    private func dateRangeQuery(start: Date, end: Date) -> [URLQueryItem] {
        return [
            URLQueryItem(name: "start_date", value: dateFormatter.string(from: start)),
            URLQueryItem(name: "end_date", value: dateFormatter.string(from: end))
        ]
    }
    
    private func performRequest<T: Decodable>(url: URL) async throws -> T {
        guard let token = token, !token.isEmpty else {
            throw OuraAPIError.invalidToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw OuraAPIError.networkError(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OuraAPIError.unknown("Invalid response type")
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw OuraAPIError.unauthorized
        case 429:
            let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After").flatMap { Int($0) }
            throw OuraAPIError.rateLimited(retryAfter: retryAfter)
        case 400...499:
            throw OuraAPIError.serverError(statusCode: httpResponse.statusCode)
        case 500...599:
            throw OuraAPIError.serverError(statusCode: httpResponse.statusCode)
        default:
            throw OuraAPIError.unknown("Unexpected status code: \(httpResponse.statusCode)")
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw OuraAPIError.decodingError(error)
        }
    }
}

// MARK: - Convenience Extensions
public extension OuraAPIClient {
    /// Fetch all data types for a date range
    func fetchAllData(startDate: Date, endDate: Date) async throws -> (
        sleep: [SleepDocumentResponse],
        readiness: [DailyReadinessResponse],
        activity: [DailyActivityResponse]
    ) {
        async let sleepTask = fetchSleepDocuments(startDate: startDate, endDate: endDate)
        async let readinessTask = fetchDailyReadiness(startDate: startDate, endDate: endDate)
        async let activityTask = fetchDailyActivity(startDate: startDate, endDate: endDate)
        
        let (sleep, readiness, activity) = try await (sleepTask, readinessTask, activityTask)
        return (sleep, readiness, activity)
    }
    
    /// Fetch data for the last N days
    func fetchRecentData(days: Int = 30) async throws -> (
        sleep: [SleepDocumentResponse],
        readiness: [DailyReadinessResponse],
        activity: [DailyActivityResponse]
    ) {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate) ?? endDate
        return try await fetchAllData(startDate: startDate, endDate: endDate)
    }
}
