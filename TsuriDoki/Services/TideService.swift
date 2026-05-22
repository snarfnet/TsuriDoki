import Foundation

actor TideService {
    static let shared = TideService()

    /// Generates simulated tide data based on simplified harmonic model
    /// In production, this would fetch from 気象庁 or NOAA API
    func fetchTideInfo(station: TideStation, date: Date) async -> TideInfo {
        let calendar = Calendar(identifier: .gregorian)
        let startOfDay = calendar.startOfDay(for: date)

        // Simplified tidal calculation using M2 (principal lunar semidiurnal) constituent
        // Period: ~12.42 hours, adjusted by station latitude
        let lunarDay = 24.8412 // hours
        let semiDiurnal = lunarDay / 2.0

        // Use station latitude to vary amplitude (higher tides at higher latitudes generally)
        let baseAmplitude = 0.8 + (abs(station.latitude - 35.0) * 0.02)
        let meanLevel = 1.2

        // Phase offset based on longitude (rough approximation)
        let phaseOffset = station.longitude * 0.05

        // Days since reference epoch for moon phase alignment
        let referenceDate = calendar.date(from: DateComponents(year: 2000, month: 1, day: 1))!
        let daysSinceRef = date.timeIntervalSince(referenceDate) / 86400.0

        // M2 phase
        let m2Phase = (daysSinceRef * 360.0 / (semiDiurnal / 24.0 * 360.0 / 360.0)) + phaseOffset
        // S2 (principal solar semidiurnal)
        let s2Phase = daysSinceRef * 360.0 / 12.0

        var hourlyPoints: [TidePoint] = []
        var extremes: [TideExtreme] = []
        var prevHeight = 0.0
        var prevSlope = 0.0

        for minute in stride(from: 0, to: 1440, by: 10) {
            let hours = Double(minute) / 60.0
            let totalHours = daysSinceRef * 24.0 + hours

            // M2 constituent (dominant)
            let m2 = baseAmplitude * cos((totalHours / semiDiurnal) * 2.0 * .pi + phaseOffset)
            // S2 constituent
            let s2 = baseAmplitude * 0.35 * cos((totalHours / 12.0) * 2.0 * .pi)
            // K1 (diurnal)
            let k1 = baseAmplitude * 0.2 * cos((totalHours / 23.93) * 2.0 * .pi)

            let height = meanLevel + m2 + s2 + k1
            let time = startOfDay.addingTimeInterval(Double(minute) * 60)

            if minute % 60 == 0 {
                hourlyPoints.append(TidePoint(time: time, height: height))
            }

            let slope = height - prevHeight
            if minute > 0 && prevSlope > 0 && slope <= 0 {
                extremes.append(TideExtreme(time: time, height: height, type: .high))
            } else if minute > 0 && prevSlope < 0 && slope >= 0 {
                extremes.append(TideExtreme(time: time, height: height, type: .low))
            }
            prevHeight = height
            prevSlope = slope
        }

        // Add hour 24 point
        let endTime = startOfDay.addingTimeInterval(24 * 3600)
        hourlyPoints.append(TidePoint(time: endTime, height: hourlyPoints.first?.height ?? meanLevel))

        return TideInfo(
            date: date,
            stationName: station.name,
            hourlyHeights: hourlyPoints,
            extremes: extremes
        )
    }
}
