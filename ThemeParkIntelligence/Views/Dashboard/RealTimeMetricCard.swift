import SwiftUI

struct RealTimeMetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let trend: TrendIndicator?
    let accentColor: Color

    enum TrendIndicator {
        case up(String)
        case down(String)
        case neutral(String)

        var icon: String {
            switch self { case .up:      return "arrow.up.right"
                          case .down:    return "arrow.down.right"
                          case .neutral: return "arrow.right" }
        }

        var color: Color {
            switch self { case .up:      return .green
                          case .down:    return .red
                          case .neutral: return .secondary }
        }

        var label: String {
            switch self { case .up(let l), .down(let l), .neutral(let l): return l }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Circle()
                    .fill(accentColor.opacity(0.2))
                    .frame(width: 8, height: 8)
                    .overlay(Circle().fill(accentColor))
            }

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            HStack(spacing: 4) {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                if let trend {
                    Spacer()
                    Label(trend.label, systemImage: trend.icon)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(trend.color)
                }
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(accentColor.opacity(0.2), lineWidth: 1)
        )
    }
}
