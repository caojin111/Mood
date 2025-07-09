import SwiftUI
import MessageUI
import UserNotifications
import AVFoundation
import CoreLocation

// MARK: - 设置页面视图
struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingUserProfile = false
    @State private var showingNotificationSettings = false
    @State private var showingDataExport = false
    @State private var showingAbout = false
    @State private var showingPrivacySettings = false
    @State private var showingFeedback = false
    @State private var showingSupportOptions = false
    @State private var showingHapticSettings = false
    @State private var showingPhotoGallery = false
    
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
        .sheet(isPresented: $showingFeedback) {
            FeedbackView()
        }
        .sheet(isPresented: $showingSupportOptions) {
            SupportOptionsView()
        }
        .sheet(isPresented: $showingHapticSettings) {
            HapticSettingsView()
                .environmentObject(dataManager)
        }
        .sheet(isPresented: $showingPhotoGallery) {
            PhotoGalleryView()
                .environmentObject(dataManager)
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
                
                Divider()
                    .padding(.leading, 60)
                
                SettingsRow(
                    icon: "iphone.radiowaves.left.and.right",
                    title: "触感反馈",
                    subtitle: "控制震动和触觉反馈",
                    action: {
                        showingHapticSettings = true
                        print("📳 触感设置")
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
                    icon: "photo.fill",
                    title: "心情照片",
                    subtitle: "查看和管理心情照片",
                    action: {
                        showingPhotoGallery = true
                        print("📸 心情照片库")
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
                        showingSupportOptions = true
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
                        showingFeedback = true
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

// MARK: - 用户资料编辑视图
struct UserProfileView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedGender: Gender?
    @State private var selectedBirthday: Date = Date()
    @State private var selectedInterests: Set<InterestCategory> = []
    @State private var selectedMoodStyle: MoodStyle = .emoji
    @State private var selectedColorScheme: ColorScheme = .lightGreen
    @State private var hasChanges = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // 性别选择
                    genderSelectionSection
                    
                    // 生日设置
                    birthdaySelectionSection
                    
                    // 兴趣选择
                    interestsSelectionSection
                    
                    // 心情风格选择
                    moodStyleSelectionSection
                    
                    // 颜色主题选择
                    colorSchemeSelectionSection
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("个人信息")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveProfile()
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                    .disabled(!hasChanges)
                }
            }
            .onAppear {
                loadCurrentProfile()
            }
        }
    }
    
    // 性别选择区域
    private var genderSelectionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("性别")
                .font(AppTheme.Fonts.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            VStack(spacing: AppTheme.Spacing.sm) {
                ForEach(Gender.allCases, id: \.self) { gender in
                    Button(action: {
                        selectedGender = gender
                        hasChanges = true
                        print("👤 选择性别: \(gender.displayName)")
                    }) {
                        HStack(spacing: AppTheme.Spacing.md) {
                            Image(systemName: gender.icon)
                                .font(.title3)
                                .foregroundColor(selectedGender == gender ? .white : AppTheme.Colors.primary)
                            
                            Text(gender.displayName)
                                .font(AppTheme.Fonts.callout)
                                .foregroundColor(selectedGender == gender ? .white : AppTheme.Colors.textPrimary)
                            
                            Spacer()
                            
                            if selectedGender == gender {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(AppTheme.Spacing.md)
                        .background(selectedGender == gender ? AppTheme.Colors.primary : AppTheme.Colors.surface)
                        .cornerRadius(AppTheme.CornerRadius.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                .stroke(
                                    selectedGender == gender ? AppTheme.Colors.primary : AppTheme.Colors.separator,
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(AppTheme.Spacing.cardPadding)
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.lg)
    }
    
    // 生日设置区域
    private var birthdaySelectionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("生日")
                .font(AppTheme.Fonts.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            DatePicker(
                "选择生日",
                selection: $selectedBirthday,
                in: Date(timeIntervalSince1970: -2_208_988_800)...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(WheelDatePickerStyle())
            .labelsHidden()
            .environment(\.locale, Locale(identifier: "zh_CN"))
            .onChange(of: selectedBirthday) { _ in
                hasChanges = true
                print("📅 选择生日: \(selectedBirthday)")
            }
        }
        .padding(AppTheme.Spacing.cardPadding)
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.lg)
    }
    
    // 兴趣选择区域
    private var interestsSelectionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("兴趣爱好")
                .font(AppTheme.Fonts.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("选择您感兴趣的活动分类（可多选）")
                .font(AppTheme.Fonts.callout)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: AppTheme.Spacing.sm) {
                ForEach(InterestCategory.allCases, id: \.self) { interest in
                    Button(action: {
                        if selectedInterests.contains(interest) {
                            selectedInterests.remove(interest)
                        } else {
                            selectedInterests.insert(interest)
                        }
                        hasChanges = true
                        print("🎯 切换兴趣: \(interest.displayName)")
                    }) {
                        HStack(spacing: AppTheme.Spacing.sm) {
                            Image(systemName: interest.icon)
                                .font(.caption)
                                .foregroundColor(selectedInterests.contains(interest) ? .white : AppTheme.Colors.primary)
                            
                            Text(interest.displayName)
                                .font(AppTheme.Fonts.caption)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .background(selectedInterests.contains(interest) ? AppTheme.Colors.primary : AppTheme.Colors.background)
                        .foregroundColor(selectedInterests.contains(interest) ? .white : AppTheme.Colors.textPrimary)
                        .cornerRadius(AppTheme.CornerRadius.sm)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                                .stroke(
                                    selectedInterests.contains(interest) ? AppTheme.Colors.primary : AppTheme.Colors.separator,
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(AppTheme.Spacing.cardPadding)
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.lg)
    }
    
    // 心情风格选择区域
    private var moodStyleSelectionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("心情风格")
                .font(AppTheme.Fonts.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("选择您偏好的心情显示风格")
                .font(AppTheme.Fonts.callout)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            VStack(spacing: AppTheme.Spacing.sm) {
                ForEach(MoodStyle.allCases, id: \.self) { style in
                    Button(action: {
                        selectedMoodStyle = style
                        hasChanges = true
                        print("🎨 选择心情风格: \(style.rawValue)")
                    }) {
                        HStack(spacing: AppTheme.Spacing.md) {
                            Text(style.previewIcon)
                                .font(.title2)
                            
                            Text(style.rawValue)
                                .font(AppTheme.Fonts.callout)
                                .foregroundColor(selectedMoodStyle == style ? .white : AppTheme.Colors.textPrimary)
                            
                            Spacer()
                            
                            if selectedMoodStyle == style {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(AppTheme.Spacing.md)
                        .background(selectedMoodStyle == style ? AppTheme.Colors.primary : AppTheme.Colors.background)
                        .cornerRadius(AppTheme.CornerRadius.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                .stroke(
                                    selectedMoodStyle == style ? AppTheme.Colors.primary : AppTheme.Colors.separator,
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(AppTheme.Spacing.cardPadding)
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.lg)
    }
    
    // 颜色主题选择区域
    private var colorSchemeSelectionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("颜色主题")
                .font(AppTheme.Fonts.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("选择您喜欢的应用颜色主题")
                .font(AppTheme.Fonts.callout)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: AppTheme.Spacing.sm) {
                ForEach(ColorScheme.allCases, id: \.self) { scheme in
                    Button(action: {
                        selectedColorScheme = scheme
                        hasChanges = true
                        print("🌈 选择颜色主题: \(scheme.rawValue)")
                    }) {
                        VStack(spacing: AppTheme.Spacing.sm) {
                            Circle()
                                .fill(getColorForScheme(scheme))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(AppTheme.Colors.separator, lineWidth: 1)
                                )
                            
                            Text(scheme.rawValue)
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(selectedColorScheme == scheme ? .white : AppTheme.Colors.textPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(AppTheme.Spacing.md)
                        .background(selectedColorScheme == scheme ? AppTheme.Colors.primary : AppTheme.Colors.background)
                        .cornerRadius(AppTheme.CornerRadius.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                .stroke(
                                    selectedColorScheme == scheme ? AppTheme.Colors.primary : AppTheme.Colors.separator,
                                    lineWidth: selectedColorScheme == scheme ? 2 : 1
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(AppTheme.Spacing.cardPadding)
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.lg)
    }
    
    // 加载当前配置
    private func loadCurrentProfile() {
        let profile = dataManager.userProfile
        selectedGender = profile.gender
        selectedBirthday = profile.birthday ?? Date()
        selectedInterests = Set(profile.interestedCategories.compactMap { InterestCategory(rawValue: $0) })
        selectedMoodStyle = profile.preferredMoodStyle
        selectedColorScheme = ColorScheme.allCases.first { $0.rawValue == profile.preferredColorScheme } ?? .lightGreen
        print("📂 加载用户配置数据")
    }
    
    // 保存配置
    private func saveProfile() {
        var profile = dataManager.userProfile
        profile.gender = selectedGender
        profile.birthday = selectedBirthday
        profile.interestedCategories = Array(selectedInterests.map { $0.rawValue })
        profile.preferredMoodStyle = selectedMoodStyle
        profile.preferredColorScheme = selectedColorScheme.rawValue
        profile.updatedAt = Date()
        
        dataManager.updateUserProfile(profile)
        hasChanges = false
        dismiss()
        print("💾 保存用户配置更新")
    }
    
    // 获取颜色主题对应的颜色
    private func getColorForScheme(_ scheme: ColorScheme) -> Color {
        switch scheme {
        case .lightGreen:
            return Color.green.opacity(0.7)
        case .warmGray:
            return Color.gray.opacity(0.7)
        case .softBlue:
            return Color.blue.opacity(0.7)
        case .classic:
            return AppTheme.Colors.primary
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
    @State private var dataCollectionEnabled = true
    @State private var analyticsEnabled = false
    @State private var crashReportsEnabled = true
    @State private var locationPermission = false
    @State private var cameraPermission = false
    @State private var notificationPermission = true
    @State private var showingPermissionAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // 标题说明
                    headerSection
                    
                    // 数据收集设置
                    dataCollectionSection
                    
                    // 权限管理
                    permissionsSection
                    
                    // 安全设置
                    securitySection
                    
                    // 数据管理
                    dataManagementSection
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("隐私设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                }
            }
        }
        .alert(alertTitle, isPresented: $showingPermissionAlert) {
            Button("去设置", role: .cancel) {
                openAppSettings()
            }
            Button("取消") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // 标题说明区域
    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.Colors.primary)
            
            Text("隐私与安全")
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .fontWeight(.semibold)
            
            Text("我们重视您的隐私，您可以随时控制数据的使用")
                .font(AppTheme.Fonts.callout)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppTheme.Spacing.cardPadding)
    }
    
    // 数据收集设置区域
    private var dataCollectionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("数据收集")
                .font(AppTheme.Fonts.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            VStack(spacing: 0) {
                PrivacyToggleRow(
                    icon: "chart.bar.fill",
                    iconColor: .blue,
                    title: "使用统计",
                    subtitle: "帮助我们改进应用功能",
                    isOn: $analyticsEnabled
                ) {
                    print("📊 分析数据收集: \(analyticsEnabled)")
                }
                
                Divider()
                    .padding(.leading, 60)
                
                PrivacyToggleRow(
                    icon: "exclamationmark.triangle.fill",
                    iconColor: .orange,
                    title: "崩溃报告",
                    subtitle: "自动发送崩溃信息以提升稳定性",
                    isOn: $crashReportsEnabled
                ) {
                    print("🐛 崩溃报告: \(crashReportsEnabled)")
                }
                
                Divider()
                    .padding(.leading, 60)
                
                PrivacyToggleRow(
                    icon: "externaldrive.fill",
                    iconColor: .green,
                    title: "本地数据",
                    subtitle: "所有心情数据仅存储在您的设备上",
                    isOn: .constant(true)
                ) {
                    // 本地数据存储不可关闭
                }
            }
            .background(AppTheme.Colors.surface)
            .cornerRadius(AppTheme.CornerRadius.lg)
        }
    }
    
    // 权限管理区域
    private var permissionsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("应用权限")
                .font(AppTheme.Fonts.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            VStack(spacing: 0) {
                PermissionRow(
                    icon: "bell.fill",
                    iconColor: .red,
                    title: "通知权限",
                    subtitle: notificationPermission ? "已授权 - 可接收提醒" : "未授权 - 无法接收提醒",
                    status: notificationPermission
                ) {
                    requestNotificationPermission()
                }
                
                Divider()
                    .padding(.leading, 60)
                
                PermissionRow(
                    icon: "camera.fill",
                    iconColor: .blue,
                    title: "相机权限",
                    subtitle: cameraPermission ? "已授权 - 可拍摄心情照片" : "未授权 - 无法使用相机",
                    status: cameraPermission
                ) {
                    requestCameraPermission()
                }
                
                Divider()
                    .padding(.leading, 60)
                
                PermissionRow(
                    icon: "location.fill",
                    iconColor: .purple,
                    title: "位置权限",
                    subtitle: locationPermission ? "已授权 - 记录心情地点" : "未授权 - 不记录位置信息",
                    status: locationPermission
                ) {
                    requestLocationPermission()
                }
            }
            .background(AppTheme.Colors.surface)
            .cornerRadius(AppTheme.CornerRadius.lg)
            
            Text("权限用于提供更好的功能体验，您可以随时在系统设置中修改")
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.textTertiary)
        }
    }
    
    // 安全设置区域
    private var securitySection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("安全保护")
                .font(AppTheme.Fonts.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            VStack(spacing: 0) {
                PrivacyInfoRow(
                    icon: "lock.fill",
                    iconColor: .green,
                    title: "数据加密",
                    subtitle: "所有数据均采用256位AES加密"
                )
                
                Divider()
                    .padding(.leading, 60)
                
                PrivacyInfoRow(
                    icon: "iphone.lock",
                    iconColor: .blue,
                    title: "本地存储",
                    subtitle: "数据仅存储在您的设备上，不上传云端"
                )
                
                Divider()
                    .padding(.leading, 60)
                
                PrivacyInfoRow(
                    icon: "eye.slash.fill",
                    iconColor: .purple,
                    title: "隐私保护",
                    subtitle: "无第三方追踪，不收集个人敏感信息"
                )
            }
            .background(AppTheme.Colors.surface)
            .cornerRadius(AppTheme.CornerRadius.lg)
        }
    }
    
    // 数据管理区域
    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("数据管理")
                .font(AppTheme.Fonts.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            VStack(spacing: AppTheme.Spacing.sm) {
                Button("查看隐私政策") {
                    openPrivacyPolicy()
                }
                .frame(maxWidth: .infinity)
                .secondaryButtonStyle()
                
                Button("查看用户协议") {
                    openUserAgreement()
                }
                .frame(maxWidth: .infinity)
                .secondaryButtonStyle()
                
                Button("联系隐私官") {
                    contactPrivacyOfficer()
                }
                .frame(maxWidth: .infinity)
                .secondaryButtonStyle()
            }
        }
    }
    
    // 请求通知权限
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.notificationPermission = granted
                if !granted {
                    self.alertTitle = "通知权限"
                    self.alertMessage = "请在设置中开启通知权限以接收心情提醒"
                    self.showingPermissionAlert = true
                }
            }
        }
    }
    
    // 请求相机权限
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                self.cameraPermission = granted
                if !granted {
                    self.alertTitle = "相机权限"
                    self.alertMessage = "请在设置中开启相机权限以拍摄心情照片"
                    self.showingPermissionAlert = true
                }
            }
        }
    }
    
    // 请求位置权限
    private func requestLocationPermission() {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        // 这里简化处理，实际项目中需要实现CLLocationManagerDelegate
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let status = CLLocationManager.authorizationStatus()
            self.locationPermission = status == .authorizedWhenInUse || status == .authorizedAlways
            
            if !self.locationPermission {
                self.alertTitle = "位置权限"
                self.alertMessage = "请在设置中开启位置权限以记录心情地点"
                self.showingPermissionAlert = true
            }
        }
    }
    
    // 打开应用设置
    private func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    // 打开隐私政策
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://example.com/privacy-policy") {
            UIApplication.shared.open(url)
        }
        print("📋 查看隐私政策")
    }
    
    // 打开用户协议
    private func openUserAgreement() {
        if let url = URL(string: "https://example.com/user-agreement") {
            UIApplication.shared.open(url)
        }
        print("📋 查看用户协议")
    }
    
    // 联系隐私官
    private func contactPrivacyOfficer() {
        if let url = URL(string: "mailto:privacy@moodjournal.app?subject=隐私咨询") {
            UIApplication.shared.open(url)
        }
        print("📧 联系隐私官")
    }
}

// MARK: - 隐私切换行组件
struct PrivacyToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 28, height: 28)
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(title)
                    .font(AppTheme.Fonts.callout)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text(subtitle)
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: AppTheme.Colors.primary))
                .onChange(of: isOn) { _ in
                    action()
                }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.md)
    }
}

// MARK: - 权限行组件
struct PermissionRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let status: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(iconColor)
                    .frame(width: 28, height: 28)
                
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(title)
                        .font(AppTheme.Fonts.callout)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text(subtitle)
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: status ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(status ? .green : .red)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.md)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 隐私信息行组件
struct PrivacyInfoRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 28, height: 28)
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(title)
                    .font(AppTheme.Fonts.callout)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text(subtitle)
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.seal.fill")
                .font(.title3)
                .foregroundColor(.green)
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.md)
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

// MARK: - 意见反馈视图
struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackText = ""
    @State private var selectedCategory: FeedbackCategory = .suggestion
    @State private var contactEmail = ""
    @State private var showingSuccessAlert = false
    @State private var showingMailComposer = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    enum FeedbackCategory: String, CaseIterable {
        case bug = "问题报告"
        case suggestion = "功能建议"
        case praise = "表扬鼓励"
        case other = "其他反馈"
        
        var icon: String {
            switch self {
            case .bug: return "ladybug.fill"
            case .suggestion: return "lightbulb.fill"
            case .praise: return "heart.fill"
            case .other: return "bubble.left.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .bug: return .red
            case .suggestion: return .blue
            case .praise: return .pink
            case .other: return .gray
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // 标题说明
                    headerSection
                    
                    // 反馈分类选择
                    categorySelectionSection
                    
                    // 反馈内容输入
                    feedbackInputSection
                    
                    // 联系方式输入
                    contactInputSection
                    
                    // 提交按钮
                    submitButton
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("意见反馈")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
        }
        .alert("反馈成功", isPresented: $showingSuccessAlert) {
            Button("确定") {
                dismiss()
            }
        } message: {
            Text("感谢您的反馈！我们会认真考虑您的建议。")
        }
        .alert("发送失败", isPresented: $showingErrorAlert) {
            Button("确定") { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showingMailComposer) {
            MailComposerView(
                subject: "心情日记 - \(selectedCategory.rawValue)",
                body: generateEmailBody(),
                recipients: ["feedback@moodjournal.app"]
            )
        }
    }
    
    // 标题说明区域
    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "envelope.open.fill")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.Colors.primary)
            
            Text("您的意见对我们很重要")
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .fontWeight(.semibold)
            
            Text("请告诉我们您的想法，帮助我们改进应用")
                .font(AppTheme.Fonts.callout)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppTheme.Spacing.cardPadding)
    }
    
    // 反馈分类选择区域
    private var categorySelectionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("反馈类型")
                .font(AppTheme.Fonts.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: AppTheme.Spacing.sm) {
                ForEach(FeedbackCategory.allCases, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                        print("📋 选择反馈类型: \(category.rawValue)")
                    }) {
                        VStack(spacing: AppTheme.Spacing.sm) {
                            Image(systemName: category.icon)
                                .font(.title2)
                                .foregroundColor(selectedCategory == category ? .white : category.color)
                            
                            Text(category.rawValue)
                                .font(AppTheme.Fonts.caption)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .foregroundColor(selectedCategory == category ? .white : AppTheme.Colors.textPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(AppTheme.Spacing.md)
                        .background(selectedCategory == category ? category.color : AppTheme.Colors.surface)
                        .cornerRadius(AppTheme.CornerRadius.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                .stroke(
                                    selectedCategory == category ? category.color : AppTheme.Colors.separator,
                                    lineWidth: selectedCategory == category ? 2 : 1
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(AppTheme.Spacing.cardPadding)
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.lg)
    }
    
    // 反馈内容输入区域
    private var feedbackInputSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("详细说明")
                .font(AppTheme.Fonts.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("请详细描述您的反馈内容")
                .font(AppTheme.Fonts.callout)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            ZStack(alignment: .topLeading) {
                if feedbackText.isEmpty {
                    Text("请在这里输入您的反馈内容...")
                        .font(AppTheme.Fonts.body)
                        .foregroundColor(AppTheme.Colors.textTertiary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                }
                
                TextEditor(text: $feedbackText)
                    .font(AppTheme.Fonts.body)
                    .frame(minHeight: 120)
                    .scrollContentBackground(.hidden)
            }
            .background(AppTheme.Colors.background)
            .cornerRadius(AppTheme.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .stroke(AppTheme.Colors.separator, lineWidth: 1)
            )
        }
        .padding(AppTheme.Spacing.cardPadding)
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.lg)
    }
    
    // 联系方式输入区域
    private var contactInputSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("联系方式")
                .font(AppTheme.Fonts.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("如需回复，请留下您的邮箱地址（可选）")
                .font(AppTheme.Fonts.callout)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            TextField("your@email.com", text: $contactEmail)
                .font(AppTheme.Fonts.body)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Colors.background)
                .cornerRadius(AppTheme.CornerRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .stroke(AppTheme.Colors.separator, lineWidth: 1)
                )
        }
        .padding(AppTheme.Spacing.cardPadding)
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.lg)
    }
    
    // 提交按钮
    private var submitButton: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Button("发送邮件反馈") {
                sendEmailFeedback()
            }
            .frame(maxWidth: .infinity)
            .primaryButtonStyle()
            .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            
            Button("提交到应用内") {
                submitInAppFeedback()
            }
            .frame(maxWidth: .infinity)
            .secondaryButtonStyle()
            .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            
            Text("我们会认真阅读每一条反馈")
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.textTertiary)
                .multilineTextAlignment(.center)
        }
    }
    
    // 发送邮件反馈
    private func sendEmailFeedback() {
        if MailComposerView.canSendMail() {
            showingMailComposer = true
        } else {
            errorMessage = "无法发送邮件，请检查邮件设置或使用应用内反馈"
            showingErrorAlert = true
        }
    }
    
    // 提交应用内反馈
    private func submitInAppFeedback() {
        // 模拟提交反馈
        let feedback = """
        反馈类型: \(selectedCategory.rawValue)
        反馈内容: \(feedbackText)
        联系邮箱: \(contactEmail.isEmpty ? "未提供" : contactEmail)
        提交时间: \(DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .short))
        """
        
        // 这里可以集成实际的反馈系统，比如Firebase Crashlytics或其他服务
        print("📬 提交反馈: \(feedback)")
        
        // 模拟网络请求延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showingSuccessAlert = true
        }
    }
    
    // 生成邮件正文
    private func generateEmailBody() -> String {
        let deviceInfo = """
        
        ===== 设备信息 =====
        应用版本: 1.0.0
        系统版本: iOS \(UIDevice.current.systemVersion)
        设备型号: \(UIDevice.current.model)
        
        ===== 反馈内容 =====
        反馈类型: \(selectedCategory.rawValue)
        
        \(feedbackText)
        """
        
        return deviceInfo
    }
}

// MARK: - 邮件编辑器视图
struct MailComposerView: UIViewControllerRepresentable {
    let subject: String
    let body: String
    let recipients: [String]
    
    static func canSendMail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setSubject(subject)
        composer.setMessageBody(body, isHTML: false)
        composer.setToRecipients(recipients)
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        }
    }
}

// MARK: - 支持选项视图
struct SupportOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var showingSuccessAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // 标题说明
                    headerSection
                    
                    // 支持选项
                    supportOptionsSection
                    
                    // 分享选项
                    shareOptionsSection
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("支持我们")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [shareText])
        }
        .alert(alertTitle, isPresented: $showingSuccessAlert) {
            Button("确定") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // 标题说明区域
    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.pink)
            
            Text("感谢您的支持")
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .fontWeight(.semibold)
            
            Text("您的支持是我们持续改进的动力")
                .font(AppTheme.Fonts.callout)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppTheme.Spacing.cardPadding)
    }
    
    // 支持选项区域
    private var supportOptionsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("给我们评分")
                .font(AppTheme.Fonts.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            VStack(spacing: 0) {
                SupportOptionRow(
                    icon: "star.fill",
                    iconColor: .orange,
                    title: "App Store 评分",
                    subtitle: "在 App Store 给我们五星好评",
                    action: {
                        rateApp()
                    }
                )
                
                Divider()
                    .padding(.leading, 60)
                
                SupportOptionRow(
                    icon: "text.bubble.fill",
                    iconColor: .blue,
                    title: "写评论",
                    subtitle: "分享您的使用体验",
                    action: {
                        writeReview()
                    }
                )
                
                Divider()
                    .padding(.leading, 60)
                
                SupportOptionRow(
                    icon: "gift.fill",
                    iconColor: .purple,
                    title: "推荐给朋友",
                    subtitle: "推荐给更多需要的人",
                    action: {
                        showingShareSheet = true
                    }
                )
            }
            .background(AppTheme.Colors.surface)
            .cornerRadius(AppTheme.CornerRadius.lg)
        }
    }
    
    // 分享选项区域
    private var shareOptionsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("传播温暖")
                .font(AppTheme.Fonts.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            VStack(spacing: 0) {
                SupportOptionRow(
                    icon: "person.2.fill",
                    iconColor: .green,
                    title: "分享给家人",
                    subtitle: "让家人也能记录美好心情",
                    action: {
                        shareToFamily()
                    }
                )
                
                Divider()
                    .padding(.leading, 60)
                
                SupportOptionRow(
                    icon: "heart.text.square.fill",
                    iconColor: .red,
                    title: "社交媒体分享",
                    subtitle: "在朋友圈分享您的心得",
                    action: {
                        shareToSocial()
                    }
                )
                
                Divider()
                    .padding(.leading, 60)
                
                SupportOptionRow(
                    icon: "envelope.fill",
                    iconColor: .teal,
                    title: "邮件推荐",
                    subtitle: "通过邮件推荐给朋友",
                    action: {
                        shareByEmail()
                    }
                )
            }
            .background(AppTheme.Colors.surface)
            .cornerRadius(AppTheme.CornerRadius.lg)
            
            Text("让更多老年朋友享受数字生活的便利")
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.textTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }
    
    // 分享文本
    private var shareText: String {
        return """
        推荐一个很棒的心情日记应用 - 心情日记 📝
        
        专为老年朋友设计，界面简洁易用，功能丰富实用：
        • 记录每日心情和活动
        • 查看心情变化趋势
        • 个性化皮肤和主题
        • 数据导出和备份
        
        让我们一起记录生活中的美好时光 ❤️
        """
    }
    
    // App Store 评分
    private func rateApp() {
        if let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID?action=write-review") {
            UIApplication.shared.open(url)
            alertTitle = "感谢支持"
            alertMessage = "您的评分对我们非常重要！"
            showingSuccessAlert = true
        }
    }
    
    // 写评论
    private func writeReview() {
        if let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID?action=write-review") {
            UIApplication.shared.open(url)
            alertTitle = "谢谢您"
            alertMessage = "您的评论将帮助更多人了解我们的应用"
            showingSuccessAlert = true
        }
    }
    
    // 分享给家人
    private func shareToFamily() {
        showingShareSheet = true
        print("👨‍👩‍👧‍👦 分享给家人")
    }
    
    // 社交媒体分享
    private func shareToSocial() {
        showingShareSheet = true
        print("📱 社交媒体分享")
    }
    
    // 邮件推荐
    private func shareByEmail() {
        let emailText = shareText.replacingOccurrences(of: "\n", with: "%0D%0A")
        if let url = URL(string: "mailto:?subject=推荐心情日记应用&body=\(emailText)") {
            UIApplication.shared.open(url)
        }
        print("📧 邮件推荐")
    }
}

// MARK: - 支持选项行组件
struct SupportOptionRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.md) {
                // 图标
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(iconColor)
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

// MARK: - 触感设置视图
struct HapticSettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var hapticEnabled = true
    @State private var hapticIntensity: Double = 0.8
    @State private var showingTestAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // 标题说明
                    headerSection
                    
                    // 触感开关
                    hapticToggleSection
                    
                    // 强度设置
                    if hapticEnabled {
                        intensitySection
                    }
                    
                    // 测试区域
                    if hapticEnabled {
                        testSection
                    }
                    
                    // 说明信息
                    explanationSection
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("触感反馈")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveHapticSettings()
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                }
            }
            .onAppear {
                loadHapticSettings()
            }
        }
        .alert("触感测试", isPresented: $showingTestAlert) {
            Button("确定") { }
        } message: {
            Text("触感反馈已触发，您感受到了吗？")
        }
    }
    
    // 标题说明区域
    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "iphone.radiowaves.left.and.right")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.Colors.primary)
            
            Text("触感反馈设置")
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .fontWeight(.semibold)
            
            Text("控制应用操作时的震动反馈")
                .font(AppTheme.Fonts.callout)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppTheme.Spacing.cardPadding)
    }
    
    // 触感开关区域
    private var hapticToggleSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("触感反馈")
                .font(AppTheme.Fonts.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text("启用触感反馈")
                        .font(AppTheme.Fonts.callout)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text("在按钮点击、选择操作时提供震动反馈")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $hapticEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: AppTheme.Colors.primary))
                    .onChange(of: hapticEnabled) { enabled in
                        if enabled {
                            HapticManager.shared.triggerSelection()
                        }
                        print("📳 触感反馈: \(enabled ? "开启" : "关闭")")
                    }
            }
        }
        .padding(AppTheme.Spacing.cardPadding)
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.lg)
    }
    
    // 强度设置区域
    private var intensitySection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("反馈强度")
                .font(AppTheme.Fonts.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            VStack(spacing: AppTheme.Spacing.md) {
                HStack {
                    Text("轻")
                        .font(AppTheme.Fonts.callout)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    Spacer()
                    
                    Text("强")
                        .font(AppTheme.Fonts.callout)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                Slider(value: $hapticIntensity, in: 0.1...1.0, step: 0.1) { editing in
                    if !editing {
                        // 滑动结束时触发对应强度的触感反馈
                        HapticManager.shared.triggerImpact(intensity: hapticIntensity)
                        print("📳 调整触感强度: \(hapticIntensity)")
                    }
                }
                .accentColor(AppTheme.Colors.primary)
                
                HStack {
                    Text("当前强度")
                        .font(AppTheme.Fonts.callout)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    Spacer()
                    
                    Text("\(Int(hapticIntensity * 100))%")
                        .font(AppTheme.Fonts.callout)
                        .foregroundColor(AppTheme.Colors.primary)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(AppTheme.Spacing.cardPadding)
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.lg)
    }
    
    // 测试区域
    private var testSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("触感测试")
                .font(AppTheme.Fonts.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            VStack(spacing: AppTheme.Spacing.sm) {
                HapticTestButton(
                    title: "选择反馈",
                    description: "点击时的轻微反馈",
                    color: .blue
                ) {
                    HapticManager.shared.triggerSelection()
                }
                
                HapticTestButton(
                    title: "轻度冲击",
                    description: "轻微的触感冲击",
                    color: .green
                ) {
                    HapticManager.shared.triggerImpact(style: .light)
                }
                
                HapticTestButton(
                    title: "中度冲击",
                    description: "适中的触感冲击",
                    color: .orange
                ) {
                    HapticManager.shared.triggerImpact(style: .medium)
                }
                
                HapticTestButton(
                    title: "重度冲击",
                    description: "强烈的触感冲击",
                    color: .red
                ) {
                    HapticManager.shared.triggerImpact(style: .heavy)
                }
            }
        }
        .padding(AppTheme.Spacing.cardPadding)
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.lg)
    }
    
    // 说明信息区域
    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("使用说明")
                .font(AppTheme.Fonts.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                ExplanationRow(icon: "hand.tap", text: "触感反馈可以增强操作体验")
                ExplanationRow(icon: "gear", text: "在设备的设置中也可以全局控制触感")
                ExplanationRow(icon: "battery.100", text: "关闭触感反馈可以节省电量")
                ExplanationRow(icon: "accessibility", text: "对听力不便的用户特别有用")
            }
        }
        .padding(AppTheme.Spacing.cardPadding)
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.lg)
    }
    
    // 加载设置
    private func loadHapticSettings() {
        let profile = dataManager.userProfile
        hapticEnabled = profile.enableHapticFeedback
        hapticIntensity = profile.hapticIntensity
        print("📂 加载触感设置: 启用=\(hapticEnabled), 强度=\(hapticIntensity)")
    }
    
    // 保存设置
    private func saveHapticSettings() {
        dataManager.updateHapticSettings(enabled: hapticEnabled, intensity: hapticIntensity)
        
        // 更新触感管理器的设置
        HapticManager.shared.updateSettings(enabled: hapticEnabled, intensity: hapticIntensity)
        
        dismiss()
        print("💾 保存触感设置")
    }
}

// MARK: - 触感测试按钮
struct HapticTestButton: View {
    let title: String
    let description: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.md) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(title)
                        .font(AppTheme.Fonts.callout)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text(description)
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.background)
            .cornerRadius(AppTheme.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .stroke(AppTheme.Colors.separator, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 说明行组件
struct ExplanationRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 16)
            
            Text(text)
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
    }
}

// MARK: - 触感管理器
class HapticManager: ObservableObject {
    static let shared = HapticManager()
    
    private var isEnabled = true
    private var intensity: Double = 0.8
    
    private init() {
        // 从DataManager加载设置
        loadSettings()
    }
    
    // 更新设置
    func updateSettings(enabled: Bool, intensity: Double) {
        self.isEnabled = enabled
        self.intensity = intensity
        print("📳 触感管理器更新设置: 启用=\(enabled), 强度=\(intensity)")
    }
    
    // 选择反馈
    func triggerSelection() {
        guard isEnabled else { return }
        let impactFeedback = UISelectionFeedbackGenerator()
        impactFeedback.selectionChanged()
    }
    
    // 冲击反馈
    func triggerImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard isEnabled else { return }
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.impactOccurred()
    }
    
    // 根据强度触发冲击反馈
    func triggerImpact(intensity: Double) {
        guard isEnabled else { return }
        
        let style: UIImpactFeedbackGenerator.FeedbackStyle
        switch intensity {
        case 0.0..<0.4:
            style = .light
        case 0.4..<0.7:
            style = .medium
        default:
            style = .heavy
        }
        
        triggerImpact(style: style)
    }
    
    // 通知反馈
    func triggerNotification(type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isEnabled else { return }
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(type)
    }
    
    // 加载设置
    private func loadSettings() {
        let profile = DataManager.shared.userProfile
        self.isEnabled = profile.enableHapticFeedback
        self.intensity = profile.hapticIntensity
    }
}

// MARK: - 心情照片库视图
struct PhotoGalleryView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var moodPhotos: [MoodPhoto] = []
    
    // 网格布局
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if moodPhotos.isEmpty {
                    emptyStateView
                } else {
                    photoGridView
                }
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("心情照片")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            sourceType = .camera
                            showingImagePicker = true
                        }) {
                            Label("拍照", systemImage: "camera")
                        }
                        
                        Button(action: {
                            sourceType = .photoLibrary
                            showingImagePicker = true
                        }) {
                            Label("从相册选择", systemImage: "photo.on.rectangle")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: sourceType)
        }
        .onChange(of: selectedImage) { _, newImage in
            if let image = newImage {
                addMoodPhoto(image: image)
                selectedImage = nil // 重置选择
            }
        }
        .onAppear {
            loadMoodPhotos()
        }
    }
    
    // 空状态视图
    private var emptyStateView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()
            
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.Colors.textTertiary)
            
            Text("还没有心情照片")
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("记录生活中的美好瞬间，为心情日记增添色彩")
                .font(AppTheme.Fonts.callout)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.lg)
            
            VStack(spacing: AppTheme.Spacing.md) {
                Button("拍摄照片") {
                    sourceType = .camera
                    showingImagePicker = true
                }
                .frame(maxWidth: .infinity)
                .primaryButtonStyle()
                .padding(.horizontal, AppTheme.Spacing.lg)
                
                Button("从相册选择") {
                    sourceType = .photoLibrary
                    showingImagePicker = true
                }
                .frame(maxWidth: .infinity)
                .secondaryButtonStyle()
                .padding(.horizontal, AppTheme.Spacing.lg)
            }
            
            Spacer()
        }
    }
    
    // 照片网格视图
    private var photoGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: AppTheme.Spacing.sm) {
                ForEach(moodPhotos) { photo in
                    PhotoGridItem(photo: photo) {
                        deleteMoodPhoto(photo)
                    }
                }
            }
            .padding(AppTheme.Spacing.md)
        }
    }
    
    // 加载心情照片
    private func loadMoodPhotos() {
        // 模拟加载照片数据
        // 实际项目中应该从DataManager或Core Data加载
        moodPhotos = []
        print("📸 加载心情照片库")
    }
    
    // 添加心情照片
    private func addMoodPhoto(image: UIImage) {
        let photo = MoodPhoto(
            id: UUID(),
            image: image,
            createdAt: Date(),
            mood: 4, // 默认心情
            note: nil
        )
        
        moodPhotos.append(photo)
        // 这里应该保存到DataManager
        print("📸 添加心情照片: \(photo.id)")
    }
    
    // 删除心情照片
    private func deleteMoodPhoto(_ photo: MoodPhoto) {
        moodPhotos.removeAll { $0.id == photo.id }
        print("🗑️ 删除心情照片: \(photo.id)")
    }
}

// MARK: - 心情照片模型
struct MoodPhoto: Identifiable {
    let id: UUID
    let image: UIImage
    let createdAt: Date
    let mood: Int // 1-5
    let note: String?
}

// MARK: - 照片网格项
struct PhotoGridItem: View {
    let photo: MoodPhoto
    let onDelete: () -> Void
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 照片
            Image(uiImage: photo.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipped()
                .cornerRadius(AppTheme.CornerRadius.md)
            
            // 删除按钮
            Button(action: {
                showingDeleteAlert = true
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
            }
            .padding(AppTheme.Spacing.xs)
        }
        .alert("删除照片", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("确定要删除这张心情照片吗？")
        }
    }
}



#Preview {
    SettingsView()
        .environmentObject(DataManager.shared)
} 