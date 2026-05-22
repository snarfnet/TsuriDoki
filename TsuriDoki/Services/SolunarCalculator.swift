import Foundation

enum SolunarCalculator {
    /// Calculate moon phase for a given date (0.0 = new moon, 0.5 = full moon)
    static func moonPhase(for date: Date) -> Double {
        // Synodic month = 29.53059 days
        let synodicMonth = 29.53059
        // Reference new moon: January 6, 2000 18:14 UTC
        let calendar = Calendar(identifier: .gregorian)
        let refComponents = DateComponents(
            timeZone: TimeZone(identifier: "UTC"),
            year: 2000, month: 1, day: 6, hour: 18, minute: 14
        )
        let referenceNewMoon = calendar.date(from: refComponents)!
        let daysSince = date.timeIntervalSince(referenceNewMoon) / 86400.0
        let phase = daysSince.truncatingRemainder(dividingBy: synodicMonth)
        return (phase < 0 ? phase + synodicMonth : phase) / synodicMonth
    }

    /// Calculate solunar periods for a date and location
    static func calculate(date: Date, latitude: Double, longitude: Double) -> SolunarInfo {
        let calendar = Calendar(identifier: .gregorian)
        let startOfDay = calendar.startOfDay(for: date)
        let phase = moonPhase(for: date)

        // Approximate moon transit time based on moon phase
        // Moon transits ~50 minutes later each day
        let dayOfLunarMonth = phase * 29.53059
        let transitOffset = dayOfLunarMonth * 50.0 / 60.0 // hours after midnight (very rough)
        let moonTransitHour = (12.0 + transitOffset).truncatingRemainder(dividingBy: 24.0)

        // Major periods: around moon transit and moon underfoot (opposite)
        let transit1 = startOfDay.addingTimeInterval(moonTransitHour * 3600)
        let transit2 = startOfDay.addingTimeInterval(((moonTransitHour + 12.0).truncatingRemainder(dividingBy: 24.0)) * 3600)

        let majorPeriods = [
            SolunarPeriod(start: transit1.addingTimeInterval(-60 * 60), end: transit1.addingTimeInterval(60 * 60), type: .major),
            SolunarPeriod(start: transit2.addingTimeInterval(-60 * 60), end: transit2.addingTimeInterval(60 * 60), type: .major),
        ]

        // Minor periods: moonrise and moonset (roughly 6h offset from transits)
        let minor1Time = startOfDay.addingTimeInterval(((moonTransitHour - 6.0 + 24.0).truncatingRemainder(dividingBy: 24.0)) * 3600)
        let minor2Time = startOfDay.addingTimeInterval(((moonTransitHour + 6.0).truncatingRemainder(dividingBy: 24.0)) * 3600)

        let minorPeriods = [
            SolunarPeriod(start: minor1Time.addingTimeInterval(-30 * 60), end: minor1Time.addingTimeInterval(30 * 60), type: .minor),
            SolunarPeriod(start: minor2Time.addingTimeInterval(-30 * 60), end: minor2Time.addingTimeInterval(30 * 60), type: .minor),
        ]

        // Sunrise/sunset approximation
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let declination = 23.45 * sin(Double(284 + dayOfYear) / 365.0 * 2.0 * .pi)
        let latRad = latitude * .pi / 180.0
        let decRad = declination * .pi / 180.0
        let hourAngle = acos(-tan(latRad) * tan(decRad)) * 180.0 / .pi / 15.0
        let solarNoon = 12.0 - longitude / 15.0 + 9.0 // JST offset

        let sunriseHour = solarNoon - hourAngle
        let sunsetHour = solarNoon + hourAngle
        let sunrise = startOfDay.addingTimeInterval(sunriseHour * 3600)
        let sunset = startOfDay.addingTimeInterval(sunsetHour * 3600)

        // Moonrise/moonset approximation
        let moonrise = minor1Time
        let moonset = minor2Time

        // Daily rating based on moon phase (full/new moon = best)
        let phaseScore: Double
        if phase < 0.1 || phase > 0.9 { phaseScore = 90 } // New moon
        else if phase > 0.4 && phase < 0.6 { phaseScore = 85 } // Full moon
        else if phase > 0.2 && phase < 0.3 { phaseScore = 60 } // First quarter
        else if phase > 0.7 && phase < 0.8 { phaseScore = 60 } // Last quarter
        else { phaseScore = 45 }

        return SolunarInfo(
            date: date,
            moonrise: moonrise,
            moonset: moonset,
            sunrise: sunrise,
            sunset: sunset,
            moonPhase: phase,
            majorPeriods: majorPeriods,
            minorPeriods: minorPeriods,
            dailyRating: Int(phaseScore)
        )
    }
}
