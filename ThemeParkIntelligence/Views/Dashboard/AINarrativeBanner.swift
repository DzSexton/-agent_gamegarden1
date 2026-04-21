import SwiftUI

struct AINarrativeBanner: View {
    let narrative: AInarrative
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                // AI 标识徽章
                Label("AI 决策摘要", systemImage: "brain.head.profile")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.purple.gradient, in: Capsule())

                Spacer()

                // 置信度
                Text("置信度 \(Int(narrative.confidence * 100))%")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text(narrative.modelVersion)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Text(narrative.summary)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(isExpanded ? nil : 3)
                .animation(.easeInOut(duration: 0.2), value: isExpanded)

            HStack {
                // 生成时间
                Label(
                    narrative.generatedAt.formatted(date: .omitted, time: .shortened),
                    systemImage: "clock"
                )
                .font(.caption2)
                .foregroundStyle(.tertiary)

                Spacer()

                Button(isExpanded ? "收起" : "展开") {
                    withAnimation { isExpanded.toggle() }
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(.purple)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.purple.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.purple.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
