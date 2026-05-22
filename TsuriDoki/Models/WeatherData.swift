import Foundation

struct HourlyWeather: Identifiable {
    let id = UUID()
    let time: Date
    let temperature: Double
    let weatherCode: Int
    let windSpeed: Double
    let windDirection: Int
    let pressure: Double
    let humidity: Int
    let precipitationProbability: Int
    let waveHeight: Double?

    var weatherIcon: String {
        switch weatherCode {
        case 0: return "sun.max.fill"
        case 1, 2, 3: return "cloud.sun.fill"
        case 45, 48: return "cloud.fog.fill"
        case 51, 53, 55, 56, 57: return "cloud.drizzle.fill"
        case 61, 63, 65, 66, 67: return "cloud.rain.fill"
        case 71, 73, 75, 77: return "cloud.snow.fill"
        case 80, 81, 82: return "cloud.heavyrain.fill"
        case 95, 96, 99: return "cloud.bolt.rain.fill"
        default: return "cloud.fill"
        }
    }

    var weatherDescription: String {
        switch weatherCode {
        case 0: return "快晴"
        case 1: return "晴れ"
        case 2: return "曇り時々晴れ"
        case 3: return "曇り"
        case 45, 48: return "霧"
        case 51, 53, 55: return "霧雨"
        case 56, 57: return "凍る霧雨"
        case 61, 63: return "雨"
        case 65: return "大雨"
        case 66, 67: return "凍る雨"
        case 71, 73, 75: return "雪"
        case 77: return "霰"
        case 80, 81, 82: return "にわか雨"
        case 95: return "雷雨"
        case 96, 99: return "雹を伴う雷雨"
        default: return "不明"
        }
    }

    var windDirectionText: String {
        let directions = ["北", "北北東", "北東", "東北東", "東", "東南東", "南東", "南南東",
                          "南", "南南西", "南西", "西南西", "西", "西北西", "北西", "北北西"]
        let index = Int((Double(windDirection) + 11.25) / 22.5) % 16
        return directions[index]
    }
}

struct DailyForecast: Identifiable {
    let id = UUID()
    let date: Date
    let tempMax: Double
    let tempMin: Double
    let weatherCode: Int
    let precipitationProbability: Int
    let windSpeedMax: Double
    let biteScore: Int // 爆釣スコア 0-100

    var weatherIcon: String {
        switch weatherCode {
        case 0: return "sun.max.fill"
        case 1, 2, 3: return "cloud.sun.fill"
        case 45, 48: return "cloud.fog.fill"
        case 51...67: return "cloud.rain.fill"
        case 71...77: return "cloud.snow.fill"
        case 80...82: return "cloud.heavyrain.fill"
        case 95...99: return "cloud.bolt.rain.fill"
        default: return "cloud.fill"
        }
    }
}
