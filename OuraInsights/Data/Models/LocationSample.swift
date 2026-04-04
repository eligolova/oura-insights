import SwiftData
import Foundation

/// Stores a reduced-precision location sample. Lat/lon are rounded before
/// persisting to protect privacy (no background tracking).
@Model
final class LocationSample {
    @Attribute(.unique) var id: String
    var timestamp: Date
    var latitude: Double
    var longitude: Double

    init(id: String, timestamp: Date, latitude: Double, longitude: Double) {
        self.id = id
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
    }
}
