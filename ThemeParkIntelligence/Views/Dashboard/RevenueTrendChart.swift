import SwiftUI
import Charts

struct RevenueTrendChart: View {
    let dataPoints: [RevenueDataPoint]

    // 单位：万元
    private func inWan(_ value: Double) -> Double { value / 10_000 }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("今日营收趋势")
                    .font(.headline)
                Spacer()
                legendItem(color: .blue,   label: "实际")
                legendItem(color: .orange.opacity(0.7), label: "预测", dashed: true)
            }

            Chart {
                // 实际营收面积图
                ForEach(dataPoints.filter { $0.actual != nil }) { point in
                    AreaMark(
                        x: .value("小时", point.hour),
                        y: .value("营收(万)", inWan(point.actual!))
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue.opacity(0.4), .blue.opacity(0.05)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )

                    LineMark(
                        x: .value("小时", point.hour),
                        y: .value("营收(万)", inWan(point.actual!))
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .symbol(Circle().strokeBorder(lineWidth: 1.5))
                    .symbolSize(30)
                }

                // 预测曲线（虚线）
                ForEach(dataPoints) { point in
                    LineMark(
                        x: .value("小时", point.hour),
                        y: .value("预测(万)", inWan(point.predicted))
                    )
                    .foregroundStyle(.orange.opacity(0.8))
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 3]))
                    .interpolationMethod(.catmullRom)
                }

                // 当前时刻标记线
                if let currentHour = dataPoints.last(where: { $0.actual != nil })?.hour {
                    RuleMark(x: .value("现在", currentHour))
                        .foregroundStyle(.secondary.opacity(0.4))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 3]))
                        .annotation(position: .top) {
                            Text("NOW")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.secondary)
                        }
                }
            }
            .chartXAxis {
                AxisMarks(values: stride(from: 0, through: 23, by: 3).map { $0 }) { value in
                    AxisValueLabel { Text("\(value.as(Int.self) ?? 0)时") .font(.caption2) }
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3))
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel { Text("¥\(value.as(Double.self).map { Int($0) } ?? 0)万").font(.caption2) }
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3))
                }
            }
            .frame(height: 180)
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func legendItem(color: Color, label: String, dashed: Bool = false) -> some View {
        HStack(spacing: 4) {
            if dashed {
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { _ in
                        Rectangle().fill(color).frame(width: 4, height: 2)
                    }
                }
            } else {
                Rectangle().fill(color).frame(width: 12, height: 2)
            }
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
    }
}
