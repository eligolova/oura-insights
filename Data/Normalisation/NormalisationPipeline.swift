import Foundation
import SwiftData

struct NormalisationPipeline {
    func run(context: ModelContext) throws {
        try normaliseSleep(context: context)
        try normaliseReadiness(context: context)
    }

    private func normaliseSleep(context: ModelContext) throws {
        let rawRecords = try context.fetch(FetchDescriptor<RawOuraSleepRecord>())

        for rawRecord in rawRecords {
            let sourceRecordID = rawRecord.ouraID
            let descriptor = FetchDescriptor<SleepSession>(
                predicate: #Predicate { $0.sourceRecordID == sourceRecordID }
            )
            let existing = try context.fetch(descriptor).first

            let startDate = rawRecord.bedtimeStart ?? rawRecord.day
            let endDate = rawRecord.bedtimeEnd ?? rawRecord.day.addingTimeInterval(TimeInterval(rawRecord.totalSleepSeconds))
            let sleepSession = existing ?? SleepSession(
                sourceRecordID: sourceRecordID,
                day: rawRecord.day,
                startDate: startDate,
                endDate: endDate
            )

            sleepSession.day = rawRecord.day
            sleepSession.startDate = startDate
            sleepSession.endDate = endDate
            sleepSession.totalSleepSeconds = rawRecord.totalSleepSeconds
            sleepSession.score = rawRecord.score

            if existing == nil {
                context.insert(sleepSession)
            }
        }
    }

    private func normaliseReadiness(context: ModelContext) throws {
        let rawRecords = try context.fetch(FetchDescriptor<RawOuraReadinessRecord>())

        for rawRecord in rawRecords {
            let sourceRecordID = rawRecord.ouraID
            let descriptor = FetchDescriptor<ReadinessScore>(
                predicate: #Predicate { $0.sourceRecordID == sourceRecordID }
            )
            let existing = try context.fetch(descriptor).first
            let readiness = existing ?? ReadinessScore(sourceRecordID: sourceRecordID, date: rawRecord.day)

            readiness.date = rawRecord.day
            readiness.score = rawRecord.score

            if existing == nil {
                context.insert(readiness)
            }
        }
    }
}
