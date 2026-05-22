import Foundation

struct TidePoint: Identifiable {
    let id = UUID()
    let time: Date
    let height: Double // meters
}

struct TideExtreme: Identifiable {
    let id = UUID()
    let time: Date
    let height: Double
    let type: TideType

    enum TideType: String {
        case high = "満潮"
        case low = "干潮"
    }
}

struct TideInfo {
    let date: Date
    let stationName: String
    let hourlyHeights: [TidePoint]
    let extremes: [TideExtreme]

    var currentHeight: Double {
        let now = Date()
        guard let closest = hourlyHeights.min(by: {
            abs($0.time.timeIntervalSince(now)) < abs($1.time.timeIntervalSince(now))
        }) else { return 0 }
        return closest.height
    }
}
