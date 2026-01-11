import XCTest
@testable import OuraInsightsCore

final class KeychainServiceTests: XCTestCase {
    
    var keychainService: KeychainService!
    let testKey = "test-keychain-key"
    
    override func setUp() {
        super.setUp()
        keychainService = KeychainService(serviceName: "com.test.oura-insights-tests")
        try? keychainService.delete(forKey: testKey)
    }
    
    override func tearDown() {
        try? keychainService.delete(forKey: testKey)
        keychainService = nil
        super.tearDown()
    }
    
    func testSaveAndLoadString() throws {
        let testValue = "test-string-value"
        
        try keychainService.save(testValue, forKey: testKey)
        let loadedValue: String = try keychainService.load(forKey: testKey)
        
        XCTAssertEqual(loadedValue, testValue)
    }
    
    func testSaveAndLoadCodable() throws {
        let testToken = OuraToken(
            id: "test-token",
            accessToken: "access-123",
            refreshToken: "refresh-456",
            expiresAt: Date().addingTimeInterval(3600),
            tokenType: "Bearer",
            scope: "daily_sleep"
        )
        
        try keychainService.save(testToken, forKey: testKey)
        let loadedToken: OuraToken = try keychainService.load(forKey: testKey)
        
        XCTAssertEqual(loadedToken.id, testToken.id)
        XCTAssertEqual(loadedToken.accessToken, testToken.accessToken)
        XCTAssertEqual(loadedToken.refreshToken, testToken.refreshToken)
        XCTAssertEqual(loadedToken.tokenType, testToken.tokenType)
        XCTAssertEqual(loadedToken.scope, testToken.scope)
    }
    
    func testUpdateExistingItem() throws {
        let originalValue = "original"
        let updatedValue = "updated"
        
        try keychainService.save(originalValue, forKey: testKey)
        try keychainService.save(updatedValue, forKey: testKey)
        
        let loadedValue: String = try keychainService.load(forKey: testKey)
        XCTAssertEqual(loadedValue, updatedValue)
    }
    
    func testDeleteItem() throws {
        let testValue = "to-be-deleted"
        
        try keychainService.save(testValue, forKey: testKey)
        XCTAssertTrue(keychainService.exists(forKey: testKey))
        
        try keychainService.delete(forKey: testKey)
        XCTAssertFalse(keychainService.exists(forKey: testKey))
    }
    
    func testLoadNonExistentItem() {
        XCTAssertThrowsError(try keychainService.load(forKey: "non-existent-key") as String) { error in
            guard let keychainError = error as? KeychainError else {
                XCTFail("Expected KeychainError")
                return
            }
            
            if case .itemNotFound = keychainError {
                // Expected
            } else {
                XCTFail("Expected itemNotFound error")
            }
        }
    }
    
    func testExists() throws {
        XCTAssertFalse(keychainService.exists(forKey: testKey))
        
        try keychainService.save("test", forKey: testKey)
        XCTAssertTrue(keychainService.exists(forKey: testKey))
    }
    
    func testDeleteNonExistentItemDoesNotThrow() {
        XCTAssertNoThrow(try keychainService.delete(forKey: "non-existent"))
    }
    
    func testKeychainErrorDescriptions() {
        let errors: [KeychainError] = [
            .duplicateEntry,
            .itemNotFound,
            .unexpectedStatus(-25300),
            .invalidData,
            .encodingFailed,
            .decodingFailed
        ]
        
        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }
}
