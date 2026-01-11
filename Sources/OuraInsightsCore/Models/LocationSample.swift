import Foundation

public struct LocationSample: Identifiable, Codable, Equatable {
    public let id: String
    public var date: Date
    public var latitude: Double
    public var longitude: Double
    public var altitude: Double?
    public var horizontalAccuracy: Double?
    public var createdAt: Date
    
    public init(
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
    
    public var reducedPrecisionLatitude: Double {
        (latitude * 100).rounded() / 100
    }
    
    public var reducedPrecisionLongitude: Double {
        (longitude * 100).rounded() / 100
    }
    
    public func distance(to other: LocationSample) -> Double {
        haversineDistance(
            lat1: latitude,
            lon1: longitude,
            lat2: other.latitude,
            lon2: other.longitude
        )
    }
    
    private func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let R = 6371.0
        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180
        let a = sin(dLat/2) * sin(dLat/2) +
                cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
                sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        return R * c
    }
}
