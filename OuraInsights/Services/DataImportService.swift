import Foundation
import SwiftData
import OuraInsightsCore

public enum DataImportError: Error, LocalizedError {
    case noToken
    case apiError(OuraAPIError)
    case persistenceError(Error)
    case parseError(String)
    
    public var errorDescription: String? {
        switch self {
        case .noToken:
            return "No Oura Personal Access Token configured"
        case .apiError(let error):
            return error.localizedDescription
        case .persistenceError(let error):
            return "Failed to save data: \(error.localizedDescription)"
        case .parseError(let message):
            return "Failed to parse data: \(message)"
        }
    }
}

@MainActor
public final class DataImportService: ObservableObject {
    private let apiClient: OuraAPIClient
    private let keychain: KeychainService
    
    @Published public var isImporting = false
    @Published public var lastImportDate: Date?
    @Published public var lastError: DataImportError?
    @Published public var importProgress: String = ""
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()
    
    private let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    public init(apiClient: OuraAPIClient = OuraAPIClient(), keychain: KeychainService = .shared) {
        self.apiClient = apiClient
        self.keychain = keychain
    }
    
    // MARK: - Token Management
    
    public var hasToken: Bool {
        keychain.hasOuraPAT()
    }
    
    public func configureToken() throws {
        let token = try keychain.loadOuraPAT()
        apiClient.setToken(token)
    }
    
    public func validateToken() async throws -> Bool {
        try configureToken()
        _ = try await apiClient.validateToken()
        return true
    }
    
    public func saveToken(_ token: String) throws {
        try keychain.saveOuraPAT(token)
        apiClient.setToken(token)
    }
    
    public func deleteToken() throws {
        try keychain.deleteOuraPAT()
        apiClient.clearToken()
    }
    
    // MARK: - Data Import
    
    public func importRecentData(days: Int = 30, modelContext: ModelContext) async throws {
        guard hasToken else {
            throw DataImportError.noToken
        }
        
        isImporting = true
        lastError = nil
        importProgress = "Starting import..."
        
        defer {
            isImporting = false
        }
        
        do {
            try configureToken()
            
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate) ?? endDate
            
            importProgress = "Fetching sleep data..."
            let sleepData = try await apiClient.fetchSleepDocuments(startDate: startDate, endDate: endDate)
            
            importProgress = "Fetching readiness data..."
            let readinessData = try await apiClient.fetchDailyReadiness(startDate: startDate, endDate: endDate)
            
            importProgress = "Fetching activity data..."
            let activityData = try await apiClient.fetchDailyActivity(startDate: startDate, endDate: endDate)
            
            importProgress = "Saving sleep data..."
            try await saveSleepData(sleepData, modelContext: modelContext)
            
            importProgress = "Saving readiness data..."
            try await saveReadinessData(readinessData, modelContext: modelContext)
            
            importProgress = "Saving activity data..."
            try await saveActivityData(activityData, modelContext: modelContext)
            
            lastImportDate = Date()
            importProgress = "Import complete!"
            
        } catch let error as OuraAPIError {
            lastError = .apiError(error)
            throw DataImportError.apiError(error)
        } catch {
            lastError = .persistenceError(error)
            throw DataImportError.persistenceError(error)
        }
    }
    
    // MARK: - Data Persistence
    
    private func saveSleepData(_ data: [SleepDocumentResponse], modelContext: ModelContext) async throws {
        for item in data {
            guard let date = dateFormatter.date(from: item.day) else { continue }
            
            let descriptor = FetchDescriptor<SleepSession>(
                predicate: #Predicate { $0.id == item.id }
            )
            
            let existing = try modelContext.fetch(descriptor)
            
            if let session = existing.first {
                // Update existing record
                session.date = date
                session.bedtimeStart = parseISO8601Date(item.bedtimeStart)
                session.bedtimeEnd = parseISO8601Date(item.bedtimeEnd)
                session.totalSleepDuration = item.totalSleepDuration
                session.remSleepDuration = item.remSleepDuration
                session.deepSleepDuration = item.deepSleepDuration
                session.lightSleepDuration = item.lightSleepDuration
                session.awakeTime = item.awakeTime
                session.efficiency = item.efficiency
                session.latency = item.latency
                session.updatedAt = Date()
            } else {
                // Insert new record
                let session = SleepSession(
                    id: item.id,
                    date: date,
                    bedtimeStart: parseISO8601Date(item.bedtimeStart),
                    bedtimeEnd: parseISO8601Date(item.bedtimeEnd),
                    totalSleepDuration: item.totalSleepDuration,
                    remSleepDuration: item.remSleepDuration,
                    deepSleepDuration: item.deepSleepDuration,
                    lightSleepDuration: item.lightSleepDuration,
                    awakeTime: item.awakeTime,
                    efficiency: item.efficiency,
                    latency: item.latency
                )
                modelContext.insert(session)
            }
        }
        
        try modelContext.save()
    }
    
    private func saveReadinessData(_ data: [DailyReadinessResponse], modelContext: ModelContext) async throws {
        for item in data {
            guard let date = dateFormatter.date(from: item.day) else { continue }
            
            let descriptor = FetchDescriptor<ReadinessScore>(
                predicate: #Predicate { $0.id == item.id }
            )
            
            let existing = try modelContext.fetch(descriptor)
            
            if let score = existing.first {
                // Update existing record
                score.date = date
                score.score = item.score
                score.temperatureDeviation = item.temperatureDeviation
                score.activityBalance = item.contributors?.activityBalance
                score.bodyTemperature = item.contributors?.bodyTemperature
                score.hrvBalance = item.contributors?.hrvBalance
                score.previousDayActivity = item.contributors?.previousDayActivity
                score.previousNight = item.contributors?.previousNight
                score.recoveryIndex = item.contributors?.recoveryIndex
                score.restingHeartRate = item.contributors?.restingHeartRate
                score.sleepBalance = item.contributors?.sleepBalance
                score.updatedAt = Date()
            } else {
                // Insert new record
                let score = ReadinessScore(
                    id: item.id,
                    date: date,
                    score: item.score,
                    temperatureDeviation: item.temperatureDeviation,
                    activityBalance: item.contributors?.activityBalance,
                    bodyTemperature: item.contributors?.bodyTemperature,
                    hrvBalance: item.contributors?.hrvBalance,
                    previousDayActivity: item.contributors?.previousDayActivity,
                    previousNight: item.contributors?.previousNight,
                    recoveryIndex: item.contributors?.recoveryIndex,
                    restingHeartRate: item.contributors?.restingHeartRate,
                    sleepBalance: item.contributors?.sleepBalance
                )
                modelContext.insert(score)
            }
        }
        
        try modelContext.save()
    }
    
    private func saveActivityData(_ data: [DailyActivityResponse], modelContext: ModelContext) async throws {
        for item in data {
            guard let date = dateFormatter.date(from: item.day) else { continue }
            
            let descriptor = FetchDescriptor<ActivityDay>(
                predicate: #Predicate { $0.id == item.id }
            )
            
            let existing = try modelContext.fetch(descriptor)
            
            if let activity = existing.first {
                // Update existing record
                activity.date = date
                activity.score = item.score
                activity.activeCalories = item.activeCalories
                activity.totalCalories = item.totalCalories
                activity.steps = item.steps
                activity.equivalentWalkingDistance = item.equivalentWalkingDistance
                activity.highActivityTime = item.highActivityTime
                activity.mediumActivityTime = item.mediumActivityTime
                activity.lowActivityTime = item.lowActivityTime
                activity.sedentaryTime = item.sedentaryTime
                activity.restingTime = item.restingTime
                activity.inactivityAlerts = item.inactivityAlerts
                activity.meetDailyTargets = item.contributors?.meetDailyTargets
                activity.moveEveryHour = item.contributors?.moveEveryHour
                activity.recoveryTime = item.contributors?.recoveryTime
                activity.trainingFrequency = item.contributors?.trainingFrequency
                activity.trainingVolume = item.contributors?.trainingVolume
                activity.updatedAt = Date()
            } else {
                // Insert new record
                let activity = ActivityDay(
                    id: item.id,
                    date: date,
                    score: item.score,
                    activeCalories: item.activeCalories,
                    totalCalories: item.totalCalories,
                    steps: item.steps,
                    equivalentWalkingDistance: item.equivalentWalkingDistance,
                    highActivityTime: item.highActivityTime,
                    mediumActivityTime: item.mediumActivityTime,
                    lowActivityTime: item.lowActivityTime,
                    sedentaryTime: item.sedentaryTime,
                    restingTime: item.restingTime,
                    inactivityAlerts: item.inactivityAlerts,
                    meetDailyTargets: item.contributors?.meetDailyTargets,
                    moveEveryHour: item.contributors?.moveEveryHour,
                    recoveryTime: item.contributors?.recoveryTime,
                    trainingFrequency: item.contributors?.trainingFrequency,
                    trainingVolume: item.contributors?.trainingVolume
                )
                modelContext.insert(activity)
            }
        }
        
        try modelContext.save()
    }
    
    // MARK: - Helpers
    
    private func parseISO8601Date(_ string: String?) -> Date? {
        guard let string = string else { return nil }
        
        // Try with fractional seconds first
        if let date = iso8601Formatter.date(from: string) {
            return date
        }
        
        // Fallback to without fractional seconds
        let fallbackFormatter = ISO8601DateFormatter()
        fallbackFormatter.formatOptions = [.withInternetDateTime]
        return fallbackFormatter.date(from: string)
    }
}
