import Foundation
import SwiftData

@Model
final class OuraToken {
    @Attribute(.unique) var id: String
    var accessToken: String
    var refreshToken: String?
    var expiresAt: Date?
    var tokenType: String
    var scope: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(
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
    
    var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() >= expiresAt
    }
}
