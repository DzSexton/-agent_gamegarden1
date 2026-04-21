import SwiftUI

struct WeatherInsightSheet: View {
    let viewModel: WeatherViewModel
    @Environment(\.dismiss) private var dismiss

    private enum Phase { case loading, result }
    @State private var phase: Phase = .loading
    @State private var recVisible: [Bool] = []
    @State private var isRotating = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.031, green: 0.047, blue: 0.094).ignoresSafeArea()

                Group {
                    if phase == .loading { loadingView } else { resultView }
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.96)),
                    removal: .opacity
                ))
                .animation(.easeInOut(duration: 0.4), value: phase)
            }
            .navigationTitle("AI 运营建议报告")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if phase == .result {
                        Button("完成") { dismiss() }.fontWeight(.semibold).foregroundStyle(.blue)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Label("TPI-GAI v2.3.1", systemImage: "brain")
                        .font(.caption2).foregroundStyle(.secondary)
                        .labelStyle(.titleAndIcon)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
        .task { await run() }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 28) {
            Spacer()
            ZStack {
                pulsingRing(index: 0)
                pulsingRing(index: 1)
                pulsingRing(index: 2)
                Circle()
                    .trim(from: 0, to: 0.70)
                    .stroke(
                        AngularGradient(colors: [viewModel.dominantType.color, .purple, .clear], center: .center),
                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                    )
                    .frame(width: 74, height: 74)
                    .rotationEffect(.degrees(isRotating ? 360 : 0))
                    .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: isRotating)

                Image(systemName: viewModel.dominantType.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(viewModel.dominantType.color)
            }
            .onAppear { isRotating = true }

            VStack(spacing: 6) {
                Text("AI 正在分析今日天气策略").font(.title3.weight(.semibold)).foregroundStyle(.white)
                Text("综合天气序列、历史对标与定价模型...").font(.subheadline).foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 10) {
                loadStep("解析今日 15 小时天气序列",   done: true)
                loadStep("匹配历史相似日数据",         done: true)
                loadStep("运行 recommendationEngine", done: false, active: true)
                loadStep("生成最终运营报告",            done: false)
            }
            .padding(20)
            .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.07), lineWidth: 1))
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    private func pulsingRing(index i: Int) -> some View {
        let size = CGFloat(76 + i * 26)
        let opacity = 0.20 - Double(i) * 0.05
        return Circle()
            .stroke(viewModel.dominantType.color.opacity(opacity), lineWidth: 1)
            .frame(width: size, height: size)
            .scaleEffect(isRotating ? 1.07 : 0.93)
            .animation(
                .easeInOut(duration: 1.4).repeatForever(autoreverses: true).delay(Double(i) * 0.25),
                value: isRotating
            )
    }

    private func loadStep(_ text: String, done: Bool, active: Bool = false) -> some View {
        HStack(spacing: 10) {
            Group {
                if done        { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green) }
                else if active { ProgressView().scaleEffect(0.7).tint(viewModel.dominantType.color) }
                else           { Image(systemName: "circle").foregroundStyle(.tertiary) }
            }.frame(width: 20)
            Text(text).font(.callout)
                .foregroundStyle(done ? Color.white : active ? viewModel.dominantType.color : Color(white: 0.4))
        }
    }

    // MARK: - Result

    private var resultView: some View {
        ScrollView {
            VStack(spacing: 16) {
                // ── Weather summary banner ──
                HStack(spacing: 10) {
                    Image(systemName: viewModel.dominantType.icon)
                        .font(.title2).foregroundStyle(viewModel.dominantType.color)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("今日天气：\(viewModel.todaySummaryLabel)")
                            .font(.headline).foregroundStyle(.white)
                        Text(viewModel.dominantType.isRainy
                             ? "雨天运营模式 · 室内导流优先"
                             : viewModel.dominantType.isHot
                             ? "高温运营模式 · 清凉产品优先"
                             : "常规运营模式 · 晴天溢价策略")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(16)
                .background(viewModel.dominantType.color.opacity(0.10), in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(viewModel.dominantType.color.opacity(0.25), lineWidth: 1))

                // ── Section A: Dynamic pricing ──
                sectionCard(title: "A. 动态调价建议", icon: "chart.line.uptrend.xyaxis") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(viewModel.overallPriceAdvice)
                            .font(.subheadline).foregroundStyle(.white.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)

                        Text(viewModel.priceRangeText)
                            .font(.callout.bold()).foregroundStyle(.green)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(.green.opacity(0.09), in: RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(.green.opacity(0.2), lineWidth: 1))

                        // Mini price delta bars
                        let rainyHours  = viewModel.hourlyWeather.filter { $0.type.isRainy }.count
                        let sunnyHours  = viewModel.hourlyWeather.filter { $0.type.isSunny }.count
                        let neutralHours = viewModel.hourlyWeather.count - rainyHours - sunnyHours

                        HStack(spacing: 8) {
                            periodBadge(icon: "sun.max.fill",        color: .yellow, label: "晴天时段", count: sunnyHours)
                            periodBadge(icon: "cloud.fill",           color: .gray,   label: "阴云时段", count: neutralHours)
                            periodBadge(icon: "cloud.heavyrain.fill", color: .blue,   label: "雨天时段", count: rainyHours)
                        }
                    }
                }

                // ── Section B: Package recommendations ──
                sectionCard(title: "B. 精准推送 · 套餐推荐", icon: "gift.fill") {
                    VStack(spacing: 10) {
                        Text("基于「\(viewModel.dominantType.displayName)」主导天气，AI 推荐以下运营动作：")
                            .font(.caption).foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(Array(viewModel.recommendations().enumerated()), id: \.element.id) { idx, rec in
                            recCard(rec, visible: idx < recVisible.count && recVisible[idx])
                        }
                    }
                }
            }
            .padding(20)
        }
    }

    // MARK: - Sub-components

    private func sectionCard<C: View>(title: String, icon: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon).font(.subheadline.weight(.semibold)).foregroundStyle(.white)
            content()
        }
        .padding(16)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.09), lineWidth: 1))
    }

    private func periodBadge(icon: String, color: Color, label: String, count: Int) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.body).foregroundStyle(color)
            Text("\(count)h").font(.callout.bold()).foregroundStyle(.white)
            Text(label).font(.system(size: 9)).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 10)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(color.opacity(0.18), lineWidth: 1))
    }

    private func recCard(_ rec: WeatherRecommendation, visible: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: rec.icon).font(.title3).foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(rec.accentColor.gradient, in: RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(rec.title).font(.callout.weight(.semibold)).foregroundStyle(.white)
                    Spacer()
                    Text(rec.category).font(.caption2).foregroundStyle(rec.accentColor)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(rec.accentColor.opacity(0.12), in: Capsule())
                }
                Text(rec.detail).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text(rec.uplift).font(.caption.bold()).foregroundStyle(rec.accentColor)
            }
        }
        .padding(12)
        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(rec.accentColor.opacity(0.2), lineWidth: 1))
        .opacity(visible ? 1 : 0)
        .offset(x: visible ? 0 : 28)
        .animation(.spring(duration: 0.45, bounce: 0.25), value: visible)
    }

    // MARK: - Async flow

    private func run() async {
        try? await Task.sleep(for: .milliseconds(1600))
        withAnimation(.easeInOut(duration: 0.4)) { phase = .result }

        let count = viewModel.recommendations().count
        recVisible = Array(repeating: false, count: count)
        for i in 0..<count {
            try? await Task.sleep(for: .milliseconds(180))
            recVisible[i] = true
        }
    }
}
