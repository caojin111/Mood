import SwiftUI

// MARK: - 简单趋势图组件
struct SimpleTrendChart: View {
    let entries: [MoodEntry]
    let period: StatisticsPeriod
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            // 图表区域
            GeometryReader { geometry in
                ZStack {
                    // 背景网格
                    backgroundGrid(in: geometry.size)
                    
                    // 趋势线
                    trendLine(in: geometry.size)
                    
                    // 数据点
                    dataPoints(in: geometry.size)
                }
            }
            
            // 底部日期轴
            dateAxis
        }
    }
    
    // 背景网格
    private func backgroundGrid(in size: CGSize) -> some View {
        ZStack {
            // 水平网格线 (心情等级)
            ForEach(1...5, id: \.self) { level in
                let y = size.height - (CGFloat(level - 1) / 4.0 * size.height)
                
                Path { path in
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }
                .stroke(AppTheme.Colors.separator.opacity(0.3), lineWidth: 1)
            }
            
            // 垂直网格线 (时间)
            let timePoints = getTimePoints()
            ForEach(0..<timePoints.count, id: \.self) { index in
                let x = CGFloat(index) / CGFloat(max(timePoints.count - 1, 1)) * size.width
                
                Path { path in
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                }
                .stroke(AppTheme.Colors.separator.opacity(0.2), lineWidth: 1)
            }
        }
    }
    
    // 趋势线
    private func trendLine(in size: CGSize) -> some View {
        let points = calculateDataPoints(size: size)
        
        return Path { path in
            guard points.count > 1 else { return }
            
            path.move(to: points[0])
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
        }
        .stroke(
            LinearGradient(
                colors: [AppTheme.Colors.primary, AppTheme.Colors.primaryDark],
                startPoint: .leading,
                endPoint: .trailing
            ),
            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
        )
    }
    
    // 数据点
    private func dataPoints(in size: CGSize) -> some View {
        let points = calculateDataPoints(size: size)
        
        return ForEach(0..<points.count, id: \.self) { index in
            let point = points[index]
            let entry = sortedEntries[index]
            
            Circle()
                .fill(AppTheme.Colors.moodColor(for: entry.moodLevel))
                .frame(width: 8, height: 8)
                .position(point)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 8, height: 8)
                        .position(point)
                )
        }
    }
    
    // 底部日期轴
    private var dateAxis: some View {
        HStack {
            let timePoints = getTimePoints()
            ForEach(0..<min(timePoints.count, 5), id: \.self) { index in
                if index == 0 {
                    Text(formatAxisDate(timePoints[index]))
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    Spacer()
                } else if index == timePoints.count - 1 {
                    Text(formatAxisDate(timePoints[index]))
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                } else if index == timePoints.count / 2 {
                    Text(formatAxisDate(timePoints[index]))
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    Spacer()
                }
            }
        }
    }
    
    // 计算数据点位置
    private func calculateDataPoints(size: CGSize) -> [CGPoint] {
        let timePoints = getTimePoints()
        guard timePoints.count > 1 else { return [] }
        
        return sortedEntries.enumerated().map { index, entry in
            let x = CGFloat(index) / CGFloat(max(timePoints.count - 1, 1)) * size.width
            let y = size.height - (CGFloat(entry.moodLevel - 1) / 4.0 * size.height)
            return CGPoint(x: x, y: y)
        }
    }
    
    // 获取排序后的数据
    private var sortedEntries: [MoodEntry] {
        return entries.sorted { $0.date < $1.date }
    }
    
    // 获取时间点
    private func getTimePoints() -> [Date] {
        let calendar = Calendar.current
        let now = Date()
        var points: [Date] = []
        
        switch period {
        case .week:
            for i in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: -6 + i, to: now) {
                    points.append(calendar.startOfDay(for: date))
                }
            }
        case .month:
            for i in 0..<30 {
                if let date = calendar.date(byAdding: .day, value: -29 + i, to: now) {
                    points.append(calendar.startOfDay(for: date))
                }
            }
        case .year:
            for i in 0..<12 {
                if let date = calendar.date(byAdding: .month, value: -11 + i, to: now) {
                    points.append(calendar.startOfDay(for: date))
                }
            }
        }
        
        return points
    }
    
    // 格式化轴标签日期
    private func formatAxisDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        
        switch period {
        case .week:
            formatter.dateFormat = "MM/dd"
        case .month:
            formatter.dateFormat = "MM/dd"
        case .year:
            formatter.dateFormat = "MM月"
        }
        
        return formatter.string(from: date)
    }
}

#Preview {
    let sampleEntries = [
        MoodEntry(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, moodLevel: 3),
        MoodEntry(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, moodLevel: 4),
        MoodEntry(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, moodLevel: 2),
        MoodEntry(date: Date(), moodLevel: 5)
    ]
    
    return SimpleTrendChart(entries: sampleEntries, period: .week)
        .frame(height: 200)
        .padding()
} 