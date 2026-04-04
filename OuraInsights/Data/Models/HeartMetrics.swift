import SwiftData
import Foundation

@Model
final class HeartMetrics {
    @Attribute(.unique) var id: String
    var date: Date
    var averageHRV: Double?
    var restingHeartRate: Double?
    var temperatureDeviation: Double?

    init(
        id: String,
        date: Date,
        averageHRV: Double? = nil,
        restingHeartRate: Double? = nil,
        temperatureDeviation: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.averageHRV = averageHRV
        self.restingHeartRate = restingHeartRate
        self.temperatureDeviation = temperatureDeviation
    }
}
