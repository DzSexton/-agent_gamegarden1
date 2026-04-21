import Foundation

// MARK: - Core API contract matching FastAPI response schema

struct DashboardSnapshot: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let demandPrediction: DemandPrediction
    let optimalPrice: OptimalPrice
    let aiNarrative: AInarrative
    let revenueHistory: [RevenueDataPoint]

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        demandPrediction: DemandPrediction,
        optimalPrice: OptimalPrice,
        aiNarrative: AInarrative,
        revenueHistory: [RevenueDataPoint]
    ) {
        self.id = id
        self.timestamp = timestamp
        self.demandPrediction = demandPrediction
        self.optimalPrice = optimalPrice
        self.aiNarrative = aiNarrative
        self.revenueHistory = revenueHistory
    }
}

struct DemandPrediction: Codable {
    let currentVisitors: Int       // 当前在园人数
    let predictedPeak: Int         // 预测峰值
    let confidenceScore: Double    // 模型置信度 0-1
    let trend: TrendDirection

    enum TrendDirection: String, Codable {
        case rising, stable, falling
    }
}

struct OptimalPrice: Codable {
    let recommended: Double        // AI建议票价
    let current: Double            // 当前执行票价
    let minBound: Double
    let maxBound: Double
    let elasticityScore: Double    // 价格弹性系数
}

struct AInarrative: Codable {
    let summary: String            // GAI生成的决策摘要
    let confidence: Double
    let generatedAt: Date
    let modelVersion: String
}

struct RevenueDataPoint: Identifiable, Codable {
    let id: UUID
    let hour: Int                  // 0-23
    let actual: Double?
    let predicted: Double

    init(id: UUID = UUID(), hour: Int, actual: Double? = nil, predicted: Double) {
        self.id = id
        self.hour = hour
        self.actual = actual
        self.predicted = predicted
    }
}
