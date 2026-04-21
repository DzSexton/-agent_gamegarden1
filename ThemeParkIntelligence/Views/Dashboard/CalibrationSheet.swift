import SwiftUI

// MARK: - Data

private struct ParamDelta: Identifiable {
    let id = UUID()
    let icon: String
    let chName: String
    let techName: String
    let delta: Double
}

private let deltas: [ParamDelta] = [
    ParamDelta(icon: "cloud.sun.fill",   chName: "天气权重特征",   techName: "weather_feature_weight",       delta: +0.04),
    ParamDelta(icon: "building.2.fill",  chName: "竞品价格弹性",   techName: "competitor_price_elasticity",  delta: -0.02),
    ParamDelta(icon: "clock.fill",       chName: "时段偏差修正",   techName: "time_slot_bias",               delta: +0.03),
]

// MARK: - CalibrationSheet

struct CalibrationSheet: View {

    let predictedValue: Int
    let actualValue: Int

    @Environment(\.dismiss) private var dismiss

    private enum Phase { case loading, result }

    @State private var phase: Phase = .loading
    @State private var isRotating  = false
    @State private var isPulsing   = false
    @State private var newBarFill: Double = 0.82
    @State private var deltaVisible: [Bool] = [false, false, false]

    private let oldConf = 0.82
    private let newConf = 0.95

    private var errorPct: Double {
        guard predictedValue > 0 else { return 0 }
        return abs(Double(predictedValue - actualValue)) / Double(predictedValue) * 100
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.031, green: 0.063, blue: 0.122).ignoresSafeArea()

                Group {
                    if phase == .loading { loadingView } else { resultView }
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.97)),
                    removal:   .opacity
                ))
                .animation(.easeInOut(duration: 0.45), value: phase)
            }
            .navigationTitle("模型自我校准")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if phase == .result {
                        Button("完成") { dismiss() }
                            .fontWeight(.semibold).foregroundStyle(.green)
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
        .task { await runCalibration() }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 36) {
            Spacer()

            // Animated rings + brain icon
            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(Color.blue.opacity(0.25 - Double(i) * 0.06), lineWidth: 1.2)
                        .frame(width: CGFloat(84 + i * 30), height: CGFloat(84 + i * 30))
                        .scaleEffect(isPulsing ? 1.08 : 0.94)
                        .animation(
                            .easeInOut(duration: 1.3).repeatForever(autoreverses: true).delay(Double(i) * 0.28),
                            value: isPulsing
                        )
                }
                // Rotating trim arc
                Circle()
                    .trim(from: 0, to: 0.72)
                    .stroke(
                        AngularGradient(colors: [.blue, .purple, .clear], center: .center),
                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                    )
                    .frame(width: 82, height: 82)
                    .rotationEffect(.degrees(isRotating ? 360 : 0))
                    .animation(.linear(duration: 1.4).repeatForever(autoreverses: false), value: isRotating)

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 30))
                    .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom))
            }
            .onAppear { isPulsing = true; isRotating = true }

            VStack(spacing: 8) {
                Text("AI 正在自我强化学习与拟合中")
                    .font(.title3.weight(.semibold)).foregroundStyle(.white)
                Text("正在将实测数据反向传播至预测模型...")
                    .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
            }
            .padding(.horizontal)

            // Fake progress steps
            VStack(alignment: .leading, spacing: 12) {
                step("收集实测观测值",              done: true)
                step("计算误差指标 (MAE / RMSE)",   done: true)
                step("反向传播，更新权重梯度",        done: false, active: true)
                step("持久化模型检查点",             done: false)
            }
            .padding(20)
            .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.08), lineWidth: 1))
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    private func step(_ text: String, done: Bool, active: Bool = false) -> some View {
        HStack(spacing: 10) {
            Group {
                if done        { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green) }
                else if active { ProgressView().scaleEffect(0.7).tint(.blue) }
                else           { Image(systemName: "circle").foregroundStyle(.tertiary) }
            }
            .frame(width: 20)
            Text(text)
                .font(.callout)
                .foregroundStyle(done ? Color.white : active ? Color.blue : Color(white: 0.4))
        }
    }

    // MARK: - Result View

    private var resultView: some View {
        ScrollView {
            VStack(spacing: 14) {
                // ── Success banner ──
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill").font(.title2).foregroundStyle(.green)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("校准完成").font(.headline).foregroundStyle(.white)
                        Text("模型已成功吸收本次实测数据并更新参数")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(16)
                .background(.green.opacity(0.10), in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(.green.opacity(0.28), lineWidth: 1))

                // ── Error analysis ──
                resultCard(title: "误差分析", icon: "chart.xyaxis.line") {
                    HStack(spacing: 0) {
                        valueBlock(label: "预测值", text: "\(predictedValue.formatted()) 人", color: .blue)
                        VStack(spacing: 4) {
                            Image(systemName: "arrow.right").foregroundStyle(.secondary)
                            Text("误差 \(String(format: "%.1f", errorPct))%")
                                .font(.caption2)
                                .foregroundStyle(errorPct < 10 ? .green : .orange)
                        }
                        .frame(maxWidth: .infinity)
                        valueBlock(label: "实际值", text: "\(actualValue.formatted()) 人", color: .orange)
                    }
                }

                // ── Confidence jump ──
                resultCard(title: "置信度跃升", icon: "arrow.up.circle.fill") {
                    VStack(spacing: 10) {
                        confBar(label: "校准前", fill: oldConf, color: .gray.opacity(0.6), animated: false)
                        confBar(label: "校准后", fill: newConf, color: .green, animated: true)
                    }
                    .padding(.top, 4)
                }

                // ── Parameter deltas ──
                resultCard(title: "模型参数微调", icon: "slider.horizontal.3") {
                    VStack(spacing: 10) {
                        Text("以下权重已根据本次误差自动更新：")
                            .font(.caption).foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ForEach(Array(deltas.enumerated()), id: \.element.id) { idx, d in
                            deltaRow(d, visible: idx < deltaVisible.count && deltaVisible[idx])
                        }
                    }
                }
            }
            .padding(20)
        }
    }

    // MARK: - Result sub-components

    private func resultCard<Content: View>(
        title: String, icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold)).foregroundStyle(.white)
            content()
        }
        .padding(16)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.09), lineWidth: 1))
    }

    private func valueBlock(label: String, text: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(text).font(.title3.bold().monospacedDigit()).foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }

    private func confBar(label: String, fill: Double, color: Color, animated: Bool) -> some View {
        HStack(spacing: 10) {
            Text(label).font(.caption).foregroundStyle(.secondary).frame(width: 44, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(.white.opacity(0.07))
                    RoundedRectangle(cornerRadius: 4).fill(color)
                        .frame(width: geo.size.width * (animated ? newBarFill : fill))
                        .animation(.spring(duration: 1.1, bounce: 0.15), value: newBarFill)
                }
            }
            .frame(height: 8)
            Text("\(Int((animated ? newBarFill : fill) * 100))%")
                .font(.caption.bold().monospacedDigit()).foregroundStyle(color)
                .contentTransition(.numericText())
                .frame(width: 36, alignment: .trailing)
        }
    }

    private func deltaRow(_ d: ParamDelta, visible: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: d.icon).font(.callout).foregroundStyle(.blue).frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(d.chName).font(.callout.weight(.medium)).foregroundStyle(.white)
                Text(d.techName).font(.caption2).foregroundStyle(.tertiary).fontDesign(.monospaced)
            }
            Spacer()
            HStack(spacing: 3) {
                Image(systemName: d.delta > 0 ? "arrow.up" : "arrow.down")
                    .font(.caption.weight(.bold))
                Text(d.delta > 0 ? "+\(String(format: "%.2f", d.delta))" : String(format: "%.2f", d.delta))
                    .font(.callout.bold().monospacedDigit())
            }
            .foregroundStyle(d.delta > 0 ? .green : .orange)
        }
        .padding(12)
        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.white.opacity(0.07), lineWidth: 1))
        .opacity(visible ? 1 : 0)
        .offset(x: visible ? 0 : 24)
        .animation(.spring(duration: 0.5, bounce: 0.3), value: visible)
    }

    // MARK: - Async state machine

    private func runCalibration() async {
        try? await Task.sleep(for: .seconds(2.3))
        withAnimation(.easeInOut(duration: 0.45)) { phase = .result }

        try? await Task.sleep(for: .milliseconds(350))
        withAnimation { newBarFill = newConf }

        for i in 0..<deltas.count {
            try? await Task.sleep(for: .milliseconds(220))
            if i < deltaVisible.count { deltaVisible[i] = true }
        }
    }
}
