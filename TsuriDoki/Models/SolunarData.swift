import Foundation

struct SolunarPeriod: Identifiable {
    let id = UUID()
    let start: Date
    let end: Date
    let type: PeriodType

    enum PeriodType: String {
        case major = "メジャー"
        case minor = "マイナー"
    }

    var durationMinutes: Int {
        Int(end.timeIntervalSince(start) / 60)
    }
}

struct SolunarInfo {
    let date: Date
    let moonrise: Date?
    let moonset: Date?
    let sunrise: Date?
    let sunset: Date?
    let moonPhase: Double // 0.0 = 新月, 0.5 = 満月
    let majorPeriods: [SolunarPeriod]
    let minorPeriods: [SolunarPeriod]
    let dailyRating: Int // 0-100

    var moonPhaseName: String {
        switch moonPhase {
        case 0..<0.0625: return "新月"
        case 0.0625..<0.1875: return "三日月"
        case 0.1875..<0.3125: return "上弦の月"
        case 0.3125..<0.4375: return "十日夜"
        case 0.4375..<0.5625: return "満月"
        case 0.5625..<0.6875: return "十六夜"
        case 0.6875..<0.8125: return "下弦の月"
        case 0.8125..<0.9375: return "二十六夜"
        default: return "新月"
        }
    }

    var moonPhaseIcon: String {
        switch moonPhase {
        case 0..<0.125: return "moonphase.new.moon"
        case 0.125..<0.25: return "moonphase.waxing.crescent"
        case 0.25..<0.375: return "moonphase.first.quarter"
        case 0.375..<0.5: return "moonphase.waxing.gibbous"
        case 0.5..<0.625: return "moonphase.full.moon"
        case 0.625..<0.75: return "moonphase.waning.gibbous"
        case 0.75..<0.875: return "moonphase.last.quarter"
        default: return "moonphase.waning.crescent"
        }
    }
}
