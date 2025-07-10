import SwiftUI

// MARK: - 统计页面视图
struct StatisticsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedPeriod: StatisticsPeriod = .week
    @State private var statistics: MoodStatistics?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // 时间段选择器
                    periodSelector
                    
                    if let stats = statistics {
                        // 统计概览卡片
                        statisticsOverviewSection(stats)
                        
                        // 心情趋势图
                        moodTrendChart(stats)
                        
                        // 心情分布图
                        moodDistributionSection(stats)
                        
                        // 活动分析
                        activityAnalysisSection(stats)
                        
                        // 详细数据
                        detailDataSection(stats)
                    } else {
                        emptyStateView
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("数据统计")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                updateStatistics()
                print("📊 加载统计页面")
            }
            .onChange(of: selectedPeriod) { _ in
                updateStatistics()
            }
        }
    }
    
    // 时间段选择器
    private var periodSelector: some View {
        Picker("统计周期", selection: $selectedPeriod) {
            ForEach(StatisticsPeriod.allCases, id: \.self) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.md)
    }
    
    // 统计概览区域
    private func statisticsOverviewSection(_ stats: MoodStatistics) -> some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Text("概览数据")
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: AppTheme.Spacing.md) {
                // 平均心情
                StatisticCard(
                    title: "平均心情",
                    value: String(format: "%.1f", stats.averageMood),
                    subtitle: moodDescription(for: Int(stats.averageMood.rounded())),
                    color: AppTheme.Colors.moodColor(for: Int(stats.averageMood.rounded())),
                    icon: "heart.fill"
                )
                
                // 记录总数
                StatisticCard(
                    title: "记录总数",
                    value: "\(stats.totalEntries)",
                    subtitle: "条记录",
                    color: AppTheme.Colors.primary,
                    icon: "doc.text"
                )
                
                // 心情稳定性
                StatisticCard(
                    title: "情绪稳定",
                    value: String(format: "%.0f%%", stats.moodStability * 100),
                    subtitle: stabilityDescription(stats.moodStability),
                    color: AppTheme.Colors.info,
                    icon: "waveform.path.ecg"
                )
                
                // 最好心情
                StatisticCard(
                    title: "最好状态",
                    value: "\(stats.entries.map { $0.moodLevel }.max() ?? 0)",
                    subtitle: moodDescription(for: stats.entries.map { $0.moodLevel }.max() ?? 0),
                    color: AppTheme.Colors.success,
                    icon: "star.fill"
                )
            }
        }
        .padding(AppTheme.Spacing.cardPadding)
        .cardStyle()
    }
    
    // 心情趋势图
    private func moodTrendChart(_ stats: MoodStatistics) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("心情趋势")
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            if stats.entries.count >= 2 {
                SimpleTrendChart(entries: stats.entries, period: selectedPeriod)
                    .frame(height: 200)
            } else {
                VStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.Colors.textTertiary)
                    
                    Text("需要更多数据")
                        .font(AppTheme.Fonts.body)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    Text("至少需要2条记录才能显示趋势")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(AppTheme.Spacing.cardPadding)
        .cardStyle()
    }
    
    // 心情分布区域
    private func moodDistributionSection(_ stats: MoodStatistics) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("心情分布")
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            VStack(spacing: AppTheme.Spacing.sm) {
                ForEach(1...5, id: \.self) { level in
                    let count = stats.moodCounts[level] ?? 0
                    let percentage = stats.totalEntries > 0 ? Double(count) / Double(stats.totalEntries) : 0.0
                    
                    MoodDistributionBar(
                        level: level,
                        count: count,
                        percentage: percentage
                    )
                }
            }
        }
        .padding(AppTheme.Spacing.cardPadding)
        .cardStyle()
    }
    
    // 活动分析区域
    private func activityAnalysisSection(_ stats: MoodStatistics) -> some View {
        let activityStats = calculateActivityStats(stats.entries)
        
        return VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("活动分析")
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            activityContentView(activityStats: activityStats)
        }
        .padding(AppTheme.Spacing.cardPadding)
        .cardStyle()
    }
    
    // 活动内容视图
    @ViewBuilder
    private func activityContentView(activityStats: [ActivityStat]) -> some View {
            if activityStats.isEmpty {
            activityEmptyStateView
        } else {
            activityListView(activityStats: activityStats)
        }
    }
    
    // 活动空状态视图
    private var activityEmptyStateView: some View {
                VStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 30))
                        .foregroundColor(AppTheme.Colors.textTertiary)
                    
                    Text("暂无活动数据")
                        .font(AppTheme.Fonts.body)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(AppTheme.Spacing.lg)
    }
    
    // 活动列表视图
    private func activityListView(activityStats: [ActivityStat]) -> some View {
                VStack(spacing: AppTheme.Spacing.sm) {
            ForEach(Array(activityStats.prefix(5)), id: \.activity.id) { stat in
                ActivityStatRow(stat: stat)
                            }
                        }
    }
    
    // 详细数据区域
    private func detailDataSection(_ stats: MoodStatistics) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("详细数据")
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            VStack(spacing: AppTheme.Spacing.sm) {
                DetailDataRow(label: "统计周期", value: selectedPeriod.rawValue)
                DetailDataRow(label: "记录天数", value: "\(calculateActiveDays(stats.entries))天")
                DetailDataRow(label: "最高心情", value: "\(stats.entries.map { $0.moodLevel }.max() ?? 0)")
                DetailDataRow(label: "最低心情", value: "\(stats.entries.map { $0.moodLevel }.min() ?? 0)")
                DetailDataRow(label: "心情范围", value: "\(calculateMoodRange(stats.entries))")
                
                if let firstEntry = stats.entries.last, let lastEntry = stats.entries.first {
                    let trend = lastEntry.moodLevel - firstEntry.moodLevel
                    let trendText = trend > 0 ? "上升 ↗️" : trend < 0 ? "下降 ↘️" : "平稳 ➡️"
                    DetailDataRow(label: "整体趋势", value: trendText)
                }
            }
        }
        .padding(AppTheme.Spacing.cardPadding)
        .cardStyle()
    }
    
    // 空状态视图
    private var emptyStateView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()
            
            Image(systemName: "chart.bar")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.textTertiary)
            
            VStack(spacing: AppTheme.Spacing.sm) {
                Text("暂无统计数据")
                    .titleStyle()
                
                Text("开始记录心情后就能看到统计分析了")
                    .subtitleStyle()
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.lg)
    }
    
    // 辅助方法
    private func updateStatistics() {
        statistics = dataManager.getMoodStatistics(for: selectedPeriod)
        print("📊 更新统计数据: \(selectedPeriod.rawValue)")
    }
    
    private func moodDescription(for level: Int) -> String {
        switch level {
        case 1: return "很差"
        case 2: return "不好"
        case 3: return "一般"
        case 4: return "不错"
        case 5: return "很好"
        default: return "未知"
        }
    }
    
    private func stabilityDescription(_ stability: Double) -> String {
        switch stability {
        case 0.8...1.0: return "非常稳定"
        case 0.6..<0.8: return "比较稳定"
        case 0.4..<0.6: return "一般"
        case 0.2..<0.4: return "波动较大"
        default: return "波动很大"
        }
    }
    
    private func calculateActivityStats(_ entries: [MoodEntry]) -> [ActivityStat] {
        var activityCounts: [UUID: (activity: Activity, moods: [Int])] = [:]
        
        for entry in entries {
            for activity in entry.activities {
                if activityCounts[activity.id] != nil {
                    activityCounts[activity.id]?.moods.append(entry.moodLevel)
                } else {
                    activityCounts[activity.id] = (activity, [entry.moodLevel])
                }
            }
        }
        
        return activityCounts.map { (_, data) in
            let averageMood = Double(data.moods.reduce(0, +)) / Double(data.moods.count)
            return ActivityStat(
                activity: data.activity,
                count: data.moods.count,
                averageMood: averageMood
            )
        }.sorted { $0.count > $1.count }
    }
    
    private func calculateActiveDays(_ entries: [MoodEntry]) -> Int {
        let dates = Set(entries.map { Calendar.current.startOfDay(for: $0.date) })
        return dates.count
    }
    
    private func calculateMoodRange(_ entries: [MoodEntry]) -> String {
        guard !entries.isEmpty else { return "0" }
        let moods = entries.map { $0.moodLevel }
        let range = (moods.max() ?? 0) - (moods.min() ?? 0)
        return "\(range)"
    }
}

// MARK: - 统计卡片组件
struct StatisticCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(value)
                    .font(AppTheme.Fonts.title1)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(title)
                    .font(AppTheme.Fonts.callout)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text(subtitle)
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - 心情分布条组件
struct MoodDistributionBar: View {
    let level: Int
    let count: Int
    let percentage: Double
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            // 心情标签
            HStack(spacing: AppTheme.Spacing.xs) {
                Text(dataManager.getMoodDisplay(for: level))
                    .font(.title3)
                
                Text(moodDescription(for: level))
                    .font(AppTheme.Fonts.callout)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .frame(width: 40, alignment: .leading)
            }
            .frame(width: 80, alignment: .leading)
            
            // 进度条
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(AppTheme.Colors.moodColor(for: level))
                        .frame(width: geometry.size.width * percentage)
                        .cornerRadius(AppTheme.CornerRadius.sm)
                    
                    Spacer()
                }
            }
            .frame(height: 8)
            .background(AppTheme.Colors.separator.opacity(0.3))
            .cornerRadius(AppTheme.CornerRadius.sm)
            
            // 数据标签
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(count)")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text("\(Int(percentage * 100))%")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .frame(width: 40, alignment: .trailing)
        }
    }
    
    private func moodEmoji(for level: Int) -> String {
        switch level {
        case 1: return "😢"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "😊"
        case 5: return "😄"
        default: return "😐"
        }
    }
    
    private func moodDescription(for level: Int) -> String {
        switch level {
        case 1: return "很差"
        case 2: return "不好"
        case 3: return "一般"
        case 4: return "不错"
        case 5: return "很好"
        default: return "未知"
        }
    }
}

// MARK: - 详细数据行组件
struct DetailDataRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppTheme.Fonts.callout)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(AppTheme.Fonts.callout)
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - 活动统计行组件
struct ActivityStatRow: View {
    let stat: ActivityStat
    
    var body: some View {
        HStack {
            // 活动图标
            Image(systemName: stat.activity.icon)
                .foregroundColor(iconColor)
                .frame(width: 20)
            
            // 活动名称和自定义标识
            activityNameView
            
            Spacer()
            
            // 统计数据
            statisticsView
        }
        .padding(.vertical, AppTheme.Spacing.xs)
    }
    
    private var iconColor: Color {
        stat.activity.isCustom ? AppTheme.Colors.warning : AppTheme.Colors.primary
    }
    
    private var activityNameView: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            Text(stat.activity.name)
                .font(AppTheme.Fonts.callout)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            if stat.activity.isCustom {
                customBadge
            }
        }
    }
    
    private var customBadge: some View {
        Text("自定义")
            .font(AppTheme.Fonts.caption)
            .foregroundColor(.white)
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .background(AppTheme.Colors.warning)
            .cornerRadius(4)
    }
    
    private var statisticsView: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text("\(stat.count)次")
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Text("平均\(String(format: "%.1f", stat.averageMood))")
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.moodColor(for: Int(stat.averageMood.rounded())))
        }
    }
}

// MARK: - 支持数据结构
struct ActivityStat {
    let activity: Activity
    let count: Int
    let averageMood: Double
}

#Preview {
    StatisticsView()
        .environmentObject(DataManager.shared)
} 