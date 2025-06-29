import SwiftUI

// MARK: - 设置页面视图
struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingUserProfile = false
    @State private var showingNotificationSettings = false
    @State private var showingDataExport = false
    @State private var showingAbout = false
    @State private var showingPrivacySettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // 用户信息卡片
                    userProfileSection
                    
                    // 应用设置
                    appSettingsSection
                    
                    // 数据管理
                    dataManagementSection
                    
                    // 支持与反馈
                    supportSection
                    
                    // 关于应用
                    aboutSection
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("更多")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingUserProfile) {
            UserProfileView()
                .environmentObject(dataManager)
        }
        .sheet(isPresented: $showingNotificationSettings) {
            NotificationSettingsView()
                .environmentObject(dataManager)
        }
        .sheet(isPresented: $showingDataExport) {
            DataExportView()
                .environmentObject(dataManager)
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingPrivacySettings) {
            PrivacySettingsView()
        }
        .onAppear {
            print("⚙️ 设置页面加载完成")
        }
    }
    
    // 用户信息区域
    private var userProfileSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                Text("个人信息")
                    .font(AppTheme.Fonts.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
            }
            
            UserProfileCard(profile: dataManager.userProfile) {
                showingUserProfile = true
            }
        }
    }
    
    // 应用设置区域
    private var appSettingsSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                Text("应用设置")
                    .font(AppTheme.Fonts.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "bell.fill",
                    title: "通知提醒",
                    subtitle: "设置心情记录提醒",
                    action: {
                        showingNotificationSettings = true
                        print("🔔 打开通知设置")
                    }
                )
                
                Divider()
                    .padding(.leading, 60)
                
                SettingsRow(
                    icon: "paintbrush.fill",
                    title: "心情皮肤",
                    subtitle: "当前：\(dataManager.currentMoodSkinPack.name)",
                    action: {
                        print("🎨 跳转到皮肤商店")
                        // 注意：这里可以通过NotificationCenter或其他方式通知MainTabView切换标签
                        NotificationCenter.default.post(name: NSNotification.Name("SwitchToStoreTab"), object: nil)
                    }
                )
                
                Divider()
                    .padding(.leading, 60)
                
                SettingsRow(
                    icon: "app.badge.fill",
                    title: "应用图标",
                    subtitle: "更换应用图标样式",
                    action: {
                        print("📱 更换应用图标")
                    }
                )
            }
            .background(AppTheme.Colors.surface)
            .cornerRadius(AppTheme.CornerRadius.lg)
        }
    }
    
    // 数据管理区域
    private var dataManagementSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                Text("数据管理")
                    .font(AppTheme.Fonts.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "square.and.arrow.up.fill",
                    title: "导出数据",
                    subtitle: "备份心情日记数据",
                    action: {
                        showingDataExport = true
                        print("📤 数据导出")
                    }
                )
                
                Divider()
                    .padding(.leading, 60)
                
                SettingsRow(
                    icon: "person.2.fill",
                    title: "家庭共享",
                    subtitle: "与家人分享心情状态",
                    action: {
                        print("👨‍👩‍👧‍👦 家庭共享")
                    }
                )
                
                Divider()
                    .padding(.leading, 60)
                
                SettingsRow(
                    icon: "hand.raised.fill",
                    title: "隐私设置",
                    subtitle: "管理数据隐私权限",
                    action: {
                        showingPrivacySettings = true
                        print("🔒 隐私设置")
                    }
                )
            }
            .background(AppTheme.Colors.surface)
            .cornerRadius(AppTheme.CornerRadius.lg)
        }
    }
    
    // 支持与反馈区域
    private var supportSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                Text("支持与反馈")
                    .font(AppTheme.Fonts.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "heart.fill",
                    title: "支持我们",
                    subtitle: "给应用评分或分享",
                    action: {
                        print("❤️ 支持我们")
                    }
                )
                
                Divider()
                    .padding(.leading, 60)
                
                SettingsRow(
                    icon: "envelope.fill",
                    title: "意见反馈",
                    subtitle: "联系开发者反馈问题",
                    action: {
                        print("✉️ 意见反馈")
                    }
                )
            }
            .background(AppTheme.Colors.surface)
            .cornerRadius(AppTheme.CornerRadius.lg)
        }
    }
    
    // 关于应用区域
    private var aboutSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                Text("关于应用")
                    .font(AppTheme.Fonts.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "info.circle.fill",
                    title: "关于我们",
                    subtitle: "版本信息和开发团队",
                    action: {
                        showingAbout = true
                        print("ℹ️ 关于我们")
                    }
                )
                
                Divider()
                    .padding(.leading, 60)
                
                SettingsRow(
                    icon: "doc.text.fill",
                    title: "隐私政策",
                    subtitle: "了解我们的隐私保护",
                    action: {
                        print("📄 隐私政策")
                    }
                )
                
                Divider()
                    .padding(.leading, 60)
                
                SettingsRow(
                    icon: "doc.plaintext.fill",
                    title: "用户协议",
                    subtitle: "查看使用条款",
                    action: {
                        print("📋 用户协议")
                    }
                )
            }
            .background(AppTheme.Colors.surface)
            .cornerRadius(AppTheme.CornerRadius.lg)
        }
    }
}

// MARK: - 用户配置卡片
struct UserProfileCard: View {
    let profile: UserProfile
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.md) {
                // 头像区域
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.Colors.primary,
                                AppTheme.Colors.primaryLight
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    )
                
                // 用户信息
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text("用户档案")
                        .font(AppTheme.Fonts.headline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    HStack {
                        Text("性别: \(profile.gender?.rawValue ?? "未设置")")
                            .font(AppTheme.Fonts.callout)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        
                        Spacer()
                    }
                    
                    Text("点击编辑个人信息")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.primary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.textTertiary)
            }
            .padding(AppTheme.Spacing.cardPadding)
            .background(AppTheme.Colors.surface)
            .cornerRadius(AppTheme.CornerRadius.lg)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 设置行组件
struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.md) {
                // 图标
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(AppTheme.Colors.primary)
                    .frame(width: 28, height: 28)
                
                // 文字内容
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(title)
                        .font(AppTheme.Fonts.callout)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text(subtitle)
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                // 右箭头
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.textTertiary)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.md)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 占位视图
struct UserProfileView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: AppTheme.Spacing.lg) {
                Text("用户资料设置")
                    .font(AppTheme.Fonts.title1)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text("这里将提供完整的用户资料编辑功能")
                    .font(AppTheme.Fonts.body)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding(AppTheme.Spacing.lg)
            .navigationTitle("个人信息")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct NotificationSettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var dailyReminderEnabled = true
    @State private var weeklyReviewEnabled = true
    @State private var reminderTime = Date()
    @State private var healthTipsEnabled = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: AppTheme.Spacing.lg) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Text("通知设置")
                        .font(AppTheme.Fonts.title2)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    VStack(spacing: AppTheme.Spacing.md) {
                        HStack {
                            Text("每日提醒")
                                .font(AppTheme.Fonts.callout)
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            
                            Spacer()
                            
                            Toggle("", isOn: $dailyReminderEnabled)
                                .toggleStyle(SwitchToggleStyle(tint: AppTheme.Colors.primary))
                        }
                        
                        if dailyReminderEnabled {
                            DatePicker("提醒时间", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                .font(AppTheme.Fonts.callout)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("周总结")
                                .font(AppTheme.Fonts.callout)
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            
                            Spacer()
                            
                            Toggle("", isOn: $weeklyReviewEnabled)
                                .toggleStyle(SwitchToggleStyle(tint: AppTheme.Colors.primary))
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("健康小贴士")
                                .font(AppTheme.Fonts.callout)
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            
                            Spacer()
                            
                            Toggle("", isOn: $healthTipsEnabled)
                                .toggleStyle(SwitchToggleStyle(tint: AppTheme.Colors.primary))
                        }
                    }
                    .padding(AppTheme.Spacing.cardPadding)
                    .background(AppTheme.Colors.surface)
                    .cornerRadius(AppTheme.CornerRadius.lg)
                }
                
                Spacer()
            }
            .padding(AppTheme.Spacing.lg)
            .navigationTitle("通知设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveNotificationSettings()
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadNotificationSettings()
            }
        }
    }
    
    private func loadNotificationSettings() {
        let profile = dataManager.userProfile
        dailyReminderEnabled = profile.enableDailyReminder
        weeklyReviewEnabled = profile.enableWeeklyReview
        healthTipsEnabled = profile.enableHealthTips
        reminderTime = profile.dailyReminderTime
        print("🔔 加载通知设置")
    }
    
    private func saveNotificationSettings() {
        dataManager.updateNotificationSettings(
            dailyReminder: dailyReminderEnabled,
            reminderTime: reminderTime,
            weeklyReview: weeklyReviewEnabled,
            healthTips: healthTipsEnabled
        )
        print("💾 保存通知设置")
    }
}

struct DataExportView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var exportedData = ""
    
    private var dataSummary: [String: Any] {
        dataManager.getDataSummary()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: AppTheme.Spacing.lg) {
                VStack(spacing: AppTheme.Spacing.md) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.Colors.primary)
                    
                    Text("数据导出")
                        .font(AppTheme.Fonts.title1)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text("将您的心情日记数据导出备份，或分享给信任的人")
                        .font(AppTheme.Fonts.body)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                // 数据概览
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Text("数据概览")
                        .font(AppTheme.Fonts.headline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    VStack(spacing: AppTheme.Spacing.sm) {
                        DataSummaryRow(label: "心情记录", value: "\(dataSummary["totalEntries"] as? Int ?? 0) 条")
                        DataSummaryRow(label: "平均心情", value: String(format: "%.1f", dataSummary["averageMood"] as? Double ?? 0.0))
                        DataSummaryRow(label: "记录期间", value: dataSummary["dateRange"] as? String ?? "无数据")
                        DataSummaryRow(label: "自定义活动", value: "\(dataSummary["customActivitiesCount"] as? Int ?? 0) 个")
                    }
                }
                .padding(AppTheme.Spacing.cardPadding)
                .background(AppTheme.Colors.surface)
                .cornerRadius(AppTheme.CornerRadius.lg)
                
                // 导出按钮
                VStack(spacing: AppTheme.Spacing.md) {
                    Button("导出JSON数据") {
                        exportAsJSON()
                    }
                    .frame(maxWidth: .infinity)
                    .primaryButtonStyle()
                    
                    Button("生成备份报告") {
                        generateBackupReport()
                    }
                    .frame(maxWidth: .infinity)
                    .secondaryButtonStyle()
                }
                
                Spacer()
                
                Text("导出的数据包含您的所有心情记录和设置信息")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textTertiary)
                    .multilineTextAlignment(.center)
            }
            .padding(AppTheme.Spacing.lg)
            .navigationTitle("数据导出")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [exportedData])
        }
    }
    
    private func exportAsJSON() {
        exportedData = dataManager.exportDataAsJSON()
        if !exportedData.isEmpty {
            showingShareSheet = true
        }
    }
    
    private func generateBackupReport() {
        let summary = dataSummary
        let reportText = """
        心情日记备份报告
        
        导出日期: \(DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .short))
        
        数据统计:
        • 心情记录总数: \(summary["totalEntries"] as? Int ?? 0) 条
        • 平均心情评分: \(String(format: "%.1f", summary["averageMood"] as? Double ?? 0.0))
        • 记录时间范围: \(summary["dateRange"] as? String ?? "无数据")
        • 自定义活动: \(summary["customActivitiesCount"] as? Int ?? 0) 个
        • 会员状态: \(summary["isPremium"] as? Bool == true ? "付费用户" : "免费用户")
        
        此报告由心情日记应用自动生成。
        """
        
        exportedData = reportText
        showingShareSheet = true
        print("📋 生成备份报告")
    }
}

struct DataSummaryRow: View {
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
                .fontWeight(.medium)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct PrivacySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: AppTheme.Spacing.lg) {
                Text("隐私设置")
                    .font(AppTheme.Fonts.title1)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text("管理您的数据隐私和权限设置")
                    .font(AppTheme.Fonts.body)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding(AppTheme.Spacing.lg)
            .navigationTitle("隐私设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: AppTheme.Spacing.lg) {
                VStack(spacing: AppTheme.Spacing.md) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.Colors.primary)
                    
                    Text("心情日记")
                        .font(AppTheme.Fonts.title1)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text("版本 1.0.0")
                        .font(AppTheme.Fonts.callout)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Text("专为老年人设计的心情记录应用")
                        .font(AppTheme.Fonts.body)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text("• 简洁易用的界面设计\n• 丰富的心情表达方式\n• 详细的数据统计分析\n• 适老化操作体验")
                        .font(AppTheme.Fonts.callout)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .lineSpacing(4)
                }
                .padding(AppTheme.Spacing.cardPadding)
                .background(AppTheme.Colors.surface)
                .cornerRadius(AppTheme.CornerRadius.lg)
                
                Spacer()
            }
            .padding(AppTheme.Spacing.lg)
            .navigationTitle("关于应用")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(DataManager.shared)
} 