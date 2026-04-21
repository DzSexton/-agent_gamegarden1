import Foundation
import Observation

@Observable
final class WeatherViewModel {

    var hourlyWeather: [WeatherHour]     = WeatherMockData.buildHourlyData()
    var historicalMatch: HistoricalMatch = WeatherMockData.buildHistoricalMatch()
    var selectedHour: WeatherHour?       = nil
    var showInsightSheet                 = false

    var currentHour: Int { Calendar.current.component(.hour, from: Date()) }

    // Most impactful weather type today (drives sheet recommendations)
    var dominantType: WeatherType {
        let rainy = hourlyWeather.filter { $0.type.isRainy }
        if rainy.count >= 3 { return rainy.max(by: { abs($0.priceDelta) < abs($1.priceDelta) })?.type ?? .heavyRain }
        if hourlyWeather.filter({ $0.type.isHot }).count >= 4 { return .hot }
        return .partlyCloudy
    }

    var todaySummaryLabel: String {
        let r = hourlyWeather.filter { $0.type.isRainy }.count
        if r >= 5 { return "雨天主导" }
        if r >= 2 { return "阴雨交替" }
        return "晴间多云"
    }

    var overallPriceAdvice: String {
        let avg = hourlyWeather.map(\.priceDelta).reduce(0, +) / Double(hourlyWeather.count)
        let p = Int(avg * 100)
        if p > 0 { return "今日建议均价上调约 +\(p)%，上午晴好时段可适度溢价" }
        if p < 0 { return "雨天影响显著，建议均价下调约 \(p)%，以维持入园率" }
        return "今日天气中性，建议维持现有定价策略，动态观察"
    }

    var priceRangeText: String {
        let maxD = Int((hourlyWeather.map(\.priceDelta).max() ?? 0) * 100)
        let minD = Int((hourlyWeather.map(\.priceDelta).min() ?? 0) * 100)
        return "建议调价区间：\(minD > 0 ? "+" : "")\(minD)% ～ +\(maxD)%"
    }

    func recommendations() -> [WeatherRecommendation] {
        WeatherMockData.recommendations(for: dominantType)
    }
}
