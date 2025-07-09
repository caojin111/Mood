import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var onboardingData: OnboardingData
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedPlan: SubscriptionPlan = .yearly
    @State private var isPurchasing = false
    @State private var showingRestorePurchases = false
    @State private var showCloseButton = false
    
    var body: some View {
        // 全屏显示，不使用 NavigationView
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // 标题区域
                    headerSection
                    
                    // 功能对比区域
                    featuresSection
                    
                    // 订阅计划选择
                    subscriptionPlansSection
                    
                    // 购买按钮
                    purchaseButton
                    
                    // 恢复购买和条款
                    footerSection
                }
                .padding(AppTheme.Spacing.lg)
                .padding(.top, 60) // 为顶部安全区域留出空间
            }
            
            // 延时显示的关闭按钮
            VStack {
                HStack {
                    Spacer()
                    
                    if showCloseButton {
                        Button(action: {
                            print("❌ 跳过付费墙，继续 Onboarding")
                            // 触发完成 Onboarding 流程
                            completeOnboarding()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        .padding(.trailing, AppTheme.Spacing.lg)
                        .padding(.top, AppTheme.Spacing.lg)
                        .transition(.opacity.combined(with: .scale))
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            print("🎬 PaywallView 出现，3秒后显示关闭按钮")
            // 延时3秒显示关闭按钮
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showCloseButton = true
                }
                print("✅ 显示关闭按钮")
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.warning)
            
            Text("解锁专业版功能")
                .font(AppTheme.Fonts.title1)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("享受完整的心情日记体验")
                .font(AppTheme.Fonts.body)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("专业版功能")
                .font(AppTheme.Fonts.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .fontWeight(.semibold)
            
            VStack(spacing: AppTheme.Spacing.sm) {
                PaywallFeatureRow(
                    icon: "chart.line.uptrend.xyaxis.circle.fill",
                    title: "深度数据分析",
                    description: "心情趋势分析、稳定性指标、详细统计报告",
                    isIncluded: true
                )
                
                PaywallFeatureRow(
                    icon: "paintbrush.fill",
                    title: "所有心情皮肤包",
                    description: "解锁全部6个精美皮肤包，个性化心情表达",
                    isIncluded: true
                )
                
                PaywallFeatureRow(
                    icon: "icloud.fill", 
                    title: "云端同步",
                    description: "数据在iPhone、iPad等设备间无缝同步",
                    isIncluded: true
                )
                
                PaywallFeatureRow(
                    icon: "bell.fill",
                    title: "智能提醒",
                    description: "个性化健康提醒、心情分析报告推送",
                    isIncluded: true
                )
                
                PaywallFeatureRow(
                    icon: "person.2.fill",
                    title: "家庭共享",
                    description: "与家人分享使用，关注彼此的心理健康",
                    isIncluded: true
                )
                
                PaywallFeatureRow(
                    icon: "mic.fill",
                    title: "语音日记",
                    description: "支持录制语音日记，更方便的记录方式",
                    isIncluded: true
                )
            }
        }
        .padding(AppTheme.Spacing.cardPadding)
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.lg)
    }
    
    private var subscriptionPlansSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Text("选择订阅计划")
                .font(AppTheme.Fonts.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .fontWeight(.semibold)
            
            VStack(spacing: AppTheme.Spacing.sm) {
                SubscriptionPlanCard(
                    plan: .lifetime,
                    isSelected: selectedPlan == .lifetime,
                    isPopular: true
                ) {
                    selectedPlan = .lifetime
                    print("💰 选择终身订阅")
                }
                
                SubscriptionPlanCard(
                    plan: .yearly,
                    isSelected: selectedPlan == .yearly,
                    isPopular: false
                ) {
                    selectedPlan = .yearly
                    print("💰 选择年度订阅")
                }
                
                SubscriptionPlanCard(
                    plan: .monthly,
                    isSelected: selectedPlan == .monthly,
                    isPopular: false
                ) {
                    selectedPlan = .monthly
                    print("💰 选择月度订阅")
                }
            }
        }
    }
    
    private var purchaseButton: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Button(selectedPlan.purchaseButtonText) {
                purchaseSubscription()
            }
            .frame(maxWidth: .infinity)
            .primaryButtonStyle()
            .disabled(isPurchasing)
            
            if selectedPlan == .yearly || selectedPlan == .monthly {
                Text("7天免费试用，随时可取消")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var footerSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Button("恢复购买") {
                restorePurchases()
            }
            .foregroundColor(AppTheme.Colors.primary)
            .font(AppTheme.Fonts.callout)
            
            VStack(spacing: AppTheme.Spacing.xs) {
                Text("购买即表示同意")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textTertiary)
                
                HStack(spacing: AppTheme.Spacing.xs) {
                    Button("服务条款") {
                        print("📋 显示服务条款")
                    }
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.primary)
                    
                    Text("和")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.textTertiary)
                    
                    Button("隐私政策") {
                        print("🔒 显示隐私政策")
                    }
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.primary)
                }
            }
        }
    }
    
    private func purchaseSubscription() {
        isPurchasing = true
        print("💰 开始购买订阅: \(selectedPlan.displayName)")
        
        // TODO: 实现StoreKit购买逻辑
        // 这里暂时模拟购买流程
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isPurchasing = false
            // 模拟购买成功
            print("✅ 购买成功")
            completeOnboarding()
        }
    }
    
    private func completeOnboarding() {
        print("✅ 从付费墙完成 Onboarding 流程")
        
        // 保存Onboarding数据
        saveOnboardingData()
        
        // 标记Onboarding为已完成
        UserDefaults.standard.set(true, forKey: "OnboardingCompleted")
        
        onboardingData.completeOnboarding()
        
        // 发送通知给ContentView
        NotificationCenter.default.post(name: NSNotification.Name("OnboardingCompleted"), object: nil)
        
        print("📢 发送Onboarding完成通知")
    }
    
    private func saveOnboardingData() {
        print("💾 从付费墙保存 Onboarding 数据")
        
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
        print("💾 从付费墙保存 Onboarding 数据到 DataManager 完成")
    }
    
    private func restorePurchases() {
        showingRestorePurchases = true
        print("🔄 恢复购买")
        
        // TODO: 实现StoreKit恢复购买逻辑
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            showingRestorePurchases = false
            print("✅ 恢复购买完成")
        }
    }
}

// MARK: - 订阅计划枚举
enum SubscriptionPlan: String, CaseIterable {
    case monthly = "monthly"
    case yearly = "yearly"
    case lifetime = "lifetime"
    
    var displayName: String {
        switch self {
        case .monthly:
            return "月度订阅"
        case .yearly:
            return "年度订阅"
        case .lifetime:
            return "终身买断"
        }
    }
    
    var price: String {
        switch self {
        case .monthly:
            return "¥12"
        case .yearly:
            return "¥88"
        case .lifetime:
            return "¥268"
        }
    }
    
    var originalPrice: String? {
        switch self {
        case .monthly:
            return nil
        case .yearly:
            return "¥144"
        case .lifetime:
            return nil
        }
    }
    
    var period: String {
        switch self {
        case .monthly:
            return "每月"
        case .yearly:
            return "每年"
        case .lifetime:
            return "一次性付费"
        }
    }
    
    var savings: String? {
        switch self {
        case .monthly:
            return nil
        case .yearly:
            return "节省39%"
        case .lifetime:
            return "永久使用"
        }
    }
    
    var purchaseButtonText: String {
        switch self {
        case .monthly:
            return "开始7天免费试用"
        case .yearly:
            return "开始7天免费试用"
        case .lifetime:
            return "立即购买 \(price)"
        }
    }
}

// MARK: - 功能行组件
struct PaywallFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let isIncluded: Bool
    
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
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: isIncluded ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(isIncluded ? AppTheme.Colors.success : AppTheme.Colors.error)
        }
    }
}

// MARK: - 订阅计划卡片
struct SubscriptionPlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let isPopular: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.sm) {
                // 推荐标签
                if isPopular {
                    HStack {
                        Spacer()
                        Text("推荐")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, AppTheme.Spacing.sm)
                            .padding(.vertical, AppTheme.Spacing.xs)
                            .background(AppTheme.Colors.warning)
                            .cornerRadius(AppTheme.CornerRadius.sm)
                        Spacer()
                    }
                    .offset(y: -8)
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text(plan.displayName)
                            .font(AppTheme.Fonts.headline)
                            .foregroundColor(isSelected ? .white : AppTheme.Colors.textPrimary)
                            .fontWeight(.semibold)
                        
                        Text(plan.period)
                            .font(AppTheme.Fonts.callout)
                            .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                        HStack(spacing: AppTheme.Spacing.xs) {
                            if let originalPrice = plan.originalPrice {
                                Text(originalPrice)
                                    .font(AppTheme.Fonts.callout)
                                    .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
                                    .strikethrough()
                            }
                            
                            Text(plan.price)
                                .font(AppTheme.Fonts.headline)
                                .foregroundColor(isSelected ? .white : AppTheme.Colors.textPrimary)
                                .fontWeight(.bold)
                        }
                        
                        if let savings = plan.savings {
                            Text(savings)
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(isSelected ? .white : AppTheme.Colors.success)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .padding(AppTheme.Spacing.cardPadding)
            .background(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.surface)
            .cornerRadius(AppTheme.CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .stroke(
                        isSelected ? AppTheme.Colors.primary : (isPopular ? AppTheme.Colors.warning : AppTheme.Colors.separator),
                        lineWidth: isSelected || isPopular ? 2 : 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PaywallView()
        .environmentObject(OnboardingData())
        .environmentObject(DataManager())
} 