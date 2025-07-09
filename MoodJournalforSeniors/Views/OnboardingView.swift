import SwiftUI

struct OnboardingView: View {
    @StateObject private var onboardingData = OnboardingData()
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()
                    .onAppear {
                        print("🔄 OnboardingView 出现，当前步骤: \(onboardingData.currentStep.title)")
                    }
                
                VStack(spacing: 0) {
                    // 进度条（Splash页面和付费墙页面不显示）
                    if onboardingData.currentStep != .welcome && onboardingData.currentStep != .paywall {
                        ProgressView(value: onboardingData.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: AppTheme.Colors.primary))
                            .frame(height: 4)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .padding(.top, AppTheme.Spacing.sm)
                        
                        // 步骤指示器
                        HStack {
                            Text("第 \(onboardingData.currentStep.rawValue + 1) 步，共 \(OnboardingStep.allCases.count) 步")
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.top, AppTheme.Spacing.sm)
                    }
                    
                    // 当前步骤内容
                    currentStepView
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    
                    // 导航按钮（Splash页面和付费墙页面不显示）
                    if onboardingData.currentStep != .welcome && onboardingData.currentStep != .paywall {
                        navigationButtons
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .padding(.bottom, AppTheme.Spacing.lg)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .animation(.easeInOut(duration: 0.3), value: onboardingData.currentStep)
    }
    
    @ViewBuilder
    private var currentStepView: some View {
        switch onboardingData.currentStep {
        case .welcome:
            WelcomeStepView()
                .environmentObject(onboardingData)
        case .gender:
            GenderSelectionStepView(selectedGender: $onboardingData.selectedGender)
        case .moodSkinSelection:
            MoodSkinSelectionStepView(selectedSkinPack: $onboardingData.selectedMoodSkinPack)
        case .colorScheme:
            ColorSchemeStepView(selectedColorScheme: $onboardingData.selectedColorScheme)
        case .interests:
            InterestsStepView(selectedInterests: $onboardingData.selectedInterests)
        case .birthday:
            BirthdayStepView(selectedBirthday: $onboardingData.selectedBirthday)
        case .healthReminder:
            HealthReminderStepView(
                dailyReminderEnabled: $onboardingData.dailyReminderEnabled,
                reminderTime: $onboardingData.reminderTime,
                healthTipsEnabled: $onboardingData.healthTipsEnabled
            )
        case .pushNotification:
            PushNotificationStepView(pushNotificationEnabled: $onboardingData.pushNotificationEnabled)
        case .paywall:
            PaywallView()
                .environmentObject(onboardingData)
                .environmentObject(dataManager)
        }
    }
    
    private var navigationButtons: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // 返回按钮
            if onboardingData.currentStep != .welcome {
                Button("返回") {
                    onboardingData.moveToPrevious()
                }
                .frame(maxWidth: .infinity)
                .secondaryButtonStyle()
            }
            
            // 继续/完成按钮
            Button(onboardingData.currentStep == .paywall ? "开始使用" : "继续") {
                print("🔘 按钮被点击，当前步骤: \(onboardingData.currentStep)")
                print("🔘 canMoveNext: \(onboardingData.canMoveNext)")
                
                if onboardingData.currentStep == .paywall {
                    print("🔘 调用completeOnboarding()")
                    completeOnboarding()
                } else {
                    print("🔘 调用moveToNext()")
                    onboardingData.moveToNext()
                }
            }
            .frame(maxWidth: .infinity)
            .primaryButtonStyle()
            .disabled(!onboardingData.canMoveNext)
        }
    }
    
    private func completeOnboarding() {
        print("✅ 开始完成Onboarding流程")
        
        // 保存Onboarding数据到DataManager
        saveOnboardingData()
        
        // 标记Onboarding为已完成
        UserDefaults.standard.set(true, forKey: "OnboardingCompleted")
        
        onboardingData.completeOnboarding()
        
        // 发送通知给ContentView
        NotificationCenter.default.post(name: NSNotification.Name("OnboardingCompleted"), object: nil)
        
        print("📢 发送Onboarding完成通知")
        
        // 尝试dismiss（可能不会工作，主要依赖NotificationCenter）
        dismiss()
    }
    
    private func saveOnboardingData() {
        print("💾 开始保存Onboarding数据")
        
        // 更新用户配置
        var profile = dataManager.userProfile
        profile.gender = onboardingData.selectedGender ?? .other
        profile.selectedMoodSkinPack = onboardingData.selectedMoodSkinPack ?? "default_emoji" // 设置默认值
        profile.preferredColorScheme = onboardingData.selectedColorScheme.rawValue
        profile.interestedCategories = onboardingData.selectedInterests.isEmpty ? 
            ["family"] : Array(onboardingData.selectedInterests.map { $0.rawValue }) // 设置默认兴趣
        profile.birthday = onboardingData.selectedBirthday
        profile.enableDailyReminder = onboardingData.dailyReminderEnabled
        profile.dailyReminderTime = onboardingData.reminderTime
        profile.enableHealthTips = onboardingData.healthTipsEnabled
        
        // 调试日志
        print("💾 保存的数据详情：")
        print("  - 性别: \(profile.gender?.displayName ?? "未设置")")
        print("  - 心情皮肤包: \(profile.selectedMoodSkinPack ?? "未设置")")
        print("  - 颜色主题: \(profile.preferredColorScheme)")
        print("  - 兴趣类别数量: \(profile.interestedCategories.count)")
        print("  - 兴趣类别: \(profile.interestedCategories)")
        print("  - 生日: \(profile.birthday ?? Date())")
        print("  - 每日提醒: \(profile.enableDailyReminder)")
        print("  - 健康贴士: \(profile.enableHealthTips)")
        print("  - Onboarding完成状态: \(profile.isOnboardingCompleted)")
        
        dataManager.updateUserProfile(profile)
        print("💾 保存Onboarding数据到DataManager完成")
    }
}

// MARK: - 步骤视图基础组件
struct OnboardingStepContainer<Content: View>: View {
    let step: OnboardingStep
    let content: Content
    
    init(step: OnboardingStep, @ViewBuilder content: () -> Content) {
        self.step = step
        self.content = content()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.xl) {
                // 标题区域
                VStack(spacing: AppTheme.Spacing.md) {
                    Text(step.title)
                        .font(AppTheme.Fonts.title1)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text(step.subtitle)
                        .font(AppTheme.Fonts.body)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                }
                .padding(.top, AppTheme.Spacing.xl)
                
                // 内容区域
                content
                
                Spacer(minLength: 100) // 为底部按钮留出空间
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(DataManager())
} 