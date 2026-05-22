import Foundation

actor WeatherService {
    static let shared = WeatherService()

    func fetchHourlyWeather(latitude: Double, longitude: Double) async throws -> [HourlyWeather] {
        let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&hourly=temperature_2m,weather_code,wind_speed_10m,wind_direction_10m,surface_pressure,relative_humidity_2m,precipitation_probability&timezone=Asia%2FTokyo&forecast_days=3")!

        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let hourly = json?["hourly"] as? [String: Any],
              let times = hourly["time"] as? [String],
              let temps = hourly["temperature_2m"] as? [Double],
              let codes = hourly["weather_code"] as? [Int],
              let winds = hourly["wind_speed_10m"] as? [Double],
              let dirs = hourly["wind_direction_10m"] as? [Int],
              let pressures = hourly["surface_pressure"] as? [Double],
              let humidities = hourly["relative_humidity_2m"] as? [Int],
              let precips = hourly["precipitation_probability"] as? [Int]
        else { return [] }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]

        var results: [HourlyWeather] = []
        for i in 0..<times.count {
            guard let date = formatter.date(from: times[i]) else { continue }
            results.append(HourlyWeather(
                time: date,
                temperature: temps[i],
                weatherCode: codes[i],
                windSpeed: winds[i],
                windDirection: dirs[i],
                pressure: pressures[i],
                humidity: humidities[i],
                precipitationProbability: precips[i],
                waveHeight: nil
            ))
        }
        return results
    }

    func fetchMarineWeather(latitude: Double, longitude: Double) async throws -> [Double?] {
        let url = URL(string: "https://marine-api.open-meteo.com/v1/marine?latitude=\(latitude)&longitude=\(longitude)&hourly=wave_height&timezone=Asia%2FTokyo&forecast_days=3")!

        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let hourly = json?["hourly"] as? [String: Any],
              let waves = hourly["wave_height"] as? [Any]
        else { return [] }

        return waves.map { ($0 as? Double) }
    }

    func fetchDailyForecast(latitude: Double, longitude: Double) async throws -> [DailyForecast] {
        let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&daily=temperature_2m_max,temperature_2m_min,weather_code,precipitation_probability_max,wind_speed_10m_max,surface_pressure_mean&timezone=Asia%2FTokyo&forecast_days=10")!

        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let daily = json?["daily"] as? [String: Any],
              let times = daily["time"] as? [String],
              let maxTemps = daily["temperature_2m_max"] as? [Double],
              let minTemps = daily["temperature_2m_min"] as? [Double],
              let codes = daily["weather_code"] as? [Int],
              let precips = daily["precipitation_probability_max"] as? [Int],
              let winds = daily["wind_speed_10m_max"] as? [Double]
        else { return [] }

        let pressures = (daily["surface_pressure_mean"] as? [Double]) ?? Array(repeating: 1013.0, count: times.count)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")

        var results: [DailyForecast] = []
        for i in 0..<times.count {
            guard let date = dateFormatter.date(from: times[i]) else { continue }
            let score = BiteScoreCalculator.calculateDaily(
                weatherCode: codes[i],
                pressure: pressures[i],
                windSpeed: winds[i],
                moonPhase: SolunarCalculator.moonPhase(for: date),
                precipProbability: precips[i]
            )
            results.append(DailyForecast(
                date: date,
                tempMax: maxTemps[i],
                tempMin: minTemps[i],
                weatherCode: codes[i],
                precipitationProbability: precips[i],
                windSpeedMax: winds[i],
                biteScore: score
            ))
        }
        return results
    }
}
