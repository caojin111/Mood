import SwiftUI
import UserNotifications

// MARK: - 欢迎页面（Splash页面）
struct WelcomeStepView: View {
    @EnvironmentObject var onboardingData: OnboardingData
    
    var body: some View {
        // 全屏的可点击区域
        GeometryReader { geometry in
            ZStack {
                // 背景
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: AppTheme.Spacing.xl) {
                    Spacer()
                    
                    // APP Logo （用临时图替代）
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 120))
                        .foregroundColor(AppTheme.Colors.primary)
                        .padding(.bottom, AppTheme.Spacing.md)
                    
                    // APP 标题
                    Text("心情日记")
                        .font(AppTheme.Fonts.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .padding(.bottom, AppTheme.Spacing.lg)
                    
                    // 开发者名字
                    Text("Made by LazyCat")
                        .font(AppTheme.Fonts.headline)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    // 提示文本
                    Text("轻触屏幕开始")
                        .font(AppTheme.Fonts.callout)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .opacity(0.8)
                        .padding(.bottom, AppTheme.Spacing.xl)
                }
            }
            .contentShape(Rectangle()) // 让整个区域都可以点击
            .onTapGesture {
                print("🎯 Splash页面被点击，跳转到下一步")
                onboardingData.moveToNext()
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(title)
                    .font(AppTheme.Fonts.callout)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - 性别选择
struct GenderSelectionStepView: View {
    @Binding var selectedGender: Gender?
    
    var body: some View {
        OnboardingStepContainer(step: .gender) {
            VStack(spacing: AppTheme.Spacing.lg) {
                ForEach(Gender.allCases, id: \.self) { gender in
                    GenderSelectionButton(
                        gender: gender,
                        isSelected: selectedGender == gender
                    ) {
                        selectedGender = gender
                        print("👤 选择性别: \(gender.displayName)")
                    }
                }
            }
        }
    }
}

// MARK: - 心情皮肤选择
struct MoodSkinSelectionStepView: View {
    @Binding var selectedSkinPack: String?
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        OnboardingStepContainer(step: .moodSkinSelection) {
            VStack(spacing: AppTheme.Spacing.lg) {
                ForEach(dataManager.availableSkinPacks, id: \.id) { skinPack in
                    SkinPackSelectionButton(
                        skinPack: skinPack,
                        isSelected: selectedSkinPack == skinPack.id
                    ) {
                        selectedSkinPack = skinPack.id
                        print("🎨 选择皮肤包: \(skinPack.name)")
                    }
                }
            }
        }
    }
}

// MARK: - 颜色方案选择
struct ColorSchemeStepView: View {
    @Binding var selectedColorScheme: ColorSchemeOption
    
    var body: some View {
        OnboardingStepContainer(step: .colorScheme) {
            VStack(spacing: AppTheme.Spacing.lg) {
                ForEach(ColorSchemeOption.allCases, id: \.self) { colorScheme in
                    ColorSchemeSelectionButton(
                        colorScheme: colorScheme,
                        isSelected: selectedColorScheme == colorScheme,
                        description: colorSchemeDescription(colorScheme)
                    ) {
                        selectedColorScheme = colorScheme
                        print("🎨 选择颜色方案: \(colorScheme.displayName)")
                    }
                }
            }
        }
    }
    
    private func colorSchemeDescription(_ colorScheme: ColorSchemeOption) -> String {
        switch colorScheme {
        case .light:
            return "明亮的界面，适合白天使用"
        case .dark:
            return "深色界面，适合夜间使用"
        case .system:
            return "根据系统设置自动切换"
        }
    }
}

// MARK: - 兴趣选择
struct InterestsStepView: View {
    @Binding var selectedInterests: Set<InterestCategory>
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: AppTheme.Spacing.sm)
    ]
    
    var body: some View {
        OnboardingStepContainer(step: .interests) {
            VStack(spacing: AppTheme.Spacing.lg) {
                Text("选择您感兴趣的活动（可多选）")
                    .font(AppTheme.Fonts.callout)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                LazyVGrid(columns: columns, spacing: AppTheme.Spacing.sm) {
                    ForEach(InterestCategory.allCases, id: \.self) { interest in
                        InterestButton(
                            interest: interest,
                            isSelected: selectedInterests.contains(interest)
                        ) {
                            if selectedInterests.contains(interest) {
                                selectedInterests.remove(interest)
                            } else {
                                selectedInterests.insert(interest)
                            }
                            print("🎯 兴趣选择: \(interest.displayName), 已选择: \(selectedInterests.count)")
                        }
                    }
                }
            }
        }
    }
}

struct InterestButton: View {
    let interest: InterestCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: interest.icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .white : AppTheme.Colors.primary)
                
                Text(interest.displayName)
                    .font(AppTheme.Fonts.callout)
                    .foregroundColor(isSelected ? .white : AppTheme.Colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(AppTheme.Spacing.md)
            .frame(maxWidth: .infinity, minHeight: 80)
            .background(
                isSelected ? AppTheme.Colors.primary : AppTheme.Colors.surface
            )
            .cornerRadius(AppTheme.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .stroke(
                        isSelected ? AppTheme.Colors.primary : AppTheme.Colors.separator,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 生日选择
struct BirthdayStepView: View {
    @Binding var selectedBirthday: Date
    
    var body: some View {
        OnboardingStepContainer(step: .birthday) {
            VStack(spacing: AppTheme.Spacing.xl) {
                Image(systemName: "calendar")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.Colors.primary)
                
                VStack(spacing: AppTheme.Spacing.lg) {
                    Text("请选择您的出生日期")
                        .font(AppTheme.Fonts.headline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    DatePicker(
                        "出生日期",
                        selection: $selectedBirthday,
                        in: Date(timeIntervalSince1970: -2_208_988_800)...Date(), // 1900年到现在
                        displayedComponents: .date
                    )
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .environment(\.locale, Locale(identifier: "zh_CN"))
                    .scaleEffect(1.2)
                    .onChange(of: selectedBirthday) { _ in
                        print("📅 选择生日: \(selectedBirthday)")
                    }
                }
            }
        }
    }
}

// MARK: - 健康提醒设置
struct HealthReminderStepView: View {
    @Binding var dailyReminderEnabled: Bool
    @Binding var reminderTime: Date
    @Binding var healthTipsEnabled: Bool
    
    var body: some View {
        OnboardingStepContainer(step: .healthReminder) {
            VStack(spacing: AppTheme.Spacing.lg) {
                // 每日提醒
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Toggle("每日心情提醒", isOn: $dailyReminderEnabled)
                        .font(AppTheme.Fonts.headline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .toggleStyle(SwitchToggleStyle(tint: AppTheme.Colors.primary))
                    
                    Text("每天提醒您记录心情")
                        .font(AppTheme.Fonts.callout)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    if dailyReminderEnabled {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                            Text("提醒时间")
                                .font(AppTheme.Fonts.callout)
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            
                            DatePicker(
                                "提醒时间",
                                selection: $reminderTime,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .environment(\.locale, Locale(identifier: "zh_CN"))
                        }
                        .padding(.leading, AppTheme.Spacing.lg)
                    }
                }
                .padding(AppTheme.Spacing.cardPadding)
                .background(AppTheme.Colors.surface)
                .cornerRadius(AppTheme.CornerRadius.lg)
                
                // 健康小贴士
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Toggle("健康小贴士", isOn: $healthTipsEnabled)
                        .font(AppTheme.Fonts.headline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .toggleStyle(SwitchToggleStyle(tint: AppTheme.Colors.primary))
                    
                    Text("定期接收心理健康相关的小贴士")
                        .font(AppTheme.Fonts.callout)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                .padding(AppTheme.Spacing.cardPadding)
                .background(AppTheme.Colors.surface)
                .cornerRadius(AppTheme.CornerRadius.lg)
            }
        }
    }
}

// MARK: - 推送通知权限
struct PushNotificationStepView: View {
    @Binding var pushNotificationEnabled: Bool
    
    var body: some View {
        OnboardingStepContainer(step: .pushNotification) {
            VStack(spacing: AppTheme.Spacing.xl) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.Colors.primary)
                
                VStack(spacing: AppTheme.Spacing.lg) {
                    Text("开启通知，不错过任何重要提醒")
                        .font(AppTheme.Fonts.headline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        NotificationFeatureRow(
                            icon: "clock.fill",
                            title: "定时提醒",
                            description: "按时记录心情"
                        )
                        NotificationFeatureRow(
                            icon: "heart.fill",
                            title: "健康贴士",
                            description: "获取心理健康建议"
                        )
                        NotificationFeatureRow(
                            icon: "chart.bar.fill",
                            title: "周报总结",
                            description: "查看心情变化趋势"
                        )
                    }
                    
                    Button("开启通知") {
                        requestNotificationPermission()
                    }
                    .frame(maxWidth: .infinity)
                    .primaryButtonStyle()
                    
                    Button("暂时跳过") {
                        pushNotificationEnabled = false
                        print("🔔 跳过通知设置")
                    }
                    .frame(maxWidth: .infinity)
                    .secondaryButtonStyle()
                }
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                pushNotificationEnabled = granted
                print("🔔 通知权限请求结果: \(granted)")
                if let error = error {
                    print("❌ 通知权限请求错误: \(error)")
                }
            }
        }
    }
}

struct NotificationFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(title)
                    .font(AppTheme.Fonts.callout)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Paywall页面
struct PaywallStepView: View {
    @State private var showingPaywall = false
    
    var body: some View {
        OnboardingStepContainer(step: .paywall) {
            VStack(spacing: AppTheme.Spacing.xl) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 80))
                    .foregroundColor(AppTheme.Colors.warning)
                
                VStack(spacing: AppTheme.Spacing.lg) {
                    Text("解锁专业版功能")
                        .font(AppTheme.Fonts.title1)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .fontWeight(.bold)
                    
                    Text("升级至专业版，享受完整功能")
                        .font(AppTheme.Fonts.headline)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        Text("专业版特权：")
                            .font(AppTheme.Fonts.callout)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .fontWeight(.medium)
                        
                        FeatureRow(icon: "chart.line.uptrend.xyaxis.circle.fill", title: "深度数据分析", description: "心情趋势、稳定性分析")
                        FeatureRow(icon: "paintbrush.fill", title: "更多心情皮肤", description: "解锁所有心情表达皮肤包")
                        FeatureRow(icon: "icloud.fill", title: "云端同步", description: "数据在多设备间同步")
                        FeatureRow(icon: "bell.fill", title: "智能提醒", description: "个性化的健康提醒功能")
                    }
                    
                    Button("升级至专业版") {
                        showingPaywall = true
                        print("💰 显示付费墙")
                    }
                    .frame(maxWidth: .infinity)
                    .primaryButtonStyle()
                    
                    Text("您也可以点击\"开始使用\"跳过付费墙")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
    }
}

// MARK: - 选择按钮组件
struct GenderSelectionButton: View {
    let gender: Gender
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: gender.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : AppTheme.Colors.primary)
                
                Text(gender.displayName)
                    .font(AppTheme.Fonts.headline)
                    .foregroundColor(isSelected ? .white : AppTheme.Colors.textPrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
            .padding(AppTheme.Spacing.cardPadding)
            .background(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.surface)
            .cornerRadius(AppTheme.CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .stroke(
                        isSelected ? AppTheme.Colors.primary : AppTheme.Colors.separator,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SkinPackSelectionButton: View {
    let skinPack: MoodSkinPack
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.md) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(1...5, id: \.self) { mood in
                        Text(skinPack.moodImages[mood] ?? "😊")
                            .font(.system(size: 30))
                    }
                }
                
                Text(skinPack.name)
                    .font(AppTheme.Fonts.headline)
                    .foregroundColor(isSelected ? .white : AppTheme.Colors.textPrimary)
                
                Text(skinPack.description)
                    .font(AppTheme.Fonts.callout)
                    .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(AppTheme.Spacing.cardPadding)
            .frame(maxWidth: .infinity)
            .background(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.surface)
            .cornerRadius(AppTheme.CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .stroke(
                        isSelected ? AppTheme.Colors.primary : AppTheme.Colors.separator,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ColorSchemeSelectionButton: View {
    let colorScheme: ColorSchemeOption
    let isSelected: Bool
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: colorScheme.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : AppTheme.Colors.primary)
                
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(colorScheme.displayName)
                        .font(AppTheme.Fonts.headline)
                        .foregroundColor(isSelected ? .white : AppTheme.Colors.textPrimary)
                    
                    Text(description)
                        .font(AppTheme.Fonts.callout)
                        .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
            .padding(AppTheme.Spacing.cardPadding)
            .background(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.surface)
            .cornerRadius(AppTheme.CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .stroke(
                        isSelected ? AppTheme.Colors.primary : AppTheme.Colors.separator,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview("Welcome Step") {
    WelcomeStepView()
}

#Preview("Gender Selection") {
    GenderSelectionStepView(selectedGender: .constant(.female))
}

#Preview("Paywall Step") {
    PaywallStepView()
} 