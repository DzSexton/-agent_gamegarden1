import SwiftUI
import Charts

struct PricingConsoleView: View {
    @State private var viewModel = PricingViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    simulationControlPanel
                    if let result = viewModel.simulationResult {
                        resultSummaryCard(result: result)
                        comparisonChart(curve: result.comparisonCurve)
                    }
                }
                .padding()
            }
            .navigationTitle("定价模拟器")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("运行模拟") { viewModel.runSimulation() }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.isSimulating)
                }
            }
        }
        .task { viewModel.runSimulation() }
    }

    // MARK: - Control Panel

    private var simulationControlPanel: some View {
        VStack(spacing: 0) {
            // 票价滑块
            sliderRow(
                title: "模拟票价",
                value: $viewModel.basePrice,
                range: 199...599,
                step: 10,
                format: "¥%.0f",
                color: .blue
            )

            Divider().padding(.horizontal)

            // 需求系数滑块
            sliderRow(
                title: "需求系数",
                value: $viewModel.demandMultiplier,
                range: 0.5...2.0,
                step: 0.1,
                format: "%.1fx",
                color: .green
            )

            Divider().padding(.horizontal)

            // 天气影响系数
            sliderRow(
                title: "天气系数",
                value: $viewModel.weatherFactor,
                range: 0.6...1.2,
                step: 0.05,
                format: "%.2fx",
                color: .orange
            )

            Divider().padding(.horizontal)

            // 时段选择
            VStack(alignment: .leading, spacing: 8) {
                Text("运营时段")
                    .font(.subheadline.weight(.medium))
                Picker("时段", selection: $viewModel.selectedTimeSlot) {
                    ForEach(PricingSimulationRequest.TimeSlot.allCases, id: \.self) { slot in
                        Text(slot.displayName).tag(slot)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(16)
        }
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.quaternary, lineWidth: 1))
    }

    @ViewBuilder
    private func sliderRow(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double,
        format: String,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text(String(format: format, value.wrappedValue))
                    .font(.subheadline.bold())
                    .foregroundStyle(color)
                    .monospacedDigit()
                    .frame(minWidth: 60, alignment: .trailing)
            }
            Slider(value: value, in: range, step: step)
                .tint(color)
                .onChange(of: value.wrappedValue) { _, _ in
                    // 实时触发模拟（防抖逻辑在 ViewModel 中通过 task cancel 实现）
                    viewModel.runSimulation()
                }
        }
        .padding(16)
    }

    // MARK: - Result Summary

    @ViewBuilder
    private func resultSummaryCard(result: PricingSimulationResult) -> some View {
        HStack(spacing: 0) {
            resultMetric(
                title: "预计营收",
                value: viewModel.formattedProjectedRevenue,
                change: viewModel.revenueChangeText,
                isPositive: viewModel.revenueChangeIsPositive,
                color: .blue
            )
            Divider()
            resultMetric(
                title: "预计入园",
                value: "\(result.projectedVisitors.formatted())人",
                change: nil,
                isPositive: true,
                color: .green
            )
            Divider()
            resultMetric(
                title: "价格弹性",
                value: String(format: "%.2f", result.priceElasticity),
                change: nil,
                isPositive: result.priceElasticity > -1.5,
                color: .orange
            )
        }
        .frame(height: 90)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(viewModel.revenueChangeIsPositive ? .green.opacity(0.3) : .red.opacity(0.3), lineWidth: 1)
        )
        .overlay {
            if viewModel.isSimulating {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.black.opacity(0.08))
                ProgressView("计算中…")
                    .font(.caption)
            }
        }
    }

    private func resultMetric(
        title: String,
        value: String,
        change: String?,
        isPositive: Bool,
        color: Color
    ) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            if let change {
                Text(change)
                    .font(.caption.bold())
                    .foregroundStyle(isPositive ? .green : .red)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Dual Curve Chart (价格 vs 营收 / 人数)

    @ViewBuilder
    private func comparisonChart(curve: [PriceCurvePoint]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("价格-收益双曲线")
                .font(.headline)

            Chart(curve) { point in
                LineMark(
                    x: .value("票价", point.price),
                    y: .value("营收(万)", point.projectedRevenue / 10_000)
                )
                .foregroundStyle(.blue)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom)

                // 当前模拟值标注
                if abs(point.price - viewModel.basePrice) < 15 {
                    PointMark(
                        x: .value("票价", point.price),
                        y: .value("营收(万)", point.projectedRevenue / 10_000)
                    )
                    .foregroundStyle(.blue)
                    .symbolSize(80)
                    .annotation(position: .top) {
                        Text("¥\(Int(point.price))")
                            .font(.caption2.bold())
                            .foregroundStyle(.blue)
                    }
                }
            }
            .chartXAxis {
                AxisMarks(preset: .automatic) { value in
                    AxisValueLabel {
                        Text("¥\(value.as(Double.self).map { Int($0) } ?? 0)")
                            .font(.caption2)
                    }
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3))
                }
            }
            .chartYAxisLabel("预计营收（万元）", position: .leading)
            .frame(height: 200)
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    PricingConsoleView()
}
