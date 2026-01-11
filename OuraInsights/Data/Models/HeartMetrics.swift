import Foundation
import SwiftData

@Model
final class HeartMetrics {
    @Attribute(.unique) var id: String
    var date: Date
    var averageHRV: Double?
    var lowestHRV: Double?
    var highestHRV: Double?
    var averageHeartRate: Double?
    var lowestHeartRate: Double?
    var highestHeartRate: Double?
    var restingHeartRate: Double?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: String,
        date: Date,
        averageHRV: Double? = nil,
        lowestHRV: Double? = nil,
        highestHRV: Double? = nil,
        averageHeartRate: Double? = nil,
        lowestHeartRate: Double? = nil,
        highestHeartRate: Double? = nil,
        restingHeartRate: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.averageHRV = averageHRV
        self.lowestHRV = lowestHRV
        self.highestHRV = highestHRV
        self.averageHeartRate = averageHeartRate
        self.lowestHeartRate = lowestHeartRate
        self.highestHeartRate = highestHeartRate
        self.restingHeartRate = restingHeartRate
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
