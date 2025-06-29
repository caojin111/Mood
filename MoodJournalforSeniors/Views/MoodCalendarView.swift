import SwiftUI

// MARK: - 心情日历视图
struct MoodCalendarView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var currentDate = Date()
    @State private var selectedEntry: MoodEntry?
    @State private var showingDetail = false
    
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
        formatter.dateFormat = "yyyy年MM月"
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
        VStack(spacing: 0) {
            // 月份导航栏
            monthNavigationBar
            
            // 星期标题
            weekdayHeaders
            
            // 日历网格
            calendarGrid
            
            Spacer()
        }
        .background(AppTheme.Colors.background)
        .onAppear {
            print("📅 日历视图加载完成")
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
    
    // 月份导航栏
    private var monthNavigationBar: some View {
        HStack {
            // 上一月按钮
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(AppTheme.Colors.primary)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.Colors.surface)
                    .cornerRadius(AppTheme.CornerRadius.md)
            }
            
            Spacer()
            
            // 当前月份年份
            Text(monthYearFormatter.string(from: currentDate))
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .fontWeight(.semibold)
            
            Spacer()
            
            // 下一月按钮
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(AppTheme.Colors.primary)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.Colors.surface)
                    .cornerRadius(AppTheme.CornerRadius.md)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.surface)
    }
    
    // 星期标题
    private var weekdayHeaders: some View {
        HStack(spacing: 0) {
            ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { weekday in
                Text(weekday)
                    .font(AppTheme.Fonts.callout)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.sm)
            }
        }
        .background(AppTheme.Colors.surface)
    }
    
    // 日历网格
    private var calendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 1) {
            // 月份开始前的空白天数
            ForEach(0..<(firstWeekday - 1), id: \.self) { _ in
                Color.clear
                    .frame(height: 60)
            }
            
            // 月份中的每一天
            ForEach(daysInMonth, id: \.self) { date in
                dayCell(for: date)
            }
        }
        .background(AppTheme.Colors.separator)
        .padding(.horizontal, 1)
    }
    
    // 单日单元格
    private func dayCell(for date: Date) -> some View {
        let dayNumber = calendar.component(.day, from: date)
        let entriesForDay = getEntriesForDay(date)
        let isToday = calendar.isDate(date, inSameDayAs: Date())
        let hasEntry = !entriesForDay.isEmpty
        
        return Button(action: {
            if hasEntry {
                selectedEntry = entriesForDay.first
                showingDetail = true
                print("📅 查看日期 \(dayNumber) 的心情记录")
            }
        }) {
            VStack(spacing: 4) {
                // 日期数字
                Text("\(dayNumber)")
                    .font(AppTheme.Fonts.body)
                    .fontWeight(isToday ? .bold : .medium)
                    .foregroundColor(
                        isToday ? AppTheme.Colors.primary :
                        hasEntry ? AppTheme.Colors.textPrimary : AppTheme.Colors.textSecondary
                    )
                
                // 心情指示器
                if hasEntry {
                    let mood = entriesForDay.first!.moodLevel
                    Circle()
                        .fill(AppTheme.Colors.moodColor(for: mood))
                        .frame(width: 20, height: 20)
                        .overlay(
                            Text(dataManager.getMoodDisplay(for: mood))
                                .font(.system(size: 10))
                        )
                } else {
                    // 占位空间
                    Color.clear
                        .frame(width: 20, height: 20)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                    .fill(
                        isToday ? AppTheme.Colors.primaryLight.opacity(0.3) :
                        hasEntry ? AppTheme.Colors.surface : Color.clear
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                    .stroke(
                        isToday ? AppTheme.Colors.primary : Color.clear,
                        lineWidth: isToday ? 2 : 0
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .background(AppTheme.Colors.background)
    }
    
    // 获取指定日期的心情记录
    private func getEntriesForDay(_ date: Date) -> [MoodEntry] {
        return dataManager.moodEntries.filter { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }.sorted { $0.date > $1.date } // 最新的在前
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
        withAnimation(.easeInOut(duration: 0.3)) {
            currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        }
        print("📅 切换到上一月: \(monthYearFormatter.string(from: currentDate))")
    }
    
    // 下一月
    private func nextMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        }
        print("📅 切换到下一月: \(monthYearFormatter.string(from: currentDate))")
    }
}

#Preview {
    MoodCalendarView()
        .environmentObject(DataManager.shared)
} 