import Foundation

protocol OuraAPIClient {
    func fetchDailySleep(accessToken: String, startDate: Date, endDate: Date) async throws -> [OuraDailySleepRecord]
    func fetchDailyReadiness(accessToken: String, startDate: Date, endDate: Date) async throws -> [OuraDailyReadinessRecord]
}

enum OuraClientError: LocalizedError, Equatable {
    case invalidResponse
    case apiFailure(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "Oura returned an invalid response."
        case let .apiFailure(statusCode, message):
            "Oura API error \(statusCode): \(message)"
        }
    }
}

struct OuraClient: OuraAPIClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let calendar: Calendar
    private let baseURL = URL(string: "https://api.ouraring.com")!

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        calendar: Calendar = .current
    ) {
        self.session = session
        self.decoder = decoder
        self.calendar = calendar
    }

    func fetchDailySleep(accessToken: String, startDate: Date, endDate: Date) async throws -> [OuraDailySleepRecord] {
        try await fetchCollection(
            path: "/v2/usercollection/daily_sleep",
            accessToken: accessToken,
            startDate: startDate,
            endDate: endDate
        )
    }

    func fetchDailyReadiness(accessToken: String, startDate: Date, endDate: Date) async throws -> [OuraDailyReadinessRecord] {
        try await fetchCollection(
            path: "/v2/usercollection/daily_readiness",
            accessToken: accessToken,
            startDate: startDate,
            endDate: endDate
        )
    }

    private func fetchCollection<T: Decodable>(
        path: String,
        accessToken: String,
        startDate: Date,
        endDate: Date
    ) async throws -> [T] {
        var allData: [T] = []
        var nextToken: String?

        repeat {
            let request = try makeRequest(
                path: path,
                accessToken: accessToken,
                startDate: startDate,
                endDate: endDate,
                nextToken: nextToken
            )
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw OuraClientError.invalidResponse
            }

            guard (200 ..< 300).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw OuraClientError.apiFailure(statusCode: httpResponse.statusCode, message: errorMessage)
            }

            let page = try decoder.decode(OuraCollectionPage<T>.self, from: data)
            allData.append(contentsOf: page.data)
            nextToken = page.nextToken
        } while nextToken != nil

        return allData
    }

    private func makeRequest(
        path: String,
        accessToken: String,
        startDate: Date,
        endDate: Date,
        nextToken: String?
    ) throws -> URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "start_date", value: Self.dayFormatter.string(from: calendar.startOfDay(for: startDate))),
            URLQueryItem(name: "end_date", value: Self.dayFormatter.string(from: calendar.startOfDay(for: endDate)))
        ]

        if let nextToken {
            components?.queryItems?.append(URLQueryItem(name: "next_token", value: nextToken))
        }

        guard let url = components?.url else {
            throw OuraClientError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_GB")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
