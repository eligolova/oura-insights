import SwiftData
import Foundation

@Model
final class ActivityDay {
    @Attribute(.unique) var id: String
    var date: Date
    var steps: Int
    var activeCalories: Int
    var totalCalories: Int
    var score: Int?

    init(
        id: String,
        date: Date,
        steps: Int = 0,
        activeCalories: Int = 0,
        totalCalories: Int = 0,
        score: Int? = nil
    ) {
        self.id = id
        self.date = date
        self.steps = steps
        self.activeCalories = activeCalories
        self.totalCalories = totalCalories
        self.score = score
    }
}
