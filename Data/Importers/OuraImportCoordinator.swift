import Foundation
import SwiftData

enum OuraImportError: LocalizedError, Equatable {
    case missingToken

    var errorDescription: String? {
        switch self {
        case .missingToken:
            "Connect Oura before starting a sync."
        }
    }
}

struct OuraImportCoordinator {
    let client: OuraAPIClient
    let normalisationPipeline: NormalisationPipeline
    let tokenStore: OuraTokenStore
    let calendar: Calendar

    init(
        client: OuraAPIClient = OuraClient(),
        normalisationPipeline: NormalisationPipeline = NormalisationPipeline(),
        tokenStore: OuraTokenStore = KeychainOuraTokenStore.shared,
        calendar: Calendar = .current
    ) {
        self.client = client
        self.normalisationPipeline = normalisationPipeline
        self.tokenStore = tokenStore
        self.calendar = calendar
    }

    func refresh(modelContainer: ModelContainer, today: Date = .now) async throws {
        guard let token = try tokenStore.load() else {
            throw OuraImportError.missingToken
        }

        let context = ModelContext(modelContainer)
        let endDate = calendar.startOfDay(for: today)
        let startDate = try incrementalStartDate(context: context, endDate: endDate)

        let sleepRecords = try await client.fetchDailySleep(
            accessToken: token.accessToken,
            startDate: startDate,
            endDate: endDate
        )
        let readinessRecords = try await client.fetchDailyReadiness(
            accessToken: token.accessToken,
            startDate: startDate,
            endDate: endDate
        )

        try upsertSleepRecords(sleepRecords, context: context)
        try upsertReadinessRecords(readinessRecords, context: context)
        try normalisationPipeline.run(context: context)
        try updateSyncMetadata(context: context, token: token, syncedAt: today)
        try context.save()
    }

    private func incrementalStartDate(context: ModelContext, endDate: Date) throws -> Date {
        let latestSleep = try context.fetch(FetchDescriptor<RawOuraSleepRecord>(
            sortBy: [SortDescriptor(\.day, order: .reverse)]
        )).first?.day
        let latestReadiness = try context.fetch(FetchDescriptor<RawOuraReadinessRecord>(
            sortBy: [SortDescriptor(\.day, order: .reverse)]
        )).first?.day

        let latestImportedDay = [latestSleep, latestReadiness]
            .compactMap { $0 }
            .max()

        if let latestImportedDay,
           let rewindDate = calendar.date(byAdding: .day, value: -1, to: latestImportedDay) {
            return rewindDate
        }

        return calendar.date(byAdding: .day, value: -30, to: endDate) ?? endDate
    }

    private func upsertSleepRecords(_ records: [OuraDailySleepRecord], context: ModelContext) throws {
        for record in records {
            guard let day = OuraDateParser.parseDay(record.day) else {
                continue
            }
            let ouraID = record.id

            let descriptor = FetchDescriptor<RawOuraSleepRecord>(
                predicate: #Predicate { $0.ouraID == ouraID }
            )
            let existing = try context.fetch(descriptor).first

            let rawRecord = existing ?? RawOuraSleepRecord(ouraID: ouraID, day: day)
            rawRecord.day = day
            rawRecord.bedtimeStart = OuraDateParser.parseTimestamp(record.bedtimeStart)
            rawRecord.bedtimeEnd = OuraDateParser.parseTimestamp(record.bedtimeEnd)
            rawRecord.totalSleepSeconds = record.totalSleepDuration ?? 0
            rawRecord.deepSleepSeconds = record.deepSleepDuration ?? 0
            rawRecord.remSleepSeconds = record.remSleepDuration ?? 0
            rawRecord.lightSleepSeconds = record.lightSleepDuration ?? 0
            rawRecord.awakeSeconds = record.awakeTime ?? 0
            rawRecord.score = record.score ?? 0
            rawRecord.importedAt = .now

            if existing == nil {
                context.insert(rawRecord)
            }
        }
    }

    private func upsertReadinessRecords(_ records: [OuraDailyReadinessRecord], context: ModelContext) throws {
        for record in records {
            guard let day = OuraDateParser.parseDay(record.day) else {
                continue
            }
            let ouraID = record.id

            let descriptor = FetchDescriptor<RawOuraReadinessRecord>(
                predicate: #Predicate { $0.ouraID == ouraID }
            )
            let existing = try context.fetch(descriptor).first

            let rawRecord = existing ?? RawOuraReadinessRecord(ouraID: ouraID, day: day)
            rawRecord.day = day
            rawRecord.score = record.score ?? 0
            rawRecord.importedAt = .now

            if existing == nil {
                context.insert(rawRecord)
            }
        }
    }

    private func updateSyncMetadata(context: ModelContext, token: OuraSessionToken, syncedAt: Date) throws {
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
        storedToken.lastSyncedAt = syncedAt
        storedToken.updatedAt = .now

        if try context.fetch(descriptor).isEmpty {
            context.insert(storedToken)
        }
    }

    private func ensureCurrentUser(in context: ModelContext) throws -> User {
        if let existing = try context.fetch(FetchDescriptor<User>()).first {
            return existing
        }

        let user = User()
        context.insert(user)
        return user
    }
}
