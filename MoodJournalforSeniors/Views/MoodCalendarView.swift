import SwiftUI

// MARK: - 心情日历视图
struct MoodCalendarView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var currentDate = Date()
    @State private var selectedEntry: MoodEntry?
    @State private var showingDetail = false
    @State private var animatingMonth = false
    
    // 日历相关计算属性
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = dateFormatter
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }
    
    private var monthRange: Range<Date> {
        let startOfMonth = calendar.dateInterval(of: .month, for: currentDate)!.start
        let endOfMonth = calendar.dateInterval(of: .month, for: currentDate)!.end
        return startOfMonth..<endOfMonth
    }
    
    private var daysInMonth: [Date] {
        let startOfMonth = calendar.dateInterval(of: .month, for: currentDate)!.start
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        
        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    private var firstWeekday: Int {
        let startOfMonth = calendar.dateInterval(of: .month, for: currentDate)!.start
        return calendar.component(.weekday, from: startOfMonth)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 渐变背景
                LinearGradient(
                    gradient: Gradient(colors: [
                        AppTheme.Colors.primary.opacity(0.1),
                        AppTheme.Colors.background,
                        AppTheme.Colors.primaryLight.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: AppTheme.Spacing.lg) {
                    // 月份导航栏
                    monthNavigationCard
                    
                    // 日历主体卡片
                    calendarMainCard
                    
                    Spacer()
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.top, AppTheme.Spacing.sm)
            }
        }
        .onAppear {
            print("📅 日历视图加载完成 - 简化表情版本")
            let currentMonth = monthYearFormatter.string(from: currentDate)
            print("   - 当前显示月份: \(currentMonth)")
            let entriesCount = dataManager.moodEntries.filter { entry in
                calendar.isDate(entry.date, equalTo: currentDate, toGranularity: .month)
            }.count
            print("   - 本月心情记录数: \(entriesCount)")
            print("   - 界面样式: 简化版，只显示日期和表情符号")
            print("   - 导航样式: 英文月份显示，纯箭头按钮")
        }
        .sheet(isPresented: $showingDetail, onDismiss: {
            selectedEntry = nil
        }) {
            if let entry = selectedEntry {
                MoodEntryDetailView(entry: entry)
                    .environmentObject(dataManager)
            }
        }
    }
    
    // 月份导航卡片
    private var monthNavigationCard: some View {
        HStack {
            // 上一月按钮
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                AppTheme.Colors.primary,
                                AppTheme.Colors.primary.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(22)
                    .shadow(color: AppTheme.Colors.primary.opacity(0.3), radius: 5, x: 0, y: 3)
            }
            .disabled(animatingMonth)
            .scaleEffect(animatingMonth ? 0.95 : 1.0)
            
            Spacer()
            
            // 当前月份年份
            VStack(spacing: 4) {
                Text(monthYearFormatter.string(from: currentDate))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                // 装饰线
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                AppTheme.Colors.primary.opacity(0.3),
                                AppTheme.Colors.primary,
                                AppTheme.Colors.primary.opacity(0.3)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 80, height: 2)
                    .cornerRadius(1)
            }
            .scaleEffect(animatingMonth ? 1.1 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: animatingMonth)
            
            Spacer()
            
            // 下一月按钮
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                AppTheme.Colors.primary,
                                AppTheme.Colors.primary.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(22)
                    .shadow(color: AppTheme.Colors.primary.opacity(0.3), radius: 5, x: 0, y: 3)
            }
            .disabled(animatingMonth)
            .scaleEffect(animatingMonth ? 0.95 : 1.0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: AppTheme.Shadow.light, radius: 10, x: 0, y: 5)
        )
    }
    
    // 日历主体卡片
    private var calendarMainCard: some View {
        VStack(spacing: 0) {
            // 星期标题
            enhancedWeekdayHeaders
            
            // 日历网格
            enhancedCalendarGrid
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: AppTheme.Shadow.light, radius: 12, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            AppTheme.Colors.primary.opacity(0.2),
                            AppTheme.Colors.primary.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
    
    // 增强的星期标题
    private var enhancedWeekdayHeaders: some View {
        HStack(spacing: 0) {
            ForEach(weekdayData, id: \.index) { item in
                weekdayHeaderItem(weekday: item.weekday, index: item.index)
            }
        }
        .background(
            Rectangle()
                .fill(AppTheme.Colors.surface.opacity(0.5))
        )
        .overlay(
            Rectangle()
                .fill(AppTheme.Colors.separator.opacity(0.3))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    // 星期数据
    private var weekdayData: [(weekday: String, index: Int)] {
        let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
        return weekdays.enumerated().map { (index, weekday) in
            (weekday: weekday, index: index)
        }
    }
    
    // 星期标题项
    private func weekdayHeaderItem(weekday: String, index: Int) -> some View {
        let textColor = (index == 0 || index == 6) ? 
            AppTheme.Colors.error.opacity(0.8) : 
            AppTheme.Colors.textSecondary
            
        let backgroundGradient = LinearGradient(
            gradient: Gradient(colors: [
                AppTheme.Colors.primaryLight.opacity(0.1),
                AppTheme.Colors.primaryLight.opacity(0.05)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        return Text(weekday)
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Rectangle()
                    .fill(backgroundGradient)
            )
    }
    
    // 增强的日历网格
    private var enhancedCalendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 2) {
            // 月份开始前的空白天数
            ForEach(0..<(firstWeekday - 1), id: \.self) { _ in
                Color.clear
                    .frame(height: 70)
            }
            
            // 月份中的每一天
            ForEach(daysInMonth, id: \.self) { date in
                enhancedDayCell(for: date)
            }
        }
        .padding(.all, 8)
    }
    
    // 增强的单日单元格
    private func enhancedDayCell(for date: Date) -> some View {
        let dayNumber = calendar.component(.day, from: date)
        let entriesForDay = getEntriesForDay(date)
        let isToday = calendar.isDate(date, inSameDayAs: Date())
        let hasEntry = !entriesForDay.isEmpty
        let isWeekend = isWeekendDate(date)
        
        return Button(action: {
            handleDayTap(dayNumber: dayNumber, hasEntry: hasEntry, entriesForDay: entriesForDay)
        }) {
            ZStack {
                // 背景层
                backgroundView(hasEntry: hasEntry)
                
                // 今日高亮环
                if isToday {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppTheme.Colors.primary,
                                    AppTheme.Colors.primary.opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppTheme.Colors.primary.opacity(0.1))
                        )
                }
                
                VStack(spacing: 4) {
                    // 日期数字
                    Text("\(dayNumber)")
                        .font(.system(size: 18, weight: isToday ? .bold : .semibold, design: .rounded))
                        .foregroundColor(
                            isToday ? AppTheme.Colors.primary :
                            isWeekend ? AppTheme.Colors.error.opacity(0.8) :
                            hasEntry ? AppTheme.Colors.textPrimary : 
                            AppTheme.Colors.textSecondary
                        )
                    
                    // 心情表情图标
                    if hasEntry {
                        let mood = entriesForDay.first!.moodLevel
                        Text(moodEmoji(for: mood))
                            .font(.system(size: 24))
                            .scaleEffect(1.0)
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                    } else {
                        // 占位空间
                        Text("")
                            .font(.system(size: 24))
                            .frame(height: 24)
                    }
                }
            }
            .frame(height: 70)
            .scaleEffect(hasEntry ? 1.0 : 0.95)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: hasEntry)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // 获取指定日期的心情记录
    private func getEntriesForDay(_ date: Date) -> [MoodEntry] {
        return dataManager.moodEntries.filter { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }.sorted { $0.date > $1.date } // 最新的在前
    }
    
    // 判断是否为周末
    private func isWeekendDate(_ date: Date) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 || weekday == 7 // 周日=1, 周六=7
    }
    
    // 处理日期点击事件
    private func handleDayTap(dayNumber: Int, hasEntry: Bool, entriesForDay: [MoodEntry]) {
        if hasEntry {
            selectedEntry = entriesForDay.first
            showingDetail = true
            let entry = entriesForDay.first!
            print("📅 查看日期 \(dayNumber) 的心情记录")
            print("   - 心情等级: \(entry.moodLevel) (\(entry.moodDescription))")
            if entry.hasMedia {
                var mediaTypes: [String] = []
                if entry.audioURL != nil { mediaTypes.append("语音") }
                if entry.imageURL != nil { mediaTypes.append("图片") }
                print("   - 包含媒体: \(mediaTypes.joined(separator: "、"))")
            }
            if !entry.activities.isEmpty {
                print("   - 活动数量: \(entry.activities.count)")
            }
        } else {
            print("📅 点击日期 \(dayNumber)，无心情记录")
        }
    }
    
    // 创建背景视图
    private func backgroundView(hasEntry: Bool) -> some View {
        let entryGradient = LinearGradient(
            gradient: Gradient(colors: [
                Color.white,
                AppTheme.Colors.primaryLight.opacity(0.1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        let emptyGradient = LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.8),
                Color.white.opacity(0.4)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        return RoundedRectangle(cornerRadius: 12)
            .fill(hasEntry ? entryGradient : emptyGradient)
            .shadow(
                color: hasEntry ? AppTheme.Shadow.medium : AppTheme.Shadow.light,
                radius: hasEntry ? 4 : 2,
                x: 0,
                y: hasEntry ? 2 : 1
            )
    }
    
    // 心情表情符号
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
    
    // 上一月
    private func previousMonth() {
        print("📅 开始切换到上一月...")
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            animatingMonth = true
            currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                animatingMonth = false
            }
        }
        
        print("📅 切换到上一月: \(monthYearFormatter.string(from: currentDate))")
        
        // 统计新月份的记录数量
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            let entriesCount = self.dataManager.moodEntries.filter { entry in
                self.calendar.isDate(entry.date, equalTo: self.currentDate, toGranularity: .month)
            }.count
            print("   - \(self.monthYearFormatter.string(from: self.currentDate)) 有 \(entriesCount) 条心情记录")
        }
    }
    
    // 下一月
    private func nextMonth() {
        print("📅 开始切换到下一月...")
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            animatingMonth = true
            currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                animatingMonth = false
            }
        }
        
        print("📅 切换到下一月: \(monthYearFormatter.string(from: currentDate))")
        
        // 统计新月份的记录数量
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            let entriesCount = self.dataManager.moodEntries.filter { entry in
                self.calendar.isDate(entry.date, equalTo: self.currentDate, toGranularity: .month)
            }.count
            print("   - \(self.monthYearFormatter.string(from: self.currentDate)) 有 \(entriesCount) 条心情记录")
        }
    }
}

#Preview {
    MoodCalendarView()
        .environmentObject(DataManager.shared)
} 