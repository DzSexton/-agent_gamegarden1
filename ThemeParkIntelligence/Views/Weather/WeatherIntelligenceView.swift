import SwiftUI
import Charts

struct WeatherIntelligenceView: View {
    @State private var vm = WeatherViewModel()

    private var bg: Color { Color(red: 0.031, green: 0.047, blue: 0.094) }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                bg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        heroCard
                        timelineSection
                        if let sel = vm.selectedHour { expandedDetail(sel) }
                        historicalSection
                        Spacer().frame(height: 80) // room for bottom button
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }

                analyzeButton
                    .padding(.horizontal, 16).padding(.bottom, 8)
            }
            .navigationTitle("天气智能")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(bg, for: .navigationBar)
        }
        .sheet(isPresented: $vm.showInsightSheet) {
            WeatherInsightSheet(viewModel: vm)
        }
    }

    // MARK: - Hero Card

    private var heroCard: some View {
        let now = vm.hourlyWeather.first(where: { $0.hour == vm.currentHour }) ?? vm.hourlyWeather[6]
        return HStack(spacing: 16) {
            // Big weather icon
            ZStack {
                Circle().fill(now.type.color.opacity(0.15)).frame(width: 72, height: 72)
                Image(systemName: now.type.icon).font(.system(size: 34)).foregroundStyle(now.type.color)
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(now.type.displayName).font(.title2.bold()).foregroundStyle(.white)
                    Text(vm.todaySummaryLabel)
                        .font(.caption.weight(.semibold)).foregroundStyle(now.type.color)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(now.type.color.opacity(0.15), in: Capsule())
                }
                Text("\(now.temperature)°C · 湿度 \(now.humidity)%")
                    .font(.subheadline).foregroundStyle(.secondary)
                Text(vm.overallPriceAdvice)
                    .font(.caption).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true).lineLimit(2)
            }

            Spacer()
        }
        .padding(16)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(now.type.color.opacity(0.25), lineWidth: 1))
    }

    // MARK: - Timeline Section

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("今日天气时间轴").font(.headline).foregroundStyle(.white)
                Spacer()
                Text("点击卡片查看 AI 策略").font(.caption2).foregroundStyle(.tertiary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(vm.hourlyWeather) { hour in
                        TimelineCard(
                            hour: hour,
                            isSelected: vm.selectedHour?.id == hour.id,
                            isCurrent: hour.hour == vm.currentHour
                        )
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
                                vm.selectedHour = vm.selectedHour?.id == hour.id ? nil : hour
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding(16)
        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.08), lineWidth: 1))
    }

    // MARK: - Expanded Strategy Detail

    private func expandedDetail(_ hour: WeatherHour) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: hour.type.icon).font(.title3).foregroundStyle(hour.type.color)
                Text("\(hour.hour):00 · \(hour.type.displayName) · \(hour.temperature)°C")
                    .font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                Spacer()
                Text(hour.priceLabel)
                    .font(.callout.bold()).foregroundStyle(hour.priceColor)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(hour.priceColor.opacity(0.12), in: Capsule())
            }

            Divider().overlay(.white.opacity(0.08))

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "brain.head.profile").font(.body).foregroundStyle(.purple).frame(width: 20)
                Text(hour.strategy)
                    .font(.subheadline).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 6) {
                Text(hour.riskTag)
                    .font(.caption2.bold()).foregroundStyle(hour.riskColor)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(hour.riskColor.opacity(0.12), in: Capsule())
                Text("湿度 \(hour.humidity)%")
                    .font(.caption2).foregroundStyle(.tertiary)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(.white.opacity(0.05), in: Capsule())
            }
        }
        .padding(16)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(hour.type.color.opacity(0.3), lineWidth: 1))
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    // MARK: - Historical Match Section

    private var historicalSection: some View {
        let h = vm.historicalMatch
        return VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Label("历史对标", systemImage: "calendar.badge.clock").font(.headline).foregroundStyle(.white)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill").font(.caption).foregroundStyle(.green)
                    Text("相似度 \(Int(h.similarity * 100))%")
                        .font(.caption.bold()).foregroundStyle(.green)
                }
            }

            // Match label
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").font(.caption).foregroundStyle(.secondary)
                Text("匹配到历史相似日：").font(.caption).foregroundStyle(.secondary)
                Text(h.dateLabel).font(.caption.bold()).foregroundStyle(.white)
                Text("·").foregroundStyle(.tertiary)
                Text(h.weatherSummary).font(.caption2).foregroundStyle(.secondary)
            }

            // Historical weather timeline (mirrors today's timeline style)
            VStack(alignment: .leading, spacing: 8) {
                Text("该日天气时间轴").font(.subheadline.weight(.semibold)).foregroundStyle(.white.opacity(0.85))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(h.hourlyPoints) { pt in
                            HistoricalTimelineCard(point: pt)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            // Mini visitor chart
            Text("该日客流曲线").font(.subheadline.weight(.semibold)).foregroundStyle(.white.opacity(0.85))
            Chart {
                ForEach(h.hourlyPoints) { pt in
                    AreaMark(
                        x: .value("H", pt.hour),
                        yStart: .value("V", 0),
                        yEnd: .value("V", pt.visitors / 1000)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: pt.isRainPeriod
                                ? [Color(red: 0.3, green: 0.5, blue: 1.0).opacity(0.55), .clear]
                                : [Color.green.opacity(0.45), .clear],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("H", pt.hour),
                        y: .value("V", pt.visitors / 1000)
                    )
                    .foregroundStyle(pt.isRainPeriod ? Color(red: 0.3, green: 0.5, blue: 1.0) : Color.green)
                    .lineStyle(.init(lineWidth: 2))
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartXAxis {
                AxisMarks(values: [8, 12, 16, 20]) { v in
                    AxisValueLabel {
                        Text("\(v.as(Int.self) ?? 0)h").font(.system(size: 9)).foregroundStyle(.white.opacity(0.35))
                    }
                    AxisGridLine(stroke: .init(lineWidth: 0.4))
                }
            }
            .chartYAxis {
                AxisMarks(values: [0, 15, 30]) { v in
                    AxisValueLabel {
                        Text("\(v.as(Int.self) ?? 0)k").font(.system(size: 9)).foregroundStyle(.white.opacity(0.35))
                    }
                }
            }
            .chartYScale(domain: 0...35)
            .frame(height: 90)

            // Legend
            HStack(spacing: 14) {
                legendDot(Color(red: 0.3, green: 0.5, blue: 1.0), "雨期")
                legendDot(.green, "晴期")
                Spacer()
                Text("历史峰值 \(h.peakVisitors / 1000)k 人").font(.caption2).foregroundStyle(.secondary)
            }

            Divider().overlay(.white.opacity(0.08))

            // Stats grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                statCell("¥\(String(format: "%.1f", h.totalRevenue))万", label: "历史当日营收",   color: .green)
                statCell("\(h.raingearSales) 件",                         label: "雨具销量",       color: .cyan)
                statCell("+\(String(format: "%.1f", h.fnbBoostPct))%",   label: "餐饮超额增长",   color: .orange)
                statCell("+\(String(format: "%.1f", h.indoorBoostPct))%", label: "室内设施超额", color: .purple)
            }
        }
        .padding(16)
        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.08), lineWidth: 1))
    }

    private func legendDot(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
    }

    private func statCell(_ value: String, label: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value).font(.title3.bold().monospacedDigit()).foregroundStyle(color)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .padding(12).frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.15), lineWidth: 1))
    }

    // MARK: - Analyze Button

    private var analyzeButton: some View {
        Button { vm.showInsightSheet = true } label: {
            HStack(spacing: 10) {
                Image(systemName: "wand.and.stars")
                Text("分析今日策略 (Analyze Today's Strategy)").fontWeight(.semibold)
                Spacer()
                Image(systemName: "arrow.right.circle.fill").font(.title3)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20).padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.15, green: 0.35, blue: 0.90), Color(red: 0.50, green: 0.20, blue: 0.85)],
                    startPoint: .leading, endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .shadow(color: Color(red: 0.15, green: 0.35, blue: 0.90).opacity(0.4), radius: 12, y: 4)
        }
    }
}

// MARK: - Historical Timeline Card (mirrors TimelineCard style)

private struct HistoricalTimelineCard: View {
    let point: HistoricalPoint

    var body: some View {
        VStack(spacing: 5) {
            Text("\(point.hour)h")
                .font(.system(size: 9, weight: .regular))
                .foregroundStyle(.secondary)

            Image(systemName: point.weatherType.icon)
                .font(.system(size: 22))
                .foregroundStyle(point.weatherType.color)

            Text("\(point.temperature)°")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)

            Text(point.isRainPeriod ? "降雨" : "晴好")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(point.isRainPeriod ? Color(red: 0.3, green: 0.5, blue: 1.0) : .green)
                .lineLimit(1)
        }
        .padding(.vertical, 10).padding(.horizontal, 6)
        .frame(width: 68)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(LinearGradient(
                    colors: [point.weatherType.color.opacity(point.isRainPeriod ? 0.15 : 0.06), .clear],
                    startPoint: .top, endPoint: .bottom))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(point.isRainPeriod
                        ? Color(red: 0.3, green: 0.5, blue: 1.0).opacity(0.35)
                        : point.weatherType.color.opacity(0.2),
                        lineWidth: 1)
        )
    }
}

// MARK: - Timeline Card (private helper)

private struct TimelineCard: View {
    let hour: WeatherHour
    let isSelected: Bool
    let isCurrent: Bool

    var body: some View {
        VStack(spacing: 5) {
            Text(isCurrent ? "NOW" : "\(hour.hour)h")
                .font(.system(size: 9, weight: isCurrent ? .bold : .regular))
                .foregroundStyle(isCurrent ? .white : .secondary)

            Image(systemName: hour.type.icon)
                .font(.system(size: 22))
                .foregroundStyle(hour.type.color)

            Text("\(hour.temperature)°")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)

            Text(hour.priceLabel)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(hour.priceColor)
                .lineLimit(1)
        }
        .padding(.vertical, 10).padding(.horizontal, 6)
        .frame(width: 68)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isSelected
                      ? LinearGradient(colors: [hour.type.color.opacity(0.25), hour.type.color.opacity(0.08)],
                                       startPoint: .top, endPoint: .bottom)
                      : LinearGradient(colors: [Color.white.opacity(isCurrent ? 0.09 : 0.04), Color.clear],
                                       startPoint: .top, endPoint: .bottom))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isSelected ? hour.type.color.opacity(0.6) : (isCurrent ? .white.opacity(0.3) : .white.opacity(0.07)),
                    lineWidth: isSelected ? 1.5 : 1
                )
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
    }
}

#Preview {
    WeatherIntelligenceView()
        .preferredColorScheme(.dark)
}
