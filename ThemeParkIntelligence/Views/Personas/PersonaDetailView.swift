import SwiftUI

struct PersonaDetailView: View {
    let persona: PersonaIndividual
    @Bindable var viewModel: PersonaViewModel

    var body: some View {
        List {

            // ── Row 1: History ─────────────────────────────────────────────
            Section {
                if persona.historyRecords.isEmpty {
                    emptyRow(text: "暂无历史消费记录")
                } else {
                    ForEach(persona.historyRecords) { record in
                        consumptionRecordRow(record, style: .history)
                    }
                }
            } header: {
                sectionHeader(
                    title: "历史消费",
                    subtitle: "¥\(String(format: "%.0f", persona.totalHistorySpend))",
                    icon: "clock.arrow.circlepath",
                    color: .blue
                )
            }

            // ── Row 2: Today ───────────────────────────────────────────────
            Section {
                if persona.todayRecords.isEmpty {
                    emptyRow(text: "今日尚无消费记录")
                } else {
                    ForEach(persona.todayRecords) { record in
                        consumptionRecordRow(record, style: .today)
                    }
                    totalTodayRow
                }
            } header: {
                sectionHeader(
                    title: "今日消费",
                    subtitle: persona.todayRecords.isEmpty ? "进行中" : "¥\(String(format: "%.0f", persona.totalTodaySpend))",
                    icon: "sun.max.fill",
                    color: .orange
                )
            }

            // ── Row 3: Recommendations ─────────────────────────────────────
            Section {
                ForEach(persona.recommendations.sorted { $0.matchScore > $1.matchScore }) { rec in
                    recommendationRow(rec)
                }
            } header: {
                sectionHeader(
                    title: "其他推荐",
                    subtitle: "基于\(persona.category.rawValue)偏好",
                    icon: "sparkles",
                    color: .purple
                )
            }

            // ── Row 4: AI Action ───────────────────────────────────────────
            Section {
                aiActionButton
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .listRowBackground(Color.clear)
        }
        .listStyle(.insetGrouped)
        .navigationTitle(persona.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { personaTagsToolbar }
        .sheet(isPresented: $viewModel.showAISheet) {
            AIAdviceSheet(viewModel: viewModel)
        }
    }

    // MARK: - Section Header

    private func sectionHeader(title: String, subtitle: String, icon: String, color: Color) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
            Spacer()
            Text(subtitle)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Consumption Record Row

    private enum RecordStyle { case history, today }

    private func consumptionRecordRow(_ record: ConsumptionRecord, style: RecordStyle) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // 地点 + 时间
            HStack {
                Text(record.locationIcon)
                Text(record.location)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(style == .today
                     ? record.date.formatted(date: .omitted, time: .shortened)
                     : record.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            // 消费明细
            ForEach(record.items) { item in
                HStack {
                    Text(item.emoji)
                    Text(item.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if item.quantity > 1 {
                        Text("×\(item.quantity)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    Spacer()
                    Text("¥\(String(format: "%.0f", item.price * Double(item.quantity)))")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.primary)
                }
            }

            // 小计
            HStack {
                Spacer()
                Text("小计 ¥\(String(format: "%.0f", record.totalAmount))")
                    .font(.caption.bold())
                    .foregroundStyle(style == .today ? .orange : .blue)
            }
        }
        .padding(.vertical, 4)
    }

    private var totalTodayRow: some View {
        HStack {
            Text("今日合计")
                .font(.subheadline.weight(.semibold))
            Spacer()
            Text("¥\(String(format: "%.0f", persona.totalTodaySpend))")
                .font(.subheadline.bold())
                .foregroundStyle(.orange)
                .monospacedDigit()
        }
        .padding(.vertical, 2)
    }

    // MARK: - Recommendation Row

    private func recommendationRow(_ rec: Recommendation) -> some View {
        HStack(spacing: 12) {
            // 类型图标
            Image(systemName: rec.type.icon)
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(persona.category.accentColor.gradient, in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(rec.emoji + " " + rec.name)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    matchScoreBadge(rec.matchScore)
                }
                Text(rec.reason)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text(rec.type.rawValue)
                    .font(.caption2)
                    .foregroundStyle(persona.category.accentColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(persona.category.accentColor.opacity(0.12), in: Capsule())
            }
        }
        .padding(.vertical, 4)
    }

    private func matchScoreBadge(_ score: Double) -> some View {
        Text("\(Int(score * 100))%")
            .font(.caption2.bold())
            .foregroundStyle(score > 0.9 ? .green : score > 0.8 ? .orange : .secondary)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                (score > 0.9 ? Color.green : score > 0.8 ? Color.orange : Color.secondary)
                    .opacity(0.12),
                in: Capsule()
            )
    }

    // MARK: - AI Button

    private var aiActionButton: some View {
        Button {
            viewModel.generateAIAdvice(for: persona)
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("AI 智能建议")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("生成个性化运营策略与增收方案")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.purple)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(colors: [.purple.opacity(0.5), .blue.opacity(0.3)],
                                               startPoint: .leading, endPoint: .trailing),
                                lineWidth: 1.5
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty State

    private func emptyRow(text: String) -> some View {
        HStack {
            Spacer()
            Text(text)
                .font(.caption)
                .foregroundStyle(.tertiary)
            Spacer()
        }
        .padding(.vertical, 8)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var personaTagsToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 4) {
                ForEach(persona.tags.prefix(1), id: \.self) { tag in
                    Text(tag)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(persona.category.accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(persona.category.accentColor.opacity(0.15), in: Capsule())
                }
            }
        }
    }
}
