import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class OuraSessionViewModel {
    var clientID: String {
        didSet {
            userDefaults.set(clientID, forKey: Self.clientIDKey)
        }
    }
    var clientSecret = ""
    var isAuthorising = false
    var isSyncing = false
    var lastErrorMessage: String?
    var connectionSummary = "Not connected"
    var syncSummary = "No Oura sync has been run yet."
    var lastAuthorisationURLString: String?
    var latestSleepSummary = "No sleep data imported yet."
    var latestReadinessSummary = "No readiness data imported yet."

    let redirectURI = OuraAuthClient.defaultRedirectURI
    let scopeSummary = OuraAuthClient.defaultScopes.joined(separator: ", ")

    private let modelContainer: ModelContainer
    private let authClient: OuraAuthClient
    private let importCoordinator: OuraImportCoordinator
    private let tokenStore: OuraTokenStore
    private let userDefaults: UserDefaults
    private let calendar: Calendar
    private var pendingState: String?
    private var hasBootstrapped = false

    private static let clientIDKey = "oura.clientID"

    init(
        modelContainer: ModelContainer,
        authClient: OuraAuthClient = OuraAuthClient(),
        importCoordinator: OuraImportCoordinator? = nil,
        tokenStore: OuraTokenStore = KeychainOuraTokenStore.shared,
        userDefaults: UserDefaults = .standard,
        calendar: Calendar = .current
    ) {
        self.modelContainer = modelContainer
        self.authClient = authClient
        self.tokenStore = tokenStore
        self.userDefaults = userDefaults
        self.calendar = calendar
        self.clientID = userDefaults.string(forKey: Self.clientIDKey) ?? ""
        self.importCoordinator = importCoordinator ?? OuraImportCoordinator(tokenStore: tokenStore, calendar: calendar)
        refreshLocalState()
    }

    var isConnected: Bool {
        connectionSummary.hasPrefix("Connected")
    }

    func bootstrap() async {
        guard hasBootstrapped == false else {
            return
        }

        hasBootstrapped = true
        refreshLocalState()

        if isConnected {
            await refresh()
        }
    }

    func makeAuthorisationURL() throws -> URL {
        guard clientSecret.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw OuraAuthError.missingClientSecret
        }

        let state = UUID().uuidString
        pendingState = state
        isAuthorising = true
        lastErrorMessage = nil

        let url = try authClient.makeAuthorisationURL(
            request: OuraAuthorisationRequest(
                clientID: clientID.trimmingCharacters(in: .whitespacesAndNewlines),
                redirectURI: redirectURI,
                scopes: OuraAuthClient.defaultScopes,
                state: state
            )
        )
        lastAuthorisationURLString = url.absoluteString
        syncSummary = "Waiting for Oura. If the browser shows 400 invalid_request, check the client ID and exact redirect URI in the Oura dashboard."
        return url
    }

    func handleIncomingURL(_ url: URL) async {
        do {
            let result = try authClient.parseAuthorisationCallback(url: url, expectedState: pendingState)
            let token = try await authClient.exchangeCodeForToken(
                request: OuraTokenExchangeRequest(
                    code: result.code,
                    clientID: clientID.trimmingCharacters(in: .whitespacesAndNewlines),
                    clientSecret: clientSecret.trimmingCharacters(in: .whitespacesAndNewlines),
                    redirectURI: redirectURI
                )
            )
            try tokenStore.save(token)
            try persistTokenMetadata(token)
            pendingState = nil
            isAuthorising = false
            lastAuthorisationURLString = nil
            refreshLocalState()
            await refresh()
        } catch {
            pendingState = nil
            isAuthorising = false
            lastErrorMessage = error.localizedDescription
            refreshLocalState()
        }
    }

    func refresh() async {
        isSyncing = true
        lastErrorMessage = nil

        do {
            try await importCoordinator.refresh(modelContainer: modelContainer)
            refreshLocalState()
        } catch {
            lastErrorMessage = error.localizedDescription
            refreshLocalState()
        }

        isSyncing = false
    }

    func disconnect() {
        do {
            try tokenStore.clear()
            try clearPersistedTokenMetadata()
            pendingState = nil
            isAuthorising = false
            isSyncing = false
            lastErrorMessage = nil
            lastAuthorisationURLString = nil
            refreshLocalState()
        } catch {
            pendingState = nil
            isAuthorising = false
            isSyncing = false
            lastErrorMessage = error.localizedDescription
        }
    }

    private func persistTokenMetadata(_ token: OuraSessionToken) throws {
        let context = ModelContext(modelContainer)
        let user = try ensureCurrentUser(in: context)
        let userID = user.id
        let descriptor = FetchDescriptor<OuraToken>(
            predicate: #Predicate { $0.userID == userID }
        )
        let storedToken = try context.fetch(descriptor).first ?? OuraToken(userID: user.id)
        storedToken.keychainAccount = "default"
        storedToken.scopeSummary = token.scopes.joined(separator: ", ")
        storedToken.tokenType = token.tokenType
        storedToken.expiresAt = token.expiresAt
        storedToken.updatedAt = .now

        if try context.fetch(descriptor).isEmpty {
            context.insert(storedToken)
        }

        try context.save()
    }

    private func clearPersistedTokenMetadata() throws {
        let context = ModelContext(modelContainer)
        let tokens = try context.fetch(FetchDescriptor<OuraToken>())
        for token in tokens {
            context.delete(token)
        }
        try context.save()
    }

    private func refreshLocalState() {
        let context = ModelContext(modelContainer)
        let tokenMetadata = try? context.fetch(FetchDescriptor<OuraToken>()).first
        let latestSleep = try? context.fetch(FetchDescriptor<SleepSession>(
            sortBy: [SortDescriptor(\.day, order: .reverse)]
        )).first
        let latestReadiness = try? context.fetch(FetchDescriptor<ReadinessScore>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )).first

        if let tokenMetadata {
            connectionSummary = "Connected to Oura until \(Self.timestampFormatter.string(from: tokenMetadata.expiresAt))"
            if let lastSyncedAt = tokenMetadata.lastSyncedAt {
                syncSummary = "Last synced \(Self.timestampFormatter.string(from: lastSyncedAt))."
            } else {
                syncSummary = "Connected, but not synced yet."
            }
        } else {
            connectionSummary = "Not connected"
            syncSummary = "No Oura sync has been run yet."
        }

        if let latestSleep {
            let durationHours = Double(latestSleep.totalSleepSeconds) / 3600
            latestSleepSummary = "\(Self.dayFormatter.string(from: latestSleep.day)): score \(latestSleep.score), \(String(format: "%.1f", durationHours)) h asleep."
        } else {
            latestSleepSummary = "No sleep data imported yet."
        }

        if let latestReadiness {
            latestReadinessSummary = "\(Self.dayFormatter.string(from: latestReadiness.date)): readiness \(latestReadiness.score)."
        } else {
            latestReadinessSummary = "No readiness data imported yet."
        }
    }

    private func ensureCurrentUser(in context: ModelContext) throws -> User {
        if let existing = try context.fetch(FetchDescriptor<User>()).first {
            return existing
        }

        let user = User()
        context.insert(user)
        try context.save()
        return user
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateStyle = .medium
        return formatter
    }()

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
