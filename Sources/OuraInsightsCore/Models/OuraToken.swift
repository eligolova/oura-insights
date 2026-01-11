import Foundation

public struct OuraToken: Identifiable, Codable, Equatable {
    public let id: String
    public var accessToken: String
    public var refreshToken: String?
    public var expiresAt: Date?
    public var tokenType: String
    public var scope: String?
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: String = "default",
        accessToken: String,
        refreshToken: String? = nil,
        expiresAt: Date? = nil,
        tokenType: String = "Bearer",
        scope: String? = nil
    ) {
        self.id = id
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
        self.tokenType = tokenType
        self.scope = scope
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    public var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() >= expiresAt
    }
    
    public var expiresIn: TimeInterval? {
        guard let expiresAt = expiresAt else { return nil }
        return expiresAt.timeIntervalSince(Date())
    }
    
    public var authorizationHeader: String {
        "\(tokenType) \(accessToken)"
    }
}
