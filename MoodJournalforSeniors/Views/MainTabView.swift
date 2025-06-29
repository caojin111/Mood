import SwiftUI

// MARK: - 主导航标签页
struct MainTabView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 首页 - 心情日记
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("首页")
                }
                .tag(0)
            
            // 统计页面  
            StatisticsView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "chart.bar.fill" : "chart.bar")
                    Text("统计")
                }
                .tag(1)
            
            // 皮肤商店
            StoreView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "paintbrush.fill" : "paintbrush")
                    Text("皮肤")
                }
                .tag(2)
            
            // 更多设置
            SettingsView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "ellipsis.circle.fill" : "ellipsis.circle")
                    Text("更多")
                }
                .tag(3)
        }
        .accentColor(AppTheme.Colors.primary)
        .environmentObject(dataManager)
        .onAppear {
            setupTabBarAppearance()
            print("🏠 主页面加载完成")
        }
    }
    
    private func setupTabBarAppearance() {
        // 设置标签栏样式
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        
        // 设置标签栏字体大小（适老化）
        let normalFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        let selectedFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .font: normalFont,
            .foregroundColor: UIColor.secondaryLabel
        ]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .font: selectedFont,
            .foregroundColor: UIColor(AppTheme.Colors.primary)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - 首页视图
struct HomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddEntry = false
    @State private var viewMode: ViewMode = .list
    
    enum ViewMode: String, CaseIterable {
        case list = "列表"
        case calendar = "日历"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 顶部模式切换
                viewModeSelector
                
                // 内容区域
                if viewMode == .list {
                    moodListView
                } else {
                    calendarView
                }
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("心情日记")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddEntry = true
                        print("➕ 点击添加心情日记按钮")
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddEntry) {
            AddMoodEntryView()
                .environmentObject(dataManager)
        }
    }
    
    // 视图模式选择器
    private var viewModeSelector: some View {
        Picker("视图模式", selection: $viewMode) {
            ForEach(ViewMode.allCases, id: \.self) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.surface)
    }
    
    // 列表视图
    private var moodListView: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Spacing.md) {
                if dataManager.moodEntries.isEmpty {
                    emptyStateView
                } else {
                    ForEach(dataManager.moodEntries) { entry in
                        MoodEntryRowView(entry: entry)
                            .environmentObject(dataManager)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
        }
    }
    
    // 日历视图
    private var calendarView: some View {
        MoodCalendarView()
            .environmentObject(dataManager)
    }
    
    // 空状态视图
    private var emptyStateView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()
            
            Image(systemName: "face.smiling")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.Colors.primary)
            
            VStack(spacing: AppTheme.Spacing.sm) {
                Text("还没有心情记录")
                    .titleStyle()
                
                Text("点击右上角的 + 号开始记录您的心情")
                    .subtitleStyle()
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                showingAddEntry = true
            }) {
                Text("记录心情")
                    .frame(maxWidth: .infinity)
                    .primaryButtonStyle()
            }
            .padding(.horizontal, AppTheme.Spacing.xl)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.lg)
    }
}

// MARK: - 心情日记行视图
struct MoodEntryRowView: View {
    let entry: MoodEntry
    @EnvironmentObject var dataManager: DataManager
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: {
            showingDetail = true
            print("📖 查看心情日记详情: \(entry.moodDescription)")
        }) {
            HStack(spacing: AppTheme.Spacing.md) {
                // 心情指示器
                Circle()
                    .fill(AppTheme.Colors.moodColor(for: entry.moodLevel))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(dataManager.getMoodDisplay(for: entry.moodLevel))
                            .font(.title2)
                    )
                
                // 内容区域
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    HStack {
                        Text(entry.moodDescription)
                            .font(AppTheme.Fonts.headline)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        
                        Spacer()
                        
                        Text(formatDate(entry.date))
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    
                    if !entry.activities.isEmpty {
                        HStack {
                            ForEach(entry.activities.prefix(3), id: \.id) { activity in
                                Text(activity.name)
                                    .font(AppTheme.Fonts.caption)
                                    .padding(.horizontal, AppTheme.Spacing.xs)
                                    .padding(.vertical, 2)
                                    .background(AppTheme.Colors.primaryLight)
                                    .foregroundColor(AppTheme.Colors.primary)
                                    .cornerRadius(AppTheme.CornerRadius.sm)
                            }
                            
                            if entry.activities.count > 3 {
                                Text("+\(entry.activities.count - 3)")
                                    .font(AppTheme.Fonts.caption)
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                            }
                        }
                    }
                    
                    if let note = entry.note, !note.isEmpty {
                        Text(note)
                            .font(AppTheme.Fonts.callout)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                // 右侧指示器
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.textTertiary)
            }
            .padding(AppTheme.Spacing.cardPadding)
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            MoodEntryDetailView(entry: entry)
                .environmentObject(dataManager)
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        let calendar = Calendar.current
        
        // 手动判断是否为今天
        if calendar.isDate(date, inSameDayAs: Date()) {
            formatter.dateFormat = "今天 HH:mm"
        } 
        // 手动判断是否为昨天
        else if let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()),
                calendar.isDate(date, inSameDayAs: yesterday) {
            formatter.dateFormat = "昨天 HH:mm"
        } 
        else {
            formatter.dateFormat = "MM月dd日 HH:mm"
        }
        
        return formatter.string(from: date)
    }
}

#Preview {
    MainTabView()
} 