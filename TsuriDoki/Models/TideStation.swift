import Foundation
import CoreLocation

struct TideStation: Identifiable, Codable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let prefecture: String

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension TideStation {
    static let allStations: [TideStation] = [
        // 北海道
        TideStation(id: "wakkanai", name: "稚内", latitude: 45.4086, longitude: 141.6731, prefecture: "北海道"),
        TideStation(id: "abashiri", name: "網走", latitude: 44.0206, longitude: 144.2864, prefecture: "北海道"),
        TideStation(id: "kushiro", name: "釧路", latitude: 42.9750, longitude: 144.3744, prefecture: "北海道"),
        TideStation(id: "hakodate", name: "函館", latitude: 41.7686, longitude: 140.7289, prefecture: "北海道"),
        TideStation(id: "otaru", name: "小樽", latitude: 43.1907, longitude: 140.9945, prefecture: "北海道"),
        // 東北
        TideStation(id: "aomori", name: "青森", latitude: 40.8271, longitude: 140.7406, prefecture: "青森県"),
        TideStation(id: "miyako", name: "宮古", latitude: 39.6364, longitude: 141.9531, prefecture: "岩手県"),
        TideStation(id: "ishinomaki", name: "石巻", latitude: 38.4175, longitude: 141.3025, prefecture: "宮城県"),
        TideStation(id: "akita", name: "秋田", latitude: 39.7600, longitude: 140.0589, prefecture: "秋田県"),
        TideStation(id: "sakata", name: "酒田", latitude: 38.9147, longitude: 139.8361, prefecture: "山形県"),
        TideStation(id: "onahama", name: "小名浜", latitude: 36.9342, longitude: 140.9017, prefecture: "福島県"),
        // 関東
        TideStation(id: "choshi", name: "銚子", latitude: 35.7350, longitude: 140.8267, prefecture: "千葉県"),
        TideStation(id: "tokyo", name: "東京", latitude: 35.6544, longitude: 139.7700, prefecture: "東京都"),
        TideStation(id: "yokohama", name: "横浜", latitude: 35.4500, longitude: 139.6500, prefecture: "神奈川県"),
        TideStation(id: "yokosuka", name: "横須賀", latitude: 35.2833, longitude: 139.6500, prefecture: "神奈川県"),
        TideStation(id: "katsuura", name: "勝浦", latitude: 35.1497, longitude: 140.3144, prefecture: "千葉県"),
        // 中部
        TideStation(id: "niigata", name: "新潟", latitude: 37.9161, longitude: 139.0364, prefecture: "新潟県"),
        TideStation(id: "toyama", name: "富山", latitude: 36.7594, longitude: 137.2161, prefecture: "富山県"),
        TideStation(id: "kanazawa", name: "金沢", latitude: 36.6000, longitude: 136.6333, prefecture: "石川県"),
        TideStation(id: "shimizu", name: "清水", latitude: 35.0167, longitude: 138.5000, prefecture: "静岡県"),
        TideStation(id: "nagoya", name: "名古屋", latitude: 35.0833, longitude: 136.8833, prefecture: "愛知県"),
        TideStation(id: "toba", name: "鳥羽", latitude: 34.4833, longitude: 136.8333, prefecture: "三重県"),
        TideStation(id: "owase", name: "尾鷲", latitude: 34.0667, longitude: 136.2000, prefecture: "三重県"),
        // 近畿
        TideStation(id: "maizuru", name: "舞鶴", latitude: 35.4667, longitude: 135.3833, prefecture: "京都府"),
        TideStation(id: "osaka", name: "大阪", latitude: 34.6500, longitude: 135.4333, prefecture: "大阪府"),
        TideStation(id: "kobe", name: "神戸", latitude: 34.6833, longitude: 135.1833, prefecture: "兵庫県"),
        TideStation(id: "wakayama", name: "和歌山", latitude: 34.2167, longitude: 135.1500, prefecture: "和歌山県"),
        TideStation(id: "shirahama", name: "白浜", latitude: 33.6833, longitude: 135.3500, prefecture: "和歌山県"),
        // 中国
        TideStation(id: "sakai_tottori", name: "境", latitude: 35.5333, longitude: 133.2333, prefecture: "鳥取県"),
        TideStation(id: "hamada", name: "浜田", latitude: 34.9000, longitude: 132.0667, prefecture: "島根県"),
        TideStation(id: "hiroshima", name: "広島", latitude: 34.3500, longitude: 132.4500, prefecture: "広島県"),
        TideStation(id: "shimonoseki", name: "下関", latitude: 33.9500, longitude: 130.9500, prefecture: "山口県"),
        // 四国
        TideStation(id: "takamatsu", name: "高松", latitude: 34.3500, longitude: 134.0500, prefecture: "香川県"),
        TideStation(id: "tokushima", name: "徳島", latitude: 34.0667, longitude: 134.5833, prefecture: "徳島県"),
        TideStation(id: "kochi", name: "高知", latitude: 33.5000, longitude: 133.5667, prefecture: "高知県"),
        TideStation(id: "uwajima", name: "宇和島", latitude: 33.2167, longitude: 132.5500, prefecture: "愛媛県"),
        // 九州
        TideStation(id: "hakata", name: "博多", latitude: 33.6000, longitude: 130.4000, prefecture: "福岡県"),
        TideStation(id: "nagasaki", name: "長崎", latitude: 32.7333, longitude: 129.8667, prefecture: "長崎県"),
        TideStation(id: "kumamoto", name: "熊本", latitude: 32.7833, longitude: 130.7167, prefecture: "熊本県"),
        TideStation(id: "oita", name: "大分", latitude: 33.2333, longitude: 131.6000, prefecture: "大分県"),
        TideStation(id: "aburatsu", name: "油津", latitude: 31.5667, longitude: 131.4000, prefecture: "宮崎県"),
        TideStation(id: "kagoshima", name: "鹿児島", latitude: 31.5833, longitude: 130.5667, prefecture: "鹿児島県"),
        // 沖縄
        TideStation(id: "naha", name: "那覇", latitude: 26.2167, longitude: 127.6667, prefecture: "沖縄県"),
        TideStation(id: "ishigaki", name: "石垣", latitude: 24.3333, longitude: 124.1500, prefecture: "沖縄県"),
    ]

    static func nearest(to location: CLLocationCoordinate2D) -> TideStation {
        allStations.min(by: {
            let d1 = pow($0.latitude - location.latitude, 2) + pow($0.longitude - location.longitude, 2)
            let d2 = pow($1.latitude - location.latitude, 2) + pow($1.longitude - location.longitude, 2)
            return d1 < d2
        }) ?? allStations.first(where: { $0.id == "tokyo" })!
    }
}
