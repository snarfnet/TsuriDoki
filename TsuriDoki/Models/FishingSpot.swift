import Foundation
import CoreLocation

struct FishingSpot: Identifiable, Codable {
    let id: UUID
    let name: String
    let latitude: Double
    let longitude: Double
    let note: String
    let createdAt: Date

    init(id: UUID = UUID(), name: String, latitude: Double, longitude: Double, note: String = "", createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.note = note
        self.createdAt = createdAt
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct CatchLog: Identifiable, Codable {
    let id: UUID
    let spotId: UUID?
    let species: String
    let timestamp: Date
    let tideHeight: Double?
    let moonPhase: Double?
    let pressure: Double?
    let temperature: Double?
    let biteScore: Int?
    let note: String

    init(id: UUID = UUID(), spotId: UUID? = nil, species: String, timestamp: Date = Date(),
         tideHeight: Double? = nil, moonPhase: Double? = nil, pressure: Double? = nil,
         temperature: Double? = nil, biteScore: Int? = nil, note: String = "") {
        self.id = id
        self.spotId = spotId
        self.species = species
        self.timestamp = timestamp
        self.tideHeight = tideHeight
        self.moonPhase = moonPhase
        self.pressure = pressure
        self.temperature = temperature
        self.biteScore = biteScore
        self.note = note
    }
}
