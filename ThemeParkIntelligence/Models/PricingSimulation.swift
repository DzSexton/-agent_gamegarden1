import Foundation

struct PricingSimulationRequest: Codable {
    let basePrice: Double
    let demandMultiplier: Double   // 需求系数 0.5-2.0
    let timeSlot: TimeSlot
    let weatherFactor: Double      // 天气影响系数

    enum TimeSlot: String, Codable, CaseIterable {
        case morning = "morning"
        case afternoon = "afternoon"
        case evening = "evening"

        var displayName: String {
            switch self {
            case .morning:   return "上午 (9:00-12:00)"
            case .afternoon: return "下午 (12:00-18:00)"
            case .evening:   return "傍晚 (18:00-22:00)"
            }
        }
    }
}

struct PricingSimulationResult: Codable {
    let suggestedPrice: Double
    let projectedRevenue: Double
    let projectedVisitors: Int
    let revenueVsBaseline: Double  // 相较基准的增减百分比
    let priceElasticity: Double
    let comparisonCurve: [PriceCurvePoint]
}

struct PriceCurvePoint: Identifiable, Codable {
    let id: UUID
    let price: Double
    let projectedRevenue: Double
    let projectedVisitors: Int

    init(id: UUID = UUID(), price: Double, projectedRevenue: Double, projectedVisitors: Int) {
        self.id = id
        self.price = price
        self.projectedRevenue = projectedRevenue
        self.projectedVisitors = projectedVisitors
    }
}
