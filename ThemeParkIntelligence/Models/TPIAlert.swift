import Foundation

struct TPIAlert: Identifiable, Codable {
    let id: UUID
    let severity: Severity
    let category: Category
    let title: String
    let detail: String
    let triggeredAt: Date
    var isAcknowledged: Bool

    init(
        id: UUID = UUID(),
        severity: Severity,
        category: Category,
        title: String,
        detail: String,
        triggeredAt: Date = Date(),
        isAcknowledged: Bool = false
    ) {
        self.id = id
        self.severity = severity
        self.category = category
        self.title = title
        self.detail = detail
        self.triggeredAt = triggeredAt
        self.isAcknowledged = isAcknowledged
    }

    enum Severity: String, Codable {
        case critical, warning, info

        var priority: Int {
            switch self { case .critical: return 3; case .warning: return 2; case .info: return 1 }
        }
    }

    enum Category: String, Codable {
        case capacity    = "capacity"
        case revenue     = "revenue"
        case weather     = "weather"
        case operations  = "operations"

        var displayName: String {
            switch self {
            case .capacity:   return "容量预警"
            case .revenue:    return "营收异常"
            case .weather:    return "天气影响"
            case .operations: return "运营事件"
            }
        }
    }
}
