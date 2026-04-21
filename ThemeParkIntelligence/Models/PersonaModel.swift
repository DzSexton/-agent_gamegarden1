import SwiftUI

// MARK: - Category

enum PersonaCategory: String, CaseIterable, Identifiable, Hashable {
    case couples  = "情侣"
    case families = "家庭"
    case seniors  = "老人"
    case girls    = "女生"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .couples:  return "heart.fill"
        case .families: return "house.fill"
        case .seniors:  return "figure.walk"
        case .girls:    return "sparkles"
        }
    }

    var accentColor: Color {
        switch self {
        case .couples:  return Color(red: 0.98, green: 0.36, blue: 0.54)   // 玫红
        case .families: return Color(red: 0.25, green: 0.60, blue: 0.98)   // 天蓝
        case .seniors:  return Color(red: 0.42, green: 0.78, blue: 0.56)   // 翠绿
        case .girls:    return Color(red: 0.72, green: 0.45, blue: 0.98)   // 紫罗兰
        }
    }

    var gradientColors: [Color] {
        [accentColor.opacity(0.9), accentColor.opacity(0.5)]
    }

    var description: String {
        switch self {
        case .couples:  return "双人体验 · 浪漫定制"
        case .families: return "亲子出行 · 全家欢乐"
        case .seniors:  return "悠享时光 · 舒适体验"
        case .girls:    return "闺蜜打卡 · 潮流种草"
        }
    }
}

// MARK: - Individual Persona

struct PersonaIndividual: Identifiable, Hashable {
    let id: UUID
    let name: String
    let subtitle: String
    let category: PersonaCategory
    let avatarEmoji: String
    let tags: [String]
    let historyRecords: [ConsumptionRecord]
    let todayRecords: [ConsumptionRecord]
    let recommendations: [Recommendation]

    init(
        id: UUID = UUID(),
        name: String,
        subtitle: String,
        category: PersonaCategory,
        avatarEmoji: String,
        tags: [String],
        historyRecords: [ConsumptionRecord],
        todayRecords: [ConsumptionRecord],
        recommendations: [Recommendation]
    ) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.category = category
        self.avatarEmoji = avatarEmoji
        self.tags = tags
        self.historyRecords = historyRecords
        self.todayRecords = todayRecords
        self.recommendations = recommendations
    }

    // Hashable by id only — avoids deep equality checks on nested arrays
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: PersonaIndividual, rhs: PersonaIndividual) -> Bool { lhs.id == rhs.id }

    var totalHistorySpend: Double {
        historyRecords.flatMap(\.items).reduce(0) { $0 + $1.price * Double($1.quantity) }
    }

    var totalTodaySpend: Double {
        todayRecords.flatMap(\.items).reduce(0) { $0 + $1.price * Double($1.quantity) }
    }
}

// MARK: - Consumption Record

struct ConsumptionRecord: Identifiable, Hashable {
    let id: UUID
    let location: String
    let locationIcon: String
    let date: Date
    let items: [PurchaseItem]

    init(
        id: UUID = UUID(),
        location: String,
        locationIcon: String,
        date: Date,
        items: [PurchaseItem]
    ) {
        self.id = id
        self.location = location
        self.locationIcon = locationIcon
        self.date = date
        self.items = items
    }

    var totalAmount: Double {
        items.reduce(0) { $0 + $1.price * Double($1.quantity) }
    }
}

struct PurchaseItem: Identifiable, Hashable {
    let id: UUID
    let name: String
    let price: Double
    let quantity: Int
    let emoji: String

    init(id: UUID = UUID(), name: String, price: Double, quantity: Int = 1, emoji: String) {
        self.id = id
        self.name = name
        self.price = price
        self.quantity = quantity
        self.emoji = emoji
    }
}

// MARK: - Recommendation

struct Recommendation: Identifiable, Hashable {
    let id: UUID
    let name: String
    let type: RecommendationType
    let reason: String
    let matchScore: Double   // 0-1
    let emoji: String

    init(
        id: UUID = UUID(),
        name: String,
        type: RecommendationType,
        reason: String,
        matchScore: Double,
        emoji: String
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.reason = reason
        self.matchScore = matchScore
        self.emoji = emoji
    }

    enum RecommendationType: String, Hashable {
        case attraction  = "游乐设施"
        case dining      = "餐饮"
        case merchandise = "周边商品"
        case photo       = "拍照打卡"

        var icon: String {
            switch self {
            case .attraction:  return "ferriswheel"
            case .dining:      return "fork.knife"
            case .merchandise: return "bag.fill"
            case .photo:       return "camera.fill"
            }
        }
    }
}

// MARK: - Navigation Route

enum PersonaRoute: Hashable {
    case list(PersonaCategory)
    case detail(PersonaIndividual)
}
