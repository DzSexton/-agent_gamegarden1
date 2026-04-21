import SwiftUI

struct AlertCenterView: View {
    let alerts: [TPIAlert]

    private var grouped: [(TPIAlert.Severity, [TPIAlert])] {
        let order: [TPIAlert.Severity] = [.critical, .warning, .info]
        return order.compactMap { severity in
            let items = alerts.filter { $0.severity == severity }
            return items.isEmpty ? nil : (severity, items)
        }
    }

    var body: some View {
        List {
            ForEach(grouped, id: \.0) { severity, items in
                Section(header: severityHeader(severity)) {
                    ForEach(items) { alert in
                        AlertRowView(alert: alert, onAcknowledge: nil)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("预警中心")
        .navigationBarTitleDisplayMode(.large)
    }

    private func severityHeader(_ severity: TPIAlert.Severity) -> some View {
        Label(severity.displayName, systemImage: severity.icon)
            .font(.caption.weight(.semibold))
            .foregroundStyle(severity.color)
    }
}

// MARK: - Reusable row used by both DashboardView and AlertCenterView

struct AlertRowView: View {
    let alert: TPIAlert
    let onAcknowledge: (() -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: alert.severity.icon)
                .font(.title3)
                .foregroundStyle(alert.severity.color)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(alert.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(alert.isAcknowledged ? .secondary : .primary)
                    Spacer()
                    Text(alert.triggeredAt, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Text(alert.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Text(alert.category.displayName)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(alert.severity.color.opacity(0.12), in: Capsule())
                        .foregroundStyle(alert.severity.color)

                    if alert.isAcknowledged {
                        Label("已确认", systemImage: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    } else if let ack = onAcknowledge {
                        Button("确认", action: ack)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .opacity(alert.isAcknowledged ? 0.6 : 1.0)
    }
}

// MARK: - TPIAlert display extensions

private extension TPIAlert.Severity {
    var displayName: String {
        switch self {
        case .critical: return "严重告警"
        case .warning:  return "警告"
        case .info:     return "通知"
        }
    }

    var icon: String {
        switch self {
        case .critical: return "exclamationmark.triangle.fill"
        case .warning:  return "exclamationmark.circle.fill"
        case .info:     return "info.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .critical: return .red
        case .warning:  return .orange
        case .info:     return .blue
        }
    }
}
