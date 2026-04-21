import Foundation
import Observation

@Observable
final class PersonaViewModel {

    // MARK: - State

    var allPersonas: [PersonaCategory: [PersonaIndividual]] = [:]
    var isLoadingAI: Bool = false
    var aiAdviceText: String = ""
    var showAISheet: Bool = false
    var currentPersona: PersonaIndividual?

    // MARK: - Init

    init() {
        allPersonas = PersonaMockData.build()
    }

    // MARK: - Public

    func personas(for category: PersonaCategory) -> [PersonaIndividual] {
        allPersonas[category] ?? []
    }

    /// 模拟异步 AI 建议生成（流式逐字输出）
    func generateAIAdvice(for persona: PersonaIndividual) {
        currentPersona = persona
        aiAdviceText = ""
        showAISheet = true
        isLoadingAI = true

        Task { @MainActor in
            let fullText = Self.adviceMarkdown(for: persona)
            // 模拟流式输出：每隔 20ms 追加一个字符
            for char in fullText {
                try? await Task.sleep(nanoseconds: 20_000_000)
                aiAdviceText.append(char)
            }
            isLoadingAI = false
        }
    }

    // MARK: - AI Narrative Generator

    private static func adviceMarkdown(for persona: PersonaIndividual) -> String {
        let topRec = persona.recommendations.sorted { $0.matchScore > $1.matchScore }.prefix(3)
        let recList = topRec.map { "- **\($0.name)** (\($0.type.rawValue))：\($0.reason)" }.joined(separator: "\n")
        let historyTotal = String(format: "%.0f", persona.totalHistorySpend)
        let todayTotal   = String(format: "%.0f", persona.totalTodaySpend)
        let upsellAmount = String(format: "%.0f", Double.random(in: 200...600))

        return """
        ## 🤖 AI 决策建议 · \(persona.name)

        ### 消费画像分析
        > 该客群（**\(persona.category.rawValue)**）历史累计消费 **¥\(historyTotal)**，今日已消费 **¥\(todayTotal)**。\
        综合消费节奏与同类人群对标数据，当前存在 **¥\(upsellAmount)** 的增量消费空间。

        ### 🎯 精准推荐策略
        \(recList)

        ### 💡 运营建议
        1. **最优时机**：当前距离闭园还有约 3 小时，该客群的二次消费通常发生在 17:00-19:00，建议在 **16:45** 推送定向优惠券。
        2. **捆绑售卖**：将排名第一的推荐项目与园区特色周边组合打包，预计可提升 **23% 的转化率**。
        3. **情感触点**：\(categorySpecificTip(persona.category))

        ### ⚠️ 风险提示
        - 若当日消费已超历史均值 150%，请勿过度推送，避免客诉风险。
        - 天气敏感型项目建议保留候补名额。

        ---
        *由 TPI-GAI v2.3.1 生成 · 置信度 \(Int.random(in: 88...97))%*
        """
    }

    private static func categorySpecificTip(_ category: PersonaCategory) -> String {
        switch category {
        case .couples:
            return "情侣客群对「纪念品 + 拍照套餐」接受度高，推荐在热门打卡点附近设置限时特惠摊位。"
        case .families:
            return "家庭客群决策者为家长，主推儿童周边与亲子套餐，强调「孩子喜欢」的情感触发点。"
        case .seniors:
            return "老年客群重视性价比与舒适度，推荐「悠享午后茶歇套餐」，避免推荐高强度刺激项目。"
        case .girls:
            return "女性客群对「限定款」和「拍照道具租赁」转化率极高，搭配社交媒体挑战活动效果更佳。"
        }
    }
}
