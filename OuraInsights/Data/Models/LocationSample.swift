import Foundation
import SwiftData

@Model
final class LocationSample {
    @Attribute(.unique) var id: String
    var date: Date
    var latitude: Double
    var longitude: Double
    var altitude: Double?
    var horizontalAccuracy: Double?
    var createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        date: Date,
        latitude: Double,
        longitude: Double,
        altitude: Double? = nil,
        horizontalAccuracy: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.horizontalAccuracy = horizontalAccuracy
        self.createdAt = Date()
    }
}
