import Foundation
import SwiftData
import SwiftUI
import Observation
import AuthenticationServices
import os.log

@Observable
final class OuraManager {
    private let logger = Logger(subsystem: "com.personal.oura-insights", category: "OuraManager")
    
    var isAuthenticated: Bool = false
    var isSyncing: Bool = false
    var lastSyncDate: Date?
    var syncError: String?
    var authError: String?
    
    private var token: OuraToken?
    private var modelContext: ModelContext?
    private var config: OuraOAuthConfig?
    private var pendingState: String?
    
    private let authService = OuraAuthService.shared
    
    init() {
    }
    
    func configure(modelContext: ModelContext, clientId: String, clientSecret: String) {
        self.modelContext = modelContext
        self.config = OuraOAuthConfig(clientId: clientId, clientSecret: clientSecret)
        loadTokenFromSwiftData()
    }
    
    private func loadTokenFromKeychain() {
        // Token loading from Keychain will be done after SwiftData is configured
    }
    
    private func loadTokenFromSwiftData() {
        guard let modelContext = modelContext else { return }
        
        let descriptor = FetchDescriptor<OuraToken>()
        if let tokens = try? modelContext.fetch(descriptor), let existingToken = tokens.first {
            self.token = existingToken
            self.isAuthenticated = true
            logger.info("Loaded token from SwiftData")
        }
    }
    
    func startOAuthFlow() async throws -> URL {
        guard let config = config else {
            throw OuraAuthError.missingCredentials
        }
        
        pendingState = UUID().uuidString
        let url = try authService.buildAuthorizationURL(config: config, state: pendingState!)
        logger.info("Starting OAuth flow with URL: \(url.absoluteString)")
        return url
    }
    
    func handleOAuthCallback(url: URL) async throws {
        guard let config = config, let expectedState = pendingState else {
            throw OuraAuthError.missingCredentials
        }
        
        logger.info("Handling OAuth callback: \(url.absoluteString)")
        
        let code = try authService.extractAuthorizationCode(from: url, expectedState: expectedState)
        pendingState = nil
        
        logger.info("Extracted authorization code, exchanging for token...")
        
        let tokenResponse = try await authService.exchangeCodeForToken(code: code, config: config)
        
        let expiresAt = Date().addingTimeInterval(TimeInterval(tokenResponse.expiresIn))
        
        let newToken = OuraToken(
            id: "default",
            accessToken: tokenResponse.accessToken,
            refreshToken: tokenResponse.refreshToken,
            expiresAt: expiresAt,
            tokenType: tokenResponse.tokenType,
            scope: tokenResponse.scope
        )
        
        try saveToken(newToken)
        self.token = newToken
        self.isAuthenticated = true
        self.authError = nil
        
        logger.info("OAuth flow completed successfully")
    }
    
    func authenticateWithWebSession() async throws {
        guard let config = config else {
            throw OuraAuthError.missingCredentials
        }
        
        pendingState = UUID().uuidString
        let authURL = try authService.buildAuthorizationURL(config: config, state: pendingState!)
        
        let authenticator = await OuraWebAuthenticator()
        let callbackURL = try await authenticator.authenticate(url: authURL, callbackScheme: "oura-insights")
        
        try await handleOAuthCallback(url: callbackURL)
    }
    
    func disconnect() throws {
        guard let modelContext = modelContext else { return }
        
        let descriptor = FetchDescriptor<OuraToken>()
        if let tokens = try? modelContext.fetch(descriptor) {
            for token in tokens {
                modelContext.delete(token)
            }
            try modelContext.save()
        }
        
        self.token = nil
        self.isAuthenticated = false
        self.lastSyncDate = nil
        
        logger.info("Disconnected from Oura")
    }
    
    func syncData(days: Int = 30) async throws {
        guard let modelContext = modelContext, let token = token else {
            throw OuraAPIError.unauthorized
        }
        
        isSyncing = true
        syncError = nil
        
        defer { isSyncing = false }
        
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate)!
        
        let apiClient = OuraAPIClient(
            authProvider: { [weak self] in
                guard let accessToken = self?.token?.accessToken else { return nil }
                return "Bearer \(accessToken)"
            },
            tokenRefresher: { [weak self] in
                try await self?.refreshTokenIfNeeded()
            }
        )
        
        let importService = await DataImportService(modelContext: modelContext)
        
        do {
            logger.info("Fetching sleep data...")
            let sleepResponse = try await apiClient.fetchDailySleep(startDate: startDate, endDate: endDate)
            let sleepCount = try await importService.importSleepData(sleepResponse.data)
            logger.info("Imported \(sleepCount) sleep records")
            
            logger.info("Fetching readiness data...")
            let readinessResponse = try await apiClient.fetchDailyReadiness(startDate: startDate, endDate: endDate)
            let readinessCount = try await importService.importReadinessData(readinessResponse.data)
            logger.info("Imported \(readinessCount) readiness records")
            
            logger.info("Fetching activity data...")
            let activityResponse = try await apiClient.fetchDailyActivity(startDate: startDate, endDate: endDate)
            let activityCount = try await importService.importActivityData(activityResponse.data)
            logger.info("Imported \(activityCount) activity records")
            
            self.lastSyncDate = Date()
            logger.info("Sync completed successfully")
            
        } catch {
            syncError = error.localizedDescription
            logger.error("Sync failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func refreshTokenIfNeeded() async throws {
        guard let config = config,
              let refreshToken = token?.refreshToken else {
            throw OuraAuthError.missingCredentials
        }
        
        logger.info("Refreshing access token...")
        
        let tokenResponse = try await authService.refreshAccessToken(
            refreshToken: refreshToken,
            config: config
        )
        
        let expiresAt = Date().addingTimeInterval(TimeInterval(tokenResponse.expiresIn))
        
        let newToken = OuraToken(
            id: "default",
            accessToken: tokenResponse.accessToken,
            refreshToken: tokenResponse.refreshToken ?? refreshToken,
            expiresAt: expiresAt,
            tokenType: tokenResponse.tokenType,
            scope: tokenResponse.scope
        )
        
        try saveToken(newToken)
        self.token = newToken
        
        logger.info("Token refreshed successfully")
    }
    
    private func saveToken(_ token: OuraToken) throws {
        guard let modelContext = modelContext else { return }
        
        let descriptor = FetchDescriptor<OuraToken>()
        if let existingTokens = try? modelContext.fetch(descriptor) {
            for existing in existingTokens {
                modelContext.delete(existing)
            }
        }
        
        modelContext.insert(token)
        try modelContext.save()
        
        logger.info("Token saved to SwiftData")
    }
}
