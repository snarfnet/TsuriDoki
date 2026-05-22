import Foundation

enum BiteScoreCalculator {
    /// Calculate bite score (0-100) from combined environmental factors
    static func calculate(
        tideHeight: Double?,
        tideRate: Double?,
        pressure: Double,
        pressureChange: Double,
        windSpeed: Double,
        moonPhase: Double,
        weatherCode: Int,
        hour: Int
    ) -> Int {
        var score = 50.0

        // Moon phase factor (new/full moon = best)
        if moonPhase < 0.1 || moonPhase > 0.9 { score += 15 }
        else if moonPhase > 0.4 && moonPhase < 0.6 { score += 12 }
        else if (moonPhase > 0.2 && moonPhase < 0.3) || (moonPhase > 0.7 && moonPhase < 0.8) { score += 5 }

        // Pressure factor
        if pressure >= 1010 && pressure <= 1020 { score += 10 }
        else if pressure < 1005 { score -= 10 }

        // Pressure change (dropping = good for fishing)
        if pressureChange < -1.0 { score += 12 }
        else if pressureChange < -0.5 { score += 8 }
        else if pressureChange > 1.0 { score -= 5 }

        // Wind (light wind best, strong wind bad)
        if windSpeed < 5 { score += 8 }
        else if windSpeed < 10 { score += 4 }
        else if windSpeed > 20 { score -= 15 }
        else if windSpeed > 15 { score -= 8 }

        // Weather (overcast/light rain often good)
        switch weatherCode {
        case 2, 3: score += 8  // Cloudy - often great
        case 1: score += 5     // Partly cloudy
        case 0: score += 2     // Clear
        case 51, 53: score += 5 // Light drizzle can be good
        case 61: score += 3    // Light rain
        case 65, 80, 81, 82: score -= 8  // Heavy rain
        case 95, 96, 99: score -= 20     // Thunderstorm
        default: break
        }

        // Time of day (dawn/dusk best)
        if hour >= 4 && hour <= 7 { score += 10 }  // Dawn
        else if hour >= 16 && hour <= 19 { score += 10 } // Dusk
        else if hour >= 11 && hour <= 14 { score -= 5 }  // Midday

        // Tide movement (moving tide better than slack)
        if let rate = tideRate {
            let absRate = abs(rate)
            if absRate > 0.05 { score += 8 } // Active tide movement
            else if absRate < 0.01 { score -= 5 } // Slack tide
        }

        return max(0, min(100, Int(score)))
    }

    /// Simplified daily score for forecast view
    static func calculateDaily(
        weatherCode: Int,
        pressure: Double,
        windSpeed: Double,
        moonPhase: Double,
        precipProbability: Int
    ) -> Int {
        var score = 50.0

        // Moon phase
        if moonPhase < 0.1 || moonPhase > 0.9 { score += 15 }
        else if moonPhase > 0.4 && moonPhase < 0.6 { score += 12 }
        else { score += 3 }

        // Pressure
        if pressure >= 1010 && pressure <= 1020 { score += 10 }
        else if pressure < 1005 { score -= 8 }

        // Wind
        if windSpeed < 10 { score += 8 }
        else if windSpeed > 20 { score -= 12 }

        // Weather
        switch weatherCode {
        case 0, 1, 2, 3: score += 8
        case 51, 53, 61: score += 4
        case 65, 80, 81, 82: score -= 8
        case 95, 96, 99: score -= 20
        default: break
        }

        // Rain probability
        if precipProbability > 80 { score -= 10 }
        else if precipProbability < 20 { score += 5 }

        return max(0, min(100, Int(score)))
    }

    static func scoreColor(_ score: Int) -> String {
        switch score {
        case 80...100: return "scoreExcellent"
        case 60..<80: return "scoreGood"
        case 40..<60: return "scoreAverage"
        default: return "scorePoor"
        }
    }

    static func scoreLabel(_ score: Int) -> String {
        switch score {
        case 80...100: return "爆釣"
        case 60..<80: return "好調"
        case 40..<60: return "普通"
        case 20..<40: return "渋い"
        default: return "厳しい"
        }
    }
}
