import SwiftUI

// MARK: - Weather Type

enum WeatherType: String, CaseIterable {
    case sunny, hot, partlyCloudy, cloudy, lightRain, heavyRain, thunderstorm

    var icon: String {
        switch self {
        case .sunny:        return "sun.max.fill"
        case .hot:          return "thermometer.sun.fill"
        case .partlyCloudy: return "cloud.sun.fill"
        case .cloudy:       return "cloud.fill"
        case .lightRain:    return "cloud.drizzle.fill"
        case .heavyRain:    return "cloud.heavyrain.fill"
        case .thunderstorm: return "cloud.bolt.rain.fill"
        }
    }

    var color: Color {
        switch self {
        case .sunny:        return .yellow
        case .hot:          return .orange
        case .partlyCloudy: return Color(red: 0.95, green: 0.75, blue: 0.25)
        case .cloudy:       return Color(white: 0.55)
        case .lightRain:    return Color(red: 0.35, green: 0.65, blue: 1.0)
        case .heavyRain:    return Color(red: 0.25, green: 0.45, blue: 0.95)
        case .thunderstorm: return Color(red: 0.45, green: 0.30, blue: 0.90)
        }
    }

    var displayName: String {
        switch self {
        case .sunny:        return "晴天"
        case .hot:          return "高温晴"
        case .partlyCloudy: return "多云"
        case .cloudy:       return "阴天"
        case .lightRain:    return "小雨"
        case .heavyRain:    return "大雨"
        case .thunderstorm: return "雷阵雨"
        }
    }

    var isRainy: Bool {
        self == .lightRain || self == .heavyRain || self == .thunderstorm
    }
    var isHot: Bool   { self == .hot }
    var isSunny: Bool { self == .sunny || self == .partlyCloudy }
}

// MARK: - Hourly Weather

struct WeatherHour: Identifiable, Equatable {
    let id: UUID
    let hour: Int            // 8-22
    let type: WeatherType
    let temperature: Int     // °C
    let humidity: Int        // 0-100
    let priceDelta: Double   // -0.25 ... +0.12
    let strategy: String
    let rewardScore: Double  // RL 即时奖励: -1.0…+1.0

    init(
        id: UUID = UUID(),
        hour: Int, type: WeatherType, temperature: Int,
        humidity: Int, priceDelta: Double, strategy: String,
        rewardScore: Double = 0.0
    ) {
        self.id = id; self.hour = hour; self.type = type
        self.temperature = temperature; self.humidity = humidity
        self.priceDelta = priceDelta; self.strategy = strategy
        self.rewardScore = rewardScore
    }

    static func == (l: WeatherHour, r: WeatherHour) -> Bool { l.id == r.id }

    var priceLabel: String {
        let p = Int(abs(priceDelta) * 100)
        if priceDelta >  0.01 { return "↑ +\(p)%" }
        if priceDelta < -0.01 { return "↓ \(p)%" }
        return "— 持平"
    }

    var priceColor: Color {
        priceDelta > 0.01 ? .green : priceDelta < -0.01 ? .orange : .secondary
    }

    var riskTag: String {
        if abs(priceDelta) >= 0.20 { return "高优先" }
        if abs(priceDelta) >= 0.10 { return "建议调" }
        return "维持"
    }

    var riskColor: Color {
        if abs(priceDelta) >= 0.20 { return .red }
        if abs(priceDelta) >= 0.10 { return .orange }
        return .secondary
    }
}

// MARK: - Historical Match

struct HistoricalMatch {
    let dateLabel: String          // "2023年6月15日"
    let similarity: Double
    let weatherSummary: String
    let peakVisitors: Int
    let totalRevenue: Double       // 万元
    let raingearSales: Int
    let fnbBoostPct: Double
    let indoorBoostPct: Double
    let hourlyPoints: [HistoricalPoint]
}

struct HistoricalPoint: Identifiable {
    let id: UUID
    let hour: Int
    let visitors: Int
    let isRainPeriod: Bool
    let weatherType: WeatherType
    let temperature: Int

    init(id: UUID = UUID(), hour: Int, visitors: Int, isRainPeriod: Bool,
         weatherType: WeatherType = .partlyCloudy, temperature: Int = 25) {
        self.id = id; self.hour = hour
        self.visitors = visitors; self.isRainPeriod = isRainPeriod
        self.weatherType = weatherType; self.temperature = temperature
    }
}

// MARK: - Recommendation

struct WeatherRecommendation: Identifiable {
    let id: UUID
    let category: String
    let title: String
    let detail: String
    let icon: String
    let uplift: String
    let accentColor: Color

    init(
        id: UUID = UUID(),
        category: String, title: String, detail: String,
        icon: String, uplift: String, accentColor: Color
    ) {
        self.id = id; self.category = category; self.title = title
        self.detail = detail; self.icon = icon; self.uplift = uplift
        self.accentColor = accentColor
    }
}
