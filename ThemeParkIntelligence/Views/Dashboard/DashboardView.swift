import SwiftUI
import Charts

// MARK: - Shared hex color helper (available project-wide)

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var n: UInt64 = 0
        Scanner(string: h).scanHexInt64(&n)
        self.init(
            red:   Double((n >> 16) & 0xFF) / 255,
            green: Double((n >> 8)  & 0xFF) / 255,
            blue:  Double( n        & 0xFF) / 255
        )
    }
}

// MARK: - Local hourly data model

private struct HourlyForecast: Identifiable {
    let id = UUID()
    let hour: Int
    let demand: Double        // raw visitors
    let optimalPrice: Double  // ¥
    let confidence: Double    // 0-1

    /// Scale price into demand-chart range (0…42k) for visual overlay
    var priceOnDemandAxis: Double { (optimalPrice - 299.0) * (37_000.0 / 200.0) / 1_000.0 + 5.0 }
}

private let hourlyData: [HourlyForecast] = {
    // 平滑正弦型客流曲线：凌晨低谷 → 早高峰 → 午后峰值 → 傍晚次峰 → 收园递减
    let d: [Double] = [
        1800, 1200,  900,  800,  900, 1800,   // 0-5  凌晨
        4500, 8500, 13500, 19000, 24500, 29500, // 6-11 早晨开园
        33500, 37000, 40000, 41500, 40500, 37500, // 12-17 午后高峰
        34000, 31000, 28500, 25000, 20500, 15000  // 18-23 傍晚收园
    ]
    // 价格随客流动态调整，呈现相似弧形
    let p: [Double] = [
        299, 299, 299, 299, 299, 309,
        319, 339, 359, 379, 399, 419,
        439, 455, 469, 475, 469, 455,
        439, 425, 415, 399, 379, 349
    ]
    let c: [Double] = [
        0.50, 0.48, 0.46, 0.46, 0.48, 0.54,
        0.62, 0.70, 0.78, 0.85, 0.90, 0.93,
        0.95, 0.96, 0.96, 0.95, 0.93, 0.90,
        0.87, 0.84, 0.81, 0.77, 0.72, 0.66
    ]
    return (0..<24).map { HourlyForecast(hour: $0, demand: d[$0], optimalPrice: p[$0], confidence: c[$0]) }
}()

// MARK: - DashboardView

struct DashboardView: View {

    @State private var actualInput: String = ""
    @State private var showSheet   = false
    @State private var animated    = false

    private var nowHour: Int { Calendar.current.component(.hour, from: Date()) }
    private var nowPoint:  HourlyForecast? { hourlyData.first { $0.hour == nowHour } }
    private var nextPoint: HourlyForecast? { hourlyData.first { $0.hour == (nowHour + 1) % 24 } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    kpiRow
                    dualChartCard
                    insightCard
                    groundTruthCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(Color(hex: "080C18").ignoresSafeArea())
            .navigationTitle("运营总览")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { liveTag }
            }
        }
        .sheet(isPresented: $showSheet) {
            CalibrationSheet(
                predictedValue: 35_000,
                actualValue: Int(actualInput) ?? 32_000
            )
        }
        .task {
            try? await Task.sleep(for: .milliseconds(400))
            withAnimation(.easeOut(duration: 1.0)) { animated = true }
        }
    }

    // MARK: - Live badge

    private var liveTag: some View {
        HStack(spacing: 5) {
            Circle().fill(.green).frame(width: 7, height: 7)
            Text("LIVE").font(.caption2.bold()).foregroundStyle(.green)
        }
        .padding(.horizontal, 8).padding(.vertical, 4)
        .background(.green.opacity(0.12), in: Capsule())
    }

    // MARK: - 1. KPI Row

    private var kpiRow: some View {
        HStack(spacing: 10) {
            kpi(
                icon: "person.3.fill", color: .blue,
                value: nowPoint.map { "\(Int($0.demand / 1000))k 人" } ?? "38k 人",
                label: "当前在园客流",
                note: nowPoint.map { _ in "峰值预计 \(Int(hourlyData.max(by: { a, b in a.demand < b.demand })!.demand / 1000))k" } ?? "↑ 上升中"
            )
            kpi(
                icon: "yensign.circle.fill", color: .green,
                value: nowPoint.map { "¥\(Int($0.optimalPrice))" } ?? "¥429",
                label: "AI 建议当前票价",
                note: "今日预估营收 ¥2.3M"
            )
        }
    }

    private func kpi(icon: String, color: Color, value: String, label: String, note: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon).font(.title3).foregroundStyle(color)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white).minimumScaleFactor(0.6).lineLimit(1)
            Text(label).font(.caption2).foregroundStyle(.secondary)
            Text(note).font(.system(size: 10, weight: .semibold)).foregroundStyle(color.opacity(0.85))
        }
        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.07), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.18), lineWidth: 1))
    }

    // MARK: - 2. Dual Chart Card

    private var dualChartCard: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("24小时预测曲线").font(.headline).foregroundStyle(.white)
                    HStack(spacing: 5) {
                        Image(systemName: "cpu.fill").font(.system(size: 11)).foregroundStyle(.white)
                        Text("XGBoost · LSTM · Random Forest")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(
                        LinearGradient(colors: [.blue, Color(hex: "0055CC")], startPoint: .leading, endPoint: .trailing),
                        in: Capsule()
                    )
                    .shadow(color: .blue.opacity(0.45), radius: 6, x: 0, y: 2)
                }
                Spacer()
                HStack(spacing: 12) {
                    legendDot(.blue,   "客流")
                    legendDot(.green,  "票价(参考)")
                }
            }
            .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 10)

            // Upper: demand + price
            Chart {
                ForEach(hourlyData) { pt in
                    AreaMark(x: .value("H", pt.hour),
                             yStart: .value("V", 0),
                             yEnd:   .value("V", animated ? pt.demand / 1000 : 0))
                    .foregroundStyle(LinearGradient(
                        colors: [.blue.opacity(0.55), .blue.opacity(0.03)],
                        startPoint: .top, endPoint: .bottom))
                    .interpolationMethod(.catmullRom)

                    LineMark(x: .value("H", pt.hour), y: .value("V", animated ? pt.demand / 1000 : 0))
                        .foregroundStyle(.blue).lineStyle(.init(lineWidth: 2)).interpolationMethod(.catmullRom)

                    LineMark(x: .value("H", pt.hour), y: .value("V", animated ? pt.priceOnDemandAxis : 0))
                        .foregroundStyle(.green.opacity(0.85))
                        .lineStyle(.init(lineWidth: 1.5, dash: [5, 3])).interpolationMethod(.catmullRom)
                }
                RuleMark(x: .value("H", nowHour))
                    .foregroundStyle(.white.opacity(0.22))
                    .lineStyle(.init(lineWidth: 1, dash: [3, 3]))
                    .annotation(position: .top) {
                        Text("NOW").font(.system(size: 8, weight: .bold)).foregroundStyle(.white.opacity(0.5))
                    }
                if let cp = nowPoint {
                    PointMark(x: .value("H", cp.hour), y: .value("V", cp.demand / 1000))
                        .foregroundStyle(.white).symbolSize(55)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks(values: [0, 10, 20, 30, 40]) { v in
                    AxisValueLabel {
                        Text("\(v.as(Int.self) ?? 0)k").font(.system(size: 9)).foregroundStyle(.white.opacity(0.35))
                    }
                    AxisGridLine(stroke: .init(lineWidth: 0.4))
                }
            }
            .chartYScale(domain: 0...50)
            .frame(height: 155)
            .padding(.horizontal, 12)

            // Confidence sub-header
            HStack {
                Text("预测置信度").font(.caption.weight(.medium)).foregroundStyle(.secondary)
                Spacer()
                if let cp = nowPoint {
                    Text("\(Int(cp.confidence * 100))%").font(.caption.bold()).foregroundStyle(.purple)
                }
            }
            .padding(.horizontal, 16).padding(.top, 10).padding(.bottom, 4)

            // Lower: confidence
            Chart {
                ForEach(hourlyData) { pt in
                    AreaMark(x: .value("H", pt.hour),
                             yStart: .value("C", 0),
                             yEnd:   .value("C", animated ? pt.confidence * 100 : 0))
                    .foregroundStyle(LinearGradient(
                        colors: [.purple.opacity(0.55), .purple.opacity(0.04)],
                        startPoint: .top, endPoint: .bottom))
                    .interpolationMethod(.catmullRom)

                    LineMark(x: .value("H", pt.hour), y: .value("C", animated ? pt.confidence * 100 : 0))
                        .foregroundStyle(.purple).lineStyle(.init(lineWidth: 1.5)).interpolationMethod(.catmullRom)
                }
                RuleMark(y: .value("C", 80))
                    .foregroundStyle(.purple.opacity(0.3)).lineStyle(.init(lineWidth: 0.8, dash: [4, 2]))
            }
            .chartXAxis {
                AxisMarks(values: stride(from: 0, through: 23, by: 4).map { $0 }) { v in
                    AxisValueLabel {
                        Text("\(v.as(Int.self) ?? 0)h").font(.system(size: 9)).foregroundStyle(.white.opacity(0.35))
                    }
                    AxisGridLine(stroke: .init(lineWidth: 0.4))
                }
            }
            .chartYAxis {
                AxisMarks(values: [0, 50, 100]) { v in
                    AxisValueLabel {
                        Text("\(v.as(Int.self) ?? 0)%").font(.system(size: 9)).foregroundStyle(.white.opacity(0.35))
                    }
                }
            }
            .chartYScale(domain: 0...100)
            .frame(height: 68)
            .padding(.horizontal, 12).padding(.bottom, 14)
        }
        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.09), lineWidth: 1))
    }

    private func legendDot(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
    }

    // MARK: - 3. Insight Card

    private var insightCard: some View {
        VStack(spacing: 0) {
            HStack {
                Label("AI 预测解释", systemImage: "brain.head.profile")
                    .font(.headline).foregroundStyle(.white)
                Spacer()
                HStack(spacing: 6) {
                    HStack(spacing: 5) {
                        Image(systemName: "point.3.connected.trianglepath.dotted")
                            .font(.system(size: 11))
                            .foregroundStyle(.white)
                        Text("机器学习驱动")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(
                        LinearGradient(colors: [.purple, Color(hex: "7B2FBE")], startPoint: .leading, endPoint: .trailing),
                        in: Capsule()
                    )
                    .shadow(color: .purple.opacity(0.45), radius: 6, x: 0, y: 2)

                    Text("TPI-GAI v2.3.1").font(.caption2).foregroundStyle(.tertiary)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(.white.opacity(0.06), in: Capsule())
                }
            }
            .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 12)

            Divider().overlay(.white.opacity(0.08))

            insightRow("sun.max.fill",         .yellow, "天气影响",   "晴天 + 28°C，户外游乐利好，模型上调客流预测 +12%")
            Divider().padding(.leading, 50).overlay(.white.opacity(0.07))
            insightRow("building.2.fill",       .orange, "竞品动态",   "周边 3 家竞品今日正常运营，无折扣促销，分流效应低 (−3%)")
            Divider().padding(.leading, 50).overlay(.white.opacity(0.07))
            insightRow("chart.line.uptrend.xyaxis", .blue, "客流趋势", "近 3 周同期对标呈上行趋势，周均增长 +8.3%，动量强劲")
            Divider().padding(.leading, 50).overlay(.white.opacity(0.07))
            insightRow("calendar.badge.clock",  .purple, "日期特征",   "工作日 + 节假日前夕（周五），历史客流倍率系数 ×1.28")

            Divider().overlay(.white.opacity(0.08))

            if let nxt = nextPoint {
                HStack(spacing: 8) {
                    Image(systemName: "triangle.fill").font(.caption2).foregroundStyle(.green)
                    Text("预测下一小时：").font(.subheadline).foregroundStyle(.secondary)
                    Text("票价 ¥\(Int(nxt.optimalPrice))").font(.subheadline.bold()).foregroundStyle(.green)
                    Text("·").foregroundStyle(.tertiary)
                    Text("客流 \(Int(nxt.demand / 1000))k 人").font(.subheadline.bold()).foregroundStyle(.blue)
                }
                .padding(.horizontal, 16).padding(.vertical, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.green.opacity(0.06))
            }
        }
        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.09), lineWidth: 1))
    }

    private func insightRow(_ icon: String, _ color: Color, _ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon).font(.body).foregroundStyle(color).frame(width: 22).padding(.top, 1)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.callout.weight(.semibold)).foregroundStyle(.white.opacity(0.9))
                Text(detail).font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }

    // MARK: - 4. Ground Truth Card

    private var groundTruthCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("实测数据回填", systemImage: "square.and.pencil")
                .font(.headline).foregroundStyle(.white)

            Text("输入今日实际客流，触发 AI 模型自我校准循环")
                .font(.caption).foregroundStyle(.secondary)

            // Input field
            HStack(spacing: 12) {
                Image(systemName: "person.3.fill").foregroundStyle(.blue.opacity(0.7)).frame(width: 22)
                TextField("", text: $actualInput,
                          prompt: Text("填入今日实际客流人数...").foregroundStyle(.white.opacity(0.22)))
                    .keyboardType(.numberPad)
                    .foregroundStyle(.white)
                    .font(.system(size: 18, weight: .medium, design: .rounded).monospacedDigit())
                if !actualInput.isEmpty {
                    Button { actualInput = "" } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                    }
                }
            }
            .padding(14)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(actualInput.isEmpty ? .white.opacity(0.08) : .blue.opacity(0.55), lineWidth: 1.5)
            )
            .animation(.easeInOut(duration: 0.2), value: actualInput.isEmpty)

            // Submit button
            Button { showSheet = true } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text("提交并校准 (Submit & Calibrate)").fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "arrow.right.circle.fill").font(.title3)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 18).padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(actualInput.isEmpty
                              ? AnyShapeStyle(Color.white.opacity(0.07))
                              : AnyShapeStyle(LinearGradient(
                                    colors: [.blue, Color(hex: "7B2FBE")],
                                    startPoint: .leading, endPoint: .trailing)))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(actualInput.isEmpty ? .white.opacity(0.06) : .clear, lineWidth: 1)
                )
            }
            .disabled(actualInput.isEmpty)
            .animation(.easeInOut(duration: 0.25), value: actualInput.isEmpty)
        }
        .padding(16)
        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.09), lineWidth: 1))
    }
}

#Preview {
    DashboardView()
        .preferredColorScheme(.dark)
}
