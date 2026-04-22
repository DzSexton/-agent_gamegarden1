import Foundation

enum WeatherMockData {

    // MARK: - 今日天气序列 (晴→阴→雨→晴)

    static func buildHourlyData() -> [WeatherHour] {
        let raw: [(Int, WeatherType, Int, Int, Double, String)] = [
            (8,  .sunny,        26, 45, +0.08, "晴好天气，游客出行意愿高，建议小幅上调早间入园价"),
            (9,  .sunny,        27, 43, +0.08, "持续晴天，上午时段需求旺盛，维持溢价策略"),
            (10, .partlyCloudy, 28, 50, +0.05, "天气舒适，游客体感良好，维持轻度上调"),
            (11, .partlyCloudy, 28, 55, +0.05, "多云遮阳反而利于户外活动，维持策略"),
            (12, .cloudy,       27, 62, +0.00, "转阴，户外项目体验稍降，建议维持定价观望"),
            (13, .lightRain,    26, 72, -0.10, "小雨预警，建议下调票价 10% 以维持入园率，同步推室内项目"),
            (14, .heavyRain,    24, 85, -0.20, "大雨，户外设施陆续暂停，强烈建议下调并推雨天联动套餐"),
            (15, .thunderstorm, 23, 90, -0.25, "雷阵雨，所有室外设施临时关闭，补偿性大幅下调维系口碑"),
            (16, .heavyRain,    23, 88, -0.20, "强降雨持续，推送室内超值套餐是关键营收保障"),
            (17, .lightRain,    24, 78, -0.10, "雨势减弱，逐步恢复户外，可提前预告傍晚天气回暖"),
            (18, .partlyCloudy, 25, 65, +0.00, "雨停转多云，游客情绪回升，维持现价观察流量"),
            (19, .partlyCloudy, 25, 60, +0.05, "傍晚出行高峰，天气回好，推送夜游套餐触达率高"),
            (20, .sunny,        24, 55, +0.05, "夜晚晴好，烟花秀节点，建议上调夜场溢价"),
            (21, .sunny,        23, 52, +0.03, "烟花秀高峰，游客滞留意愿强，维持夜场溢价"),
            (22, .sunny,        22, 50, +0.00, "收园时段，维持正常定价，重点推送次日复访优惠"),
        ]
        // RL 即时奖励：+捕获溢价, -天气惩罚/策略失误 (-1.0…+1.0)
        let rewards: [Double] = [
             0.68,  // 8h  晴天溢价执行良好
             0.72,  // 9h  持续优质策略
             0.55,  // 10h 适度上调匹配天气
             0.52,  // 11h 维持策略稳定
             0.10,  // 12h 转阴未调价，轻微遗漏机会
             0.38,  // 13h 提前 1h 识别降雨信号并下调 ✓
            -0.15,  // 14h 大雨营收承压，策略正确但不可抗力
            -0.42,  // 15h 雷阵雨强制关闭，强惩罚 (天气因子)
            -0.28,  // 16h 持续降雨损失，室内套餐部分对冲
             0.22,  // 17h 雨势减弱，恢复信号捕捉及时
             0.35,  // 18h 雨停流量回升，观望策略合理
             0.58,  // 19h 傍晚溢价恢复，Q值回升
             0.65,  // 20h 烟花秀溢价策略命中
             0.60,  // 21h 高峰维持，策略稳定
             0.20,  // 22h 收园自然衰减
        ]
        return raw.enumerated().map { i, r in
            WeatherHour(hour: r.0, type: r.1, temperature: r.2, humidity: r.3,
                        priceDelta: r.4, strategy: r.5, rewardScore: rewards[i])
        }
    }

    // MARK: - 历史对标日数据

    static func buildHistoricalMatch() -> HistoricalMatch {
        // (hour, visitors, isRainPeriod, weatherType, temperature)
        let points: [(Int, Int, Bool, WeatherType, Int)] = [
            (8,  12000, false, .sunny,        24),
            (9,  15000, false, .sunny,        25),
            (10, 22000, false, .partlyCloudy, 27),
            (11, 28000, false, .partlyCloudy, 28),
            (12, 26000, false, .cloudy,       27),
            (13, 18000, true,  .lightRain,    25),
            (14, 10000, true,  .heavyRain,    23),
            (15,  8000, true,  .thunderstorm, 22),
            (16,  9000, true,  .heavyRain,    22),
            (17, 13000, true,  .lightRain,    23),
            (18, 20000, false, .partlyCloudy, 24),
            (19, 25000, false, .partlyCloudy, 24),
            (20, 28000, false, .sunny,        23),
            (21, 24000, false, .sunny,        22),
            (22, 18000, false, .sunny,        21),
        ]
        return HistoricalMatch(
            dateLabel: "2023年6月15日",
            similarity: 0.91,
            weatherSummary: "晴转大雨，14:00-17:00 持续降水",
            peakVisitors: 28_000,
            totalRevenue: 168.5,
            raingearSales: 1_248,
            fnbBoostPct: 28.3,
            indoorBoostPct: 52.0,
            hourlyPoints: points.map {
                HistoricalPoint(hour: $0.0, visitors: $0.1, isRainPeriod: $0.2,
                                weatherType: $0.3, temperature: $0.4)
            }
        )
    }

    // MARK: - Recommendation Engine

    static func recommendations(for type: WeatherType) -> [WeatherRecommendation] {
        switch type {
        case .lightRain, .heavyRain, .thunderstorm:
            return [
                WeatherRecommendation(category: "套餐推荐",  title: "🌧 雨天室内联动套餐",
                    detail: "电影票 + 爆米花 + 热饮三件套，定价 ¥98，在园推送转化率高",
                    icon: "ticket.fill",          uplift: "二销预计 +32%",   accentColor: .blue),
                WeatherRecommendation(category: "周边销售",  title: "☂️ 雨具闪购",
                    detail: "雨伞 + 雨衣套装 ¥35，APP 内购送至区域服务点，减少游客中途离园",
                    icon: "bag.fill",             uplift: "销量预计 800+ 件", accentColor: .cyan),
                WeatherRecommendation(category: "设施优化",  title: "🎭 室内设施优先通道",
                    detail: "推送室内游乐专属快速通道券，降低户外空置率，提升室内坪效",
                    icon: "star.circle.fill",     uplift: "室内入场 +55%",   accentColor: .purple),
                WeatherRecommendation(category: "餐饮推荐",  title: "🍜 暖心热食套餐",
                    detail: "热汤 + 主食套餐 ¥68，App 首页首屏曝光，雨天餐饮需求弹性高",
                    icon: "fork.knife.circle.fill", uplift: "餐饮营收 +28%", accentColor: .orange),
            ]
        case .hot:
            return [
                WeatherRecommendation(category: "快速通道",  title: "💦 水上乐园清凉特权",
                    detail: "水上乐园快速通道 ¥49，限时 2 小时，高温触达转化率极高",
                    icon: "figure.pool.swim",     uplift: "水区入场 +68%",   accentColor: .cyan),
                WeatherRecommendation(category: "餐饮推荐",  title: "🧋 清凉特饮联名套餐",
                    detail: "网红冰淇淋 + 特调果茶 + 冰沙三选二，定价 ¥55",
                    icon: "cup.and.saucer.fill",  uplift: "饮品销量 +120%",  accentColor: .blue),
                WeatherRecommendation(category: "设施运营",  title: "⛱ 遮阳休息区开放",
                    detail: "VIP 遮阳区向普通游客开放，延长停留时长可触发二次消费",
                    icon: "umbrella.fill",        uplift: "停留时长 +25min", accentColor: .yellow),
            ]
        default:
            return [
                WeatherRecommendation(category: "票价策略",  title: "☀️ 晴天溢价推荐",
                    detail: "天气指数良好，上午时段建议上调 8%，维持入园动力同时提升坪效",
                    icon: "chart.line.uptrend.xyaxis", uplift: "营收预计 +8.5%", accentColor: .yellow),
                WeatherRecommendation(category: "打卡活动",  title: "📸 限时打卡挑战赛",
                    detail: "晴天光线最佳，发起 UGC 拍照挑战，刺激社媒传播与二次到访",
                    icon: "camera.fill",          uplift: "社媒曝光 +3.2x",  accentColor: .pink),
                WeatherRecommendation(category: "演艺联动",  title: "🎪 户外演艺周边联动",
                    detail: "晴天户外演艺上座率高，联动周边摊位销售纪念品提升连带消费",
                    icon: "music.note.house.fill", uplift: "演艺周边 +45%",  accentColor: .green),
            ]
        }
    }
}
