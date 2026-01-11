import Foundation
import SwiftData
import os.log

enum DataImportError: Error, LocalizedError {
    case noModelContext
    case importFailed(String)
    case saveFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .noModelContext:
            return "Model context not available"
        case .importFailed(let message):
            return "Import failed: \(message)"
        case .saveFailed(let error):
            return "Failed to save data: \(error.localizedDescription)"
        }
    }
}

struct ImportResult {
    let sleepCount: Int
    let readinessCount: Int
    let activityCount: Int
    let startDate: Date
    let endDate: Date
    
    var totalCount: Int {
        sleepCount + readinessCount + activityCount
    }
}

@MainActor
final class DataImportService {
    private let modelContext: ModelContext
    private let logger = Logger(subsystem: "com.personal.oura-insights", category: "DataImportService")
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func importSleepData(_ data: [DailySleepData]) throws -> Int {
        var importedCount = 0
        
        for item in data {
            guard let dayDate = item.dayDate else {
                logger.warning("Skipping sleep data with invalid date: \(item.day)")
                continue
            }
            
            let descriptor = FetchDescriptor<SleepSession>(
                predicate: #Predicate { $0.id == item.id }
            )
            
            let existing = try? modelContext.fetch(descriptor)
            
            if let existingSession = existing?.first {
                updateSleepSession(existingSession, with: item, date: dayDate)
                logger.debug("Updated sleep session: \(item.id)")
            } else {
                let newSession = createSleepSession(from: item, date: dayDate)
                modelContext.insert(newSession)
                importedCount += 1
                logger.debug("Created sleep session: \(item.id)")
            }
        }
        
        do {
            try modelContext.save()
            logger.info("Imported \(importedCount) sleep sessions")
        } catch {
            throw DataImportError.saveFailed(error)
        }
        
        return importedCount
    }
    
    func importReadinessData(_ data: [DailyReadinessData]) throws -> Int {
        var importedCount = 0
        
        for item in data {
            guard let dayDate = item.dayDate else {
                logger.warning("Skipping readiness data with invalid date: \(item.day)")
                continue
            }
            
            let descriptor = FetchDescriptor<ReadinessScore>(
                predicate: #Predicate { $0.id == item.id }
            )
            
            let existing = try? modelContext.fetch(descriptor)
            
            if let existingScore = existing?.first {
                updateReadinessScore(existingScore, with: item, date: dayDate)
                logger.debug("Updated readiness score: \(item.id)")
            } else {
                let newScore = createReadinessScore(from: item, date: dayDate)
                modelContext.insert(newScore)
                importedCount += 1
                logger.debug("Created readiness score: \(item.id)")
            }
        }
        
        do {
            try modelContext.save()
            logger.info("Imported \(importedCount) readiness scores")
        } catch {
            throw DataImportError.saveFailed(error)
        }
        
        return importedCount
    }
    
    func importActivityData(_ data: [DailyActivityData]) throws -> Int {
        var importedCount = 0
        
        for item in data {
            guard let dayDate = item.dayDate else {
                logger.warning("Skipping activity data with invalid date: \(item.day)")
                continue
            }
            
            let descriptor = FetchDescriptor<ActivityDay>(
                predicate: #Predicate { $0.id == item.id }
            )
            
            let existing = try? modelContext.fetch(descriptor)
            
            if let existingDay = existing?.first {
                updateActivityDay(existingDay, with: item, date: dayDate)
                logger.debug("Updated activity day: \(item.id)")
            } else {
                let newDay = createActivityDay(from: item, date: dayDate)
                modelContext.insert(newDay)
                importedCount += 1
                logger.debug("Created activity day: \(item.id)")
            }
        }
        
        do {
            try modelContext.save()
            logger.info("Imported \(importedCount) activity days")
        } catch {
            throw DataImportError.saveFailed(error)
        }
        
        return importedCount
    }
    
    private func createSleepSession(from data: DailySleepData, date: Date) -> SleepSession {
        SleepSession(
            id: data.id,
            date: date,
            sleepScore: data.score,
            efficiency: data.contributors?.efficiency,
            latency: data.contributors?.latency,
            restfulness: data.contributors?.restfulness,
            timing: data.contributors?.timing
        )
    }
    
    private func updateSleepSession(_ session: SleepSession, with data: DailySleepData, date: Date) {
        session.date = date
        session.sleepScore = data.score
        session.efficiency = data.contributors?.efficiency
        session.latency = data.contributors?.latency
        session.restfulness = data.contributors?.restfulness
        session.timing = data.contributors?.timing
        session.updatedAt = Date()
    }
    
    private func createReadinessScore(from data: DailyReadinessData, date: Date) -> ReadinessScore {
        ReadinessScore(
            id: data.id,
            date: date,
            score: data.score,
            temperatureDeviation: data.temperatureDeviation,
            activityBalance: data.contributors?.activityBalance,
            bodyTemperature: data.contributors?.bodyTemperature,
            hrvBalance: data.contributors?.hrvBalance,
            previousDayActivity: data.contributors?.previousDayActivity,
            previousNight: data.contributors?.previousNight,
            recoveryIndex: data.contributors?.recoveryIndex,
            restingHeartRate: data.contributors?.restingHeartRate,
            sleepBalance: data.contributors?.sleepBalance
        )
    }
    
    private func updateReadinessScore(_ score: ReadinessScore, with data: DailyReadinessData, date: Date) {
        score.date = date
        score.score = data.score
        score.temperatureDeviation = data.temperatureDeviation
        score.activityBalance = data.contributors?.activityBalance
        score.bodyTemperature = data.contributors?.bodyTemperature
        score.hrvBalance = data.contributors?.hrvBalance
        score.previousDayActivity = data.contributors?.previousDayActivity
        score.previousNight = data.contributors?.previousNight
        score.recoveryIndex = data.contributors?.recoveryIndex
        score.restingHeartRate = data.contributors?.restingHeartRate
        score.sleepBalance = data.contributors?.sleepBalance
        score.updatedAt = Date()
    }
    
    private func createActivityDay(from data: DailyActivityData, date: Date) -> ActivityDay {
        ActivityDay(
            id: data.id,
            date: date,
            score: data.score,
            activeCalories: data.activeCalories,
            totalCalories: data.totalCalories,
            steps: data.steps,
            equivalentWalkingDistance: data.equivalentWalkingDistance,
            highActivityTime: data.highActivityTime,
            mediumActivityTime: data.mediumActivityTime,
            lowActivityTime: data.lowActivityTime,
            sedentaryTime: data.sedentaryTime,
            restingTime: data.restingTime,
            inactivityAlerts: data.inactivityAlerts,
            meetDailyTargets: data.contributors?.meetDailyTargets,
            moveEveryHour: data.contributors?.moveEveryHour,
            recoveryTime: data.contributors?.recoveryTime,
            trainingFrequency: data.contributors?.trainingFrequency,
            trainingVolume: data.contributors?.trainingVolume
        )
    }
    
    private func updateActivityDay(_ day: ActivityDay, with data: DailyActivityData, date: Date) {
        day.date = date
        day.score = data.score
        day.activeCalories = data.activeCalories
        day.totalCalories = data.totalCalories
        day.steps = data.steps
        day.equivalentWalkingDistance = data.equivalentWalkingDistance
        day.highActivityTime = data.highActivityTime
        day.mediumActivityTime = data.mediumActivityTime
        day.lowActivityTime = data.lowActivityTime
        day.sedentaryTime = data.sedentaryTime
        day.restingTime = data.restingTime
        day.inactivityAlerts = data.inactivityAlerts
        day.meetDailyTargets = data.contributors?.meetDailyTargets
        day.moveEveryHour = data.contributors?.moveEveryHour
        day.recoveryTime = data.contributors?.recoveryTime
        day.trainingFrequency = data.contributors?.trainingFrequency
        day.trainingVolume = data.contributors?.trainingVolume
        day.updatedAt = Date()
    }
    
    func getLastSyncDate() -> Date? {
        let sleepDescriptor = FetchDescriptor<SleepSession>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        if let latestSleep = try? modelContext.fetch(sleepDescriptor).first {
            return latestSleep.date
        }
        
        return nil
    }
    
    func getDataCount() -> (sleep: Int, readiness: Int, activity: Int) {
        let sleepCount = (try? modelContext.fetchCount(FetchDescriptor<SleepSession>())) ?? 0
        let readinessCount = (try? modelContext.fetchCount(FetchDescriptor<ReadinessScore>())) ?? 0
        let activityCount = (try? modelContext.fetchCount(FetchDescriptor<ActivityDay>())) ?? 0
        
        return (sleepCount, readinessCount, activityCount)
    }
}
