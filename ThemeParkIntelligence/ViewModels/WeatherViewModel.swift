import SwiftUI
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

    // MARK: - RL 奖惩统计

    var cumulativeReward: Double {
        hourlyWeather.map(\.rewardScore).reduce(0, +)
    }

    /// 归一化到 0-100 的策略综合评分
    var policyScore: Int {
        let n = Double(hourlyWeather.count)
        let normalized = (cumulativeReward - (-n)) / (n - (-n))
        return max(0, min(100, Int(normalized * 100)))
    }

    var policyGrade: String {
        switch policyScore {
        case 80...: return "A"
        case 65..<80: return "B"
        case 50..<65: return "C"
        default: return "D"
        }
    }

    var policyGradeColor: Color {
        switch policyScore {
        case 80...: return .green
        case 65..<80: return .blue
        case 50..<65: return .orange
        default: return .red
        }
    }

    /// 当前小时的 Q 值估算（当前 + 折扣未来奖励）
    var currentQValue: Double {
        let gamma = 0.9
        let future = hourlyWeather
            .filter { $0.hour > currentHour }
            .enumerated()
            .map { i, h in pow(gamma, Double(i + 1)) * h.rewardScore }
            .reduce(0, +)
        let current = hourlyWeather.first(where: { $0.hour == currentHour })?.rewardScore ?? 0
        return current + future
    }

    var rlPolicyNotes: [(icon: String, color: Color, text: String)] {
        [
            ("bolt.circle.fill",      .yellow, "模型在 13:00 提前 1h 识别降雨预警信号，下调定价精准命中，游客留园率高于基线 +14%"),
            ("exclamationmark.triangle.fill", .red, "15:00 雷阵雨造成不可抗力关闭，该时段惩罚已标记为天气因子（ξ），不反向传播至策略梯度"),
            ("arrow.up.right.circle.fill",    .green, "19:00 策略恢复溢价及时，Q 值回弹 +0.23，策略网络权重正向更新"),
        ]
    }
}
