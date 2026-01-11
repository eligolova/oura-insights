import Foundation
import Security

public enum KeychainError: Error, LocalizedError {
    case duplicateEntry
    case itemNotFound
    case unexpectedStatus(OSStatus)
    case invalidData
    case encodingFailed
    case decodingFailed
    
    public var errorDescription: String? {
        switch self {
        case .duplicateEntry:
            return "An item with this key already exists"
        case .itemNotFound:
            return "No item found for this key"
        case .unexpectedStatus(let status):
            return "Keychain error: \(status)"
        case .invalidData:
            return "Invalid data format"
        case .encodingFailed:
            return "Failed to encode data"
        case .decodingFailed:
            return "Failed to decode data"
        }
    }
}

public protocol KeychainServiceProtocol {
    func save<T: Encodable>(_ item: T, forKey key: String) throws
    func load<T: Decodable>(forKey key: String) throws -> T
    func delete(forKey key: String) throws
    func exists(forKey key: String) -> Bool
}

public final class KeychainService: KeychainServiceProtocol {
    private let serviceName: String
    private let accessGroup: String?
    
    public static let shared = KeychainService()
    
    public init(serviceName: String = "com.personal.oura-insights", accessGroup: String? = nil) {
        self.serviceName = serviceName
        self.accessGroup = accessGroup
    }
    
    public func save<T: Encodable>(_ item: T, forKey key: String) throws {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(item) else {
            throw KeychainError.encodingFailed
        }
        
        if exists(forKey: key) {
            try update(data: data, forKey: key)
        } else {
            try add(data: data, forKey: key)
        }
    }
    
    public func load<T: Decodable>(forKey key: String) throws -> T {
        var query = baseQuery(forKey: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.itemNotFound
            }
            throw KeychainError.unexpectedStatus(status)
        }
        
        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }
        
        let decoder = JSONDecoder()
        guard let item = try? decoder.decode(T.self, from: data) else {
            throw KeychainError.decodingFailed
        }
        
        return item
    }
    
    public func delete(forKey key: String) throws {
        let query = baseQuery(forKey: key)
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    public func exists(forKey key: String) -> Bool {
        var query = baseQuery(forKey: key)
        query[kSecReturnData as String] = false
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    private func add(data: Data, forKey key: String) throws {
        var query = baseQuery(forKey: key)
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            if status == errSecDuplicateItem {
                throw KeychainError.duplicateEntry
            }
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    private func update(data: Data, forKey key: String) throws {
        let query = baseQuery(forKey: key)
        let attributes: [String: Any] = [kSecValueData as String: data]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    private func baseQuery(forKey key: String) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        return query
    }
}
