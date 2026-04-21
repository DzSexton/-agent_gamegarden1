import SwiftUI

struct PersonaListView: View {
    let category: PersonaCategory
    let personas: [PersonaIndividual]
    @Binding var navPath: NavigationPath

    var body: some View {
        List {
            // 分类头部信息卡
            Section {
                categoryHeaderCard
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

            // 人物列表
            Section("档案列表 (\(personas.count))") {
                ForEach(personas) { persona in
                    personaRow(persona)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            navPath.append(PersonaRoute.detail(persona))
                        }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Header Card

    private var categoryHeaderCard: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: category.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 140)

            // 装饰背景图标
            Image(systemName: category.icon)
                .font(.system(size: 100))
                .foregroundStyle(.white.opacity(0.10))
                .offset(x: UIScreen.main.bounds.width - 150, y: 20)

            VStack(alignment: .leading, spacing: 6) {
                Label(category.rawValue, systemImage: category.icon)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text(category.description)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
                Text("共 \(personas.count) 份档案 · 点击查看消费洞察")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.70))
            }
            .padding(20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Persona Row

    private func personaRow(_ persona: PersonaIndividual) -> some View {
        HStack(spacing: 14) {
            // 头像
            Text(persona.avatarEmoji)
                .font(.system(size: 36))
                .frame(width: 52, height: 52)
                .background(category.accentColor.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(persona.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(persona.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // 标签
                HStack(spacing: 4) {
                    ForEach(persona.tags.prefix(2), id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(category.accentColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(category.accentColor.opacity(0.12), in: Capsule())
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("¥\(String(format: "%.0f", persona.totalHistorySpend))")
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                    .monospacedDigit()
                Text("历史消费")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 6)
    }
}
