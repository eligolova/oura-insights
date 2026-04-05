import Foundation
#if canImport(Security)
import Security
#endif

protocol OuraTokenStore {
    func save(_ token: OuraSessionToken) throws
    func load() throws -> OuraSessionToken?
    func clear() throws
}

enum OuraTokenStoreError: LocalizedError, Equatable {
    case unexpectedData
    case unhandledStatus(OSStatus)

    var errorDescription: String? {
        switch self {
        case .unexpectedData:
            "The saved Oura token could not be decoded."
        case let .unhandledStatus(status):
            "Keychain operation failed with status \(status)."
        }
    }
}

final class KeychainOuraTokenStore: OuraTokenStore {
    static let shared = KeychainOuraTokenStore()

    private let service = "dev.codex.oura-insights.oura-token"
    private let account = "default"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func save(_ token: OuraSessionToken) throws {
#if canImport(Security)
        let data = try encoder.encode(token)
        let query = baseQuery
        SecItemDelete(query as CFDictionary)

        let attributes = query.merging([kSecValueData as String: data]) { _, new in new }
        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw OuraTokenStoreError.unhandledStatus(status)
        }
#else
        _ = token
#endif
    }

    func load() throws -> OuraSessionToken? {
#if canImport(Security)
        var result: CFTypeRef?
        let query = baseQuery.merging([
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]) { _, new in new }
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess, let data = result as? Data else {
            throw OuraTokenStoreError.unhandledStatus(status)
        }

        do {
            return try decoder.decode(OuraSessionToken.self, from: data)
        } catch {
            throw OuraTokenStoreError.unexpectedData
        }
#else
        return nil
#endif
    }

    func clear() throws {
#if canImport(Security)
        let status = SecItemDelete(baseQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw OuraTokenStoreError.unhandledStatus(status)
        }
#endif
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}

final class InMemoryOuraTokenStore: OuraTokenStore {
    private var token: OuraSessionToken?

    func save(_ token: OuraSessionToken) throws {
        self.token = token
    }

    func load() throws -> OuraSessionToken? {
        token
    }

    func clear() throws {
        token = nil
    }
}
