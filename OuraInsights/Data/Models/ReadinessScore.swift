import SwiftData
import Foundation

@Model
final class ReadinessScore {
    @Attribute(.unique) var id: String
    var date: Date
    var score: Int?
    var hrv: Double?
    var temperatureDeviation: Double?
    var recoveryIndex: Double?

    init(
        id: String,
        date: Date,
        score: Int? = nil,
        hrv: Double? = nil,
        temperatureDeviation: Double? = nil,
        recoveryIndex: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.score = score
        self.hrv = hrv
        self.temperatureDeviation = temperatureDeviation
        self.recoveryIndex = recoveryIndex
    }
}
