import Foundation

// MARK: - Complete mock dataset for all four persona categories

enum PersonaMockData {

    static func build() -> [PersonaCategory: [PersonaIndividual]] {
        [
            .couples:  couples(),
            .families: families(),
            .seniors:  seniors(),
            .girls:    girls()
        ]
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private static func date(daysAgo: Int, hour: Int = 14) -> Date {
        Calendar.current.date(
            byAdding: .day, value: -daysAgo,
            to: Calendar.current.date(
                bySettingHour: hour, minute: Int.random(in: 0...59), second: 0, of: Date()
            )!
        )!
    }

    private static func today(hour: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date())!
    }

    // ── Couples ──────────────────────────────────────────────────────────────

    private static func couples() -> [PersonaIndividual] {
        [
            PersonaIndividual(
                name: "情侣组 A · 小明 & 小红",
                subtitle: "本地客 · 年度会员",
                category: .couples,
                avatarEmoji: "👫",
                tags: ["高消费", "拍照控", "甜品爱好者"],
                historyRecords: [
                    ConsumptionRecord(location: "梦幻城堡区", locationIcon: "🏰", date: date(daysAgo: 30), items: [
                        PurchaseItem(name: "双人票（含快速通道）", price: 738, quantity: 1, emoji: "🎟"),
                        PurchaseItem(name: "城堡主题周边礼盒",   price: 198, quantity: 2, emoji: "🎁"),
                    ]),
                    ConsumptionRecord(location: "星际探险馆", locationIcon: "🚀", date: date(daysAgo: 15), items: [
                        PurchaseItem(name: "VR 太空体验套餐", price: 260, quantity: 2, emoji: "🥽"),
                        PurchaseItem(name: "宇宙主题拍贴机",  price: 30,  quantity: 4, emoji: "📸"),
                    ]),
                ],
                todayRecords: [
                    ConsumptionRecord(location: "玫瑰花园打卡区", locationIcon: "🌹", date: today(hour: 10), items: [
                        PurchaseItem(name: "限定情侣写真套餐", price: 368, quantity: 1, emoji: "💑"),
                        PurchaseItem(name: "玫瑰冰淇淋",     price: 38,  quantity: 2, emoji: "🍦"),
                    ]),
                    ConsumptionRecord(location: "梦幻餐厅", locationIcon: "🍽", date: today(hour: 12), items: [
                        PurchaseItem(name: "浪漫双人套餐",  price: 398, quantity: 1, emoji: "🥂"),
                    ]),
                ],
                recommendations: [
                    Recommendation(name: "烟花观景台·黄金位预约", type: .photo,       reason: "情侣客群烟花节目复购率 87%，当前余票仅剩 12 席", matchScore: 0.96, emoji: "🎆"),
                    Recommendation(name: "限定版情侣锁挂件",     type: .merchandise, reason: "同类客群本月购买率 73%，强情感纪念价值",         matchScore: 0.91, emoji: "🔒"),
                    Recommendation(name: "夜游极速过山车",       type: .attraction,  reason: "情侣夜场转化率比白天高 40%",                    matchScore: 0.84, emoji: "🎢"),
                    Recommendation(name: "精酿啤酒花园",         type: .dining,      reason: "傍晚时段情侣留园率可提升 25 分钟",              matchScore: 0.78, emoji: "🍺"),
                ]
            ),
            PersonaIndividual(
                name: "情侣组 B · Jack & Lily",
                subtitle: "外地游客 · 首次到访",
                category: .couples,
                avatarEmoji: "💏",
                tags: ["外地客", "打卡新手", "体验驱动"],
                historyRecords: [
                    ConsumptionRecord(location: "欢乐世界（同城竞品）", locationIcon: "🎡", date: date(daysAgo: 90), items: [
                        PurchaseItem(name: "双人普通票",  price: 500, quantity: 1, emoji: "🎟"),
                        PurchaseItem(name: "园区套餐餐饮", price: 160, quantity: 2, emoji: "🍱"),
                    ]),
                ],
                todayRecords: [
                    ConsumptionRecord(location: "入园礼品店", locationIcon: "🛍", date: today(hour: 9), items: [
                        PurchaseItem(name: "园区地图 + 纪念册", price: 58,  quantity: 2, emoji: "📖"),
                        PurchaseItem(name: "快速通道升级",      price: 300, quantity: 2, emoji: "⚡️"),
                    ]),
                ],
                recommendations: [
                    Recommendation(name: "网红漂流 · 双人艇",   type: .attraction,  reason: "首访情侣必玩TOP1，好评率 96%",              matchScore: 0.93, emoji: "🚣"),
                    Recommendation(name: "城堡拍照贴纸机",      type: .photo,       reason: "外地游客纪念属性强，人均消费¥45",             matchScore: 0.88, emoji: "📸"),
                    Recommendation(name: "园区特色甜品礼盒",    type: .merchandise, reason: "首访伴手礼转化率 68%",                       matchScore: 0.82, emoji: "🍰"),
                    Recommendation(name: "日落主题下午茶",      type: .dining,      reason: "景观餐厅体验感强，复购意愿高",               matchScore: 0.76, emoji: "☕️"),
                ]
            ),
            PersonaIndividual(
                name: "情侣组 C · Alex & Emma",
                subtitle: "会员复访 · 五周年纪念游",
                category: .couples,
                avatarEmoji: "🥂",
                tags: ["高频复访", "纪念意义", "高净值"],
                historyRecords: [
                    ConsumptionRecord(location: "巅峰过山车", locationIcon: "🎢", date: date(daysAgo: 365), items: [
                        PurchaseItem(name: "年度会员双人卡", price: 1980, quantity: 1, emoji: "💳"),
                    ]),
                    ConsumptionRecord(location: "星光演艺广场", locationIcon: "🎭", date: date(daysAgo: 60), items: [
                        PurchaseItem(name: "前排VIP观演席", price: 580, quantity: 2, emoji: "🎫"),
                        PurchaseItem(name: "香槟庆典套餐",  price: 288, quantity: 1, emoji: "🍾"),
                    ]),
                ],
                todayRecords: [
                    ConsumptionRecord(location: "贵宾接待室", locationIcon: "👑", date: today(hour: 10), items: [
                        PurchaseItem(name: "五周年定制蛋糕",  price: 588, quantity: 1, emoji: "🎂"),
                        PurchaseItem(name: "专属纪念摄影服务", price: 980, quantity: 1, emoji: "📷"),
                    ]),
                ],
                recommendations: [
                    Recommendation(name: "烟花秀·情侣专属观景包厢", type: .photo,       reason: "五周年纪念用户专属权益，提升留存价值", matchScore: 0.98, emoji: "🎇"),
                    Recommendation(name: "定制刻字纪念品",           type: .merchandise, reason: "高净值情侣对个性化纪念品溢价接受度高", matchScore: 0.94, emoji: "💎"),
                    Recommendation(name: "园区专属管家服务升级",     type: .attraction,  reason: "VIP服务留客时长平均多2.3小时",         matchScore: 0.89, emoji: "🤵"),
                    Recommendation(name: "星光晚宴套餐",             type: .dining,      reason: "五周年纪念日高端餐饮转化率 91%",       matchScore: 0.87, emoji: "🌟"),
                ]
            ),
        ]
    }

    // ── Families ─────────────────────────────────────────────────────────────

    private static func families() -> [PersonaIndividual] {
        [
            PersonaIndividual(
                name: "家庭 1 · 李家（爸妈+双胞胎）",
                subtitle: "亲子家庭 · 周末常客",
                category: .families,
                avatarEmoji: "👨‍👩‍👧‍👦",
                tags: ["亲子", "儿童友好", "周末复访"],
                historyRecords: [
                    ConsumptionRecord(location: "儿童奇幻乐园", locationIcon: "🎠", date: date(daysAgo: 7), items: [
                        PurchaseItem(name: "亲子四人票",         price: 1200, quantity: 1, emoji: "🎟"),
                        PurchaseItem(name: "儿童 IP 玩偶（熊大）", price: 168,  quantity: 2, emoji: "🧸"),
                        PurchaseItem(name: "儿童套餐",           price: 88,   quantity: 2, emoji: "🍔"),
                    ]),
                    ConsumptionRecord(location: "水上乐园", locationIcon: "💦", date: date(daysAgo: 21), items: [
                        PurchaseItem(name: "水上乐园门票",    price: 180, quantity: 4, emoji: "🏊"),
                        PurchaseItem(name: "游泳圈租赁",      price: 30,  quantity: 2, emoji: "🏖"),
                        PurchaseItem(name: "防晒喷雾",        price: 45,  quantity: 1, emoji: "☀️"),
                    ]),
                ],
                todayRecords: [
                    ConsumptionRecord(location: "儿童奇幻乐园", locationIcon: "🎠", date: today(hour: 10), items: [
                        PurchaseItem(name: "旋转木马·亲子票", price: 60, quantity: 2, emoji: "🎠"),
                        PurchaseItem(name: "棉花糖",          price: 15, quantity: 2, emoji: "🍭"),
                    ]),
                    ConsumptionRecord(location: "美食广场", locationIcon: "🍱", date: today(hour: 12), items: [
                        PurchaseItem(name: "家庭超值套餐 4 人份", price: 368, quantity: 1, emoji: "🍱"),
                    ]),
                ],
                recommendations: [
                    Recommendation(name: "儿童互动剧场·下午专场", type: .attraction,  reason: "双胞胎客群对互动剧场停留时长均值 75 分钟", matchScore: 0.95, emoji: "🎭"),
                    Recommendation(name: "DIY 亲子陶艺工坊",      type: .attraction,  reason: "家庭客群亲子手工转化率 81%",               matchScore: 0.90, emoji: "🏺"),
                    Recommendation(name: "儿童限定冰淇淋礼盒",    type: .merchandise, reason: "儿童在场时伴手礼消费决策快",               matchScore: 0.85, emoji: "🍦"),
                    Recommendation(name: "家庭主题摄影套餐",      type: .photo,       reason: "家庭客群回头率与拍照服务强相关",          matchScore: 0.80, emoji: "📸"),
                ]
            ),
            PersonaIndividual(
                name: "家庭 2 · 张家（祖孙三代）",
                subtitle: "三代同游 · 年度大团",
                category: .families,
                avatarEmoji: "👴👵👨👩🧒",
                tags: ["三代同游", "低强度偏好", "高总消费"],
                historyRecords: [
                    ConsumptionRecord(location: "文化体验馆", locationIcon: "🏛", date: date(daysAgo: 180), items: [
                        PurchaseItem(name: "家庭六人联票",    price: 2100, quantity: 1, emoji: "🎟"),
                        PurchaseItem(name: "文化主题纪念册",  price: 128,  quantity: 3, emoji: "📚"),
                    ]),
                ],
                todayRecords: [
                    ConsumptionRecord(location: "老上海风情街", locationIcon: "🏮", date: today(hour: 10), items: [
                        PurchaseItem(name: "怀旧快照服务",   price: 198, quantity: 1, emoji: "📷"),
                        PurchaseItem(name: "传统小吃套装",   price: 128, quantity: 2, emoji: "🥟"),
                    ]),
                ],
                recommendations: [
                    Recommendation(name: "无障碍观光车·全程",     type: .attraction,  reason: "三代同游客群对舒适交通需求高", matchScore: 0.94, emoji: "🚌"),
                    Recommendation(name: "老字号餐厅·家宴套餐",   type: .dining,      reason: "祖孙三代客均消费¥380",         matchScore: 0.91, emoji: "🍜"),
                    Recommendation(name: "国风主题全家福",        type: .photo,       reason: "三代客群全家福转化率 88%",     matchScore: 0.88, emoji: "👨‍👩‍👧‍👦"),
                    Recommendation(name: "传统工艺体验坊",        type: .attraction,  reason: "老年与儿童双端满意度高",       matchScore: 0.82, emoji: "🎋"),
                ]
            ),
        ]
    }

    // ── Seniors ───────────────────────────────────────────────────────────────

    private static func seniors() -> [PersonaIndividual] {
        [
            PersonaIndividual(
                name: "老人组 A · 退休夫妇（王叔叔 & 王阿姨）",
                subtitle: "银发游客 · 休闲养生型",
                category: .seniors,
                avatarEmoji: "👴👵",
                tags: ["低强度", "茶歇偏好", "文化体验"],
                historyRecords: [
                    ConsumptionRecord(location: "汉唐文化区", locationIcon: "⛩", date: date(daysAgo: 45), items: [
                        PurchaseItem(name: "双人悠享通票（含茶歇）", price: 680, quantity: 1, emoji: "🎟"),
                        PurchaseItem(name: "汉服租赁·拍照套餐",      price: 280, quantity: 2, emoji: "👘"),
                    ]),
                ],
                todayRecords: [
                    ConsumptionRecord(location: "园景茶室", locationIcon: "🍵", date: today(hour: 10), items: [
                        PurchaseItem(name: "精品下午茶双人套", price: 168, quantity: 1, emoji: "🫖"),
                        PurchaseItem(name: "太极养生扇（纪念品）", price: 88, quantity: 2, emoji: "🪭"),
                    ]),
                ],
                recommendations: [
                    Recommendation(name: "园景观光电瓶车·全天票",  type: .attraction,  reason: "银发客群步行距离<3km偏好率 92%",          matchScore: 0.96, emoji: "🚃"),
                    Recommendation(name: "传统戏曲演艺专场",        type: .attraction,  reason: "55岁以上客群戏曲观演满意度 97%",          matchScore: 0.93, emoji: "🎎"),
                    Recommendation(name: "养生茶礼·园区限定",       type: .merchandise, reason: "银发购物偏好健康类产品，客单价¥158",       matchScore: 0.88, emoji: "🍃"),
                    Recommendation(name: "无障碍夕阳摄影服务",      type: .photo,       reason: "退休夫妇纪念照需求高，复购意愿强",        matchScore: 0.84, emoji: "🌅"),
                ]
            ),
            PersonaIndividual(
                name: "老人组 B · 老年团（夕阳红旅游团 12 人）",
                subtitle: "团体客 · 旅行社协议价",
                category: .seniors,
                avatarEmoji: "🧓",
                tags: ["团体", "协议折扣", "集中消费"],
                historyRecords: [
                    ConsumptionRecord(location: "民俗风情街", locationIcon: "🏮", date: date(daysAgo: 120), items: [
                        PurchaseItem(name: "团体票（12 人）",  price: 4200, quantity: 1, emoji: "🎟"),
                        PurchaseItem(name: "团体午餐套餐",    price: 128,  quantity: 12, emoji: "🍽"),
                    ]),
                ],
                todayRecords: [
                    ConsumptionRecord(location: "民俗表演广场", locationIcon: "🎪", date: today(hour: 10), items: [
                        PurchaseItem(name: "民俗表演观看票", price: 60,  quantity: 12, emoji: "🎭"),
                        PurchaseItem(name: "伴手礼套装",     price: 98,  quantity: 8,  emoji: "🎁"),
                    ]),
                ],
                recommendations: [
                    Recommendation(name: "团体专属导游服务",     type: .attraction,  reason: "12人团标配服务，提升满意度评分",         matchScore: 0.95, emoji: "🗺"),
                    Recommendation(name: "园区团体餐·中式宴席", type: .dining,      reason: "团体客午餐转化率 100%，推荐升级套餐",   matchScore: 0.93, emoji: "🥘"),
                    Recommendation(name: "批量纪念品折扣套装",  type: .merchandise, reason: "团体采购意愿强，8件以上享8折",           matchScore: 0.87, emoji: "🛒"),
                    Recommendation(name: "团体合影服务",        type: .photo,       reason: "老年团合影需求高，摄影师到场服务率100%", matchScore: 0.83, emoji: "📸"),
                ]
            ),
        ]
    }

    // ── Girls ─────────────────────────────────────────────────────────────────

    private static func girls() -> [PersonaIndividual] {
        [
            PersonaIndividual(
                name: "闺蜜团 A · 小雨、小云、小雪",
                subtitle: "90后 · 打卡型高消费",
                category: .girls,
                avatarEmoji: "👯‍♀️",
                tags: ["打卡控", "高颜值偏好", "种草达人"],
                historyRecords: [
                    ConsumptionRecord(location: "魔法泡泡王国", locationIcon: "🫧", date: date(daysAgo: 14), items: [
                        PurchaseItem(name: "网红泡泡机拍照道具租赁", price: 88,  quantity: 3, emoji: "🫧"),
                        PurchaseItem(name: "限定版公主礼服租赁",     price: 268, quantity: 3, emoji: "👗"),
                        PurchaseItem(name: "闺蜜特调饮品套装",       price: 138, quantity: 1, emoji: "🥤"),
                    ]),
                    ConsumptionRecord(location: "网红甜品一条街", locationIcon: "🍰", date: date(daysAgo: 30), items: [
                        PurchaseItem(name: "草莓芭菲",   price: 68, quantity: 3, emoji: "🍓"),
                        PurchaseItem(name: "云朵棉花糖", price: 35, quantity: 3, emoji: "☁️"),
                    ]),
                ],
                todayRecords: [
                    ConsumptionRecord(location: "梦幻镜屋", locationIcon: "🪞", date: today(hour: 10), items: [
                        PurchaseItem(name: "镜屋主题打卡票",   price: 58,  quantity: 3, emoji: "🪞"),
                        PurchaseItem(name: "限定唇彩（联名款）", price: 128, quantity: 3, emoji: "💄"),
                    ]),
                    ConsumptionRecord(location: "网红咖啡角", locationIcon: "☕️", date: today(hour: 11), items: [
                        PurchaseItem(name: "园区限定拿铁",   price: 48, quantity: 3, emoji: "☕️"),
                        PurchaseItem(name: "限定杯套（可外带）", price: 25, quantity: 3, emoji: "🛍"),
                    ]),
                ],
                recommendations: [
                    Recommendation(name: "「梦境花海」限时沉浸展",  type: .photo,       reason: "小红书打卡热度TOP1，带动客流 +35%",      matchScore: 0.97, emoji: "🌸"),
                    Recommendation(name: "园区联名美妆限定礼盒",    type: .merchandise, reason: "女性客群美妆联名转化率 79%，客单价¥259",  matchScore: 0.93, emoji: "💅"),
                    Recommendation(name: "闺蜜专属下午茶·4人套",   type: .dining,      reason: "3人以上闺蜜团套餐升级率 83%",            matchScore: 0.89, emoji: "🫖"),
                    Recommendation(name: "旋转木马 · 网红摄影位",  type: .attraction,  reason: "拍照打卡位每日流量最高的游乐设施",        matchScore: 0.86, emoji: "🎠"),
                ]
            ),
            PersonaIndividual(
                name: "独行侠 · 小艾（solo旅行者）",
                subtitle: "Z世代 · 深度体验型",
                category: .girls,
                avatarEmoji: "🚶‍♀️",
                tags: ["独行", "深度体验", "文青"],
                historyRecords: [
                    ConsumptionRecord(location: "文创艺术街区", locationIcon: "🎨", date: date(daysAgo: 60), items: [
                        PurchaseItem(name: "艺术家联名明信片套装", price: 88,  quantity: 1, emoji: "🖼"),
                        PurchaseItem(name: "手工蜡烛 DIY 体验",   price: 168, quantity: 1, emoji: "🕯"),
                    ]),
                ],
                todayRecords: [
                    ConsumptionRecord(location: "书香小馆", locationIcon: "📚", date: today(hour: 10), items: [
                        PurchaseItem(name: "手冲咖啡 + 园区主题笔记本", price: 128, quantity: 1, emoji: "☕️"),
                    ]),
                ],
                recommendations: [
                    Recommendation(name: "「昨日重现」复古主题展",    type: .photo,       reason: "文青独行客群深度体验偏好，停留时长+45min", matchScore: 0.94, emoji: "🎞"),
                    Recommendation(name: "手工皮具刻字工坊",          type: .attraction,  reason: "独行女性手工体验转化率 77%",               matchScore: 0.90, emoji: "👜"),
                    Recommendation(name: "园区联名艺术家明信片礼盒",  type: .merchandise, reason: "文创类客单价¥158，复购率 68%",             matchScore: 0.87, emoji: "✉️"),
                    Recommendation(name: "轻食花园·单人桌",           type: .dining,      reason: "独行女性对私密单人座位满意度 94%",         matchScore: 0.82, emoji: "🥗"),
                ]
            ),
        ]
    }
}
