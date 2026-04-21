import Foundation

// MARK: - Protocol enabling easy swap with real FastAPI service later

protocol DataServiceProtocol {
    func fetchDashboardSnapshot() async throws -> DashboardSnapshot
    func runPricingSimulation(_ request: PricingSimulationRequest) async throws -> PricingSimulationResult
    func fetchAlerts() async throws -> [TPIAlert]
}

enum ServiceError: LocalizedError {
    case networkUnavailable
    case decodingFailed(String)
    case simulationTimeout

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:     return "网络连接不可用，请检查网络设置"
        case .decodingFailed(let m):  return "数据解析失败: \(m)"
        case .simulationTimeout:      return "模拟计算超时，请重试"
        }
    }
}

final class MockDataService: DataServiceProtocol {

    // 模拟网络延迟
    private func simulateLatency(_ range: ClosedRange<UInt64> = 300_000_000...800_000_000) async {
        try? await Task.sleep(nanoseconds: UInt64.random(in: range))
    }

    func fetchDashboardSnapshot() async throws -> DashboardSnapshot {
        await simulateLatency()

        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)

        let revenueHistory = (0..<currentHour).map { hour in
            RevenueDataPoint(
                hour: hour,
                actual: Double.random(in: 80_000...200_000),
                predicted: Double.random(in: 90_000...190_000)
            )
        } + (currentHour..<24).map { hour in
            RevenueDataPoint(
                hour: hour,
                actual: nil,
                predicted: Double.random(in: 90_000...190_000)
            )
        }

        return DashboardSnapshot(
            demandPrediction: DemandPrediction(
                currentVisitors: Int.random(in: 12_000...35_000),
                predictedPeak: Int.random(in: 38_000...45_000),
                confidenceScore: Double.random(in: 0.82...0.97),
                trend: [.rising, .stable, .falling].randomElement()!
            ),
            optimalPrice: OptimalPrice(
                recommended: Double.random(in: 299...459),
                current: 369,
                minBound: 199,
                maxBound: 599,
                elasticityScore: Double.random(in: -1.8 ... -0.6)
            ),
            aiNarrative: AInarrative(
                summary: Self.randomNarrative(),
                confidence: Double.random(in: 0.78...0.95),
                generatedAt: now,
                modelVersion: "TPI-GAI v2.3.1"
            ),
            revenueHistory: revenueHistory
        )
    }

    func runPricingSimulation(_ request: PricingSimulationRequest) async throws -> PricingSimulationResult {
        // 模拟AI计算延迟（比普通请求稍长）
        await simulateLatency(600_000_000...1_200_000_000)

        let baseRevenue = 1_500_000.0
        let priceEffect = 1.0 + (request.basePrice - 369) / 369 * request.demandMultiplier
        let projectedRevenue = baseRevenue * priceEffect * request.weatherFactor

        // 生成价格-收益对比曲线（用于双曲线图）
        let curve = stride(from: 199.0, through: 599.0, by: 20.0).map { price in
            let effect = 1.0 + (price - 369) / 369 * request.demandMultiplier
            let rev = baseRevenue * effect * request.weatherFactor
            let visitors = Int(35_000.0 * (1.0 - (price - 199) / 800))
            return PriceCurvePoint(price: price, projectedRevenue: rev, projectedVisitors: visitors)
        }

        return PricingSimulationResult(
            suggestedPrice: request.basePrice,
            projectedRevenue: projectedRevenue,
            projectedVisitors: Int(35_000 * request.demandMultiplier * request.weatherFactor),
            revenueVsBaseline: (projectedRevenue / baseRevenue - 1.0) * 100,
            priceElasticity: -1.2 * request.demandMultiplier,
            comparisonCurve: curve
        )
    }

    func fetchAlerts() async throws -> [TPIAlert] {
        await simulateLatency(200_000_000...500_000_000)
        return Self.mockAlerts()
    }
}

// MARK: - Mock Data Generators

private extension MockDataService {

    static func randomNarrative() -> String {
        let narratives = [
            "当前客流呈上升趋势，预计14:00-16:00达到峰值约4.2万人。建议将票价上调至¥429，可在保持入园率的同时最大化营收。热力图显示西区游乐设施承载率已达78%，建议提前开启应急分流通道。",
            "今日天气晴好，外部需求超出基准预测12%。AI模型建议动态调整票价至¥449-¥469区间，预计带来额外营收¥23万。注意：周边竞品乐园今日有促销活动，价格弹性系数较昨日下降0.15。",
            "综合实时气象数据与历史客流模型，预计下午将迎来散客高峰。当前库存游览车尚余45个名额，建议优先通过APP推送定向营销。定价模型置信度92%，可信赖性高。"
        ]
        return narratives.randomElement()!
    }

    static func mockAlerts() -> [TPIAlert] {
        [
            TPIAlert(
                severity: .critical,
                category: .capacity,
                title: "西区容量预警",
                detail: "西区实时承载率已达额定容量的 91%，触发三级预警阈值。建议立即启动分流方案 B。",
                triggeredAt: Date().addingTimeInterval(-180)
            ),
            TPIAlert(
                severity: .warning,
                category: .revenue,
                title: "营收偏离预测",
                detail: "过去 2 小时实际营收较预测值低 8.3%（¥-14.2万），请确认线上渠道是否正常。",
                triggeredAt: Date().addingTimeInterval(-900)
            ),
            TPIAlert(
                severity: .warning,
                category: .weather,
                title: "午后雷阵雨风险",
                detail: "气象数据显示15:30-17:00存在60%降雨概率，户外设施需提前准备应急预案。",
                triggeredAt: Date().addingTimeInterval(-1800)
            ),
            TPIAlert(
                severity: .info,
                category: .operations,
                title: "过山车设施维护完成",
                detail: "雷霆飞车 A 线已完成例行检修，恢复正常运营。预计释放需求约 800 人次/时。",
                triggeredAt: Date().addingTimeInterval(-3600),
                isAcknowledged: true
            )
        ].sorted { $0.severity.priority > $1.severity.priority }
    }
}
