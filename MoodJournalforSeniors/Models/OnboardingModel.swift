import Foundation

// MARK: - Onboarding步骤枚举
enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case gender
    case moodSkinSelection
    case colorScheme
    case interests
    case birthday
    case healthReminder
    case pushNotification
    case paywall
    
    var title: String {
        switch self {
        case .welcome:
            return "心情日记"
        case .gender:
            return "请选择您的性别"
        case .moodSkinSelection:
            return "选择您喜欢的心情皮肤"
        case .colorScheme:
            return "选择显示模式"
        case .interests:
            return "您的兴趣爱好"
        case .birthday:
            return "请填写您的出生日期"
        case .healthReminder:
            return "健康提醒设置"
        case .pushNotification:
            return "开启消息通知"
        case .paywall:
            return "升级至专业版"
        }
    }
    
    var subtitle: String {
        switch self {
        case .welcome:
            return "Made by LazyCat"
        case .gender:
            return "这将帮助我们为您提供更好的服务"
        case .moodSkinSelection:
            return "选择您最喜欢的心情表达方式"
        case .colorScheme:
            return "选择适合您的界面风格"
        case .interests:
            return "告诉我们您平时喜欢什么活动"
        case .birthday:
            return "这将帮助我们提供更个性化的服务"
        case .healthReminder:
            return "设置日常健康提醒"
        case .pushNotification:
            return "及时收到重要的健康提醒"
        case .paywall:
            return "解锁更多功能，享受完整的心情日记体验"
        }
    }
}

// Gender枚举定义在UserProfile.swift中

// MARK: - 颜色方案
enum ColorSchemeOption: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .light:
            return "浅色模式"
        case .dark:
            return "深色模式"
        case .system:
            return "跟随系统"
        }
    }
    
    var icon: String {
        switch self {
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        case .system:
            return "circle.lefthalf.filled"
        }
    }
}

// InterestCategory枚举定义在UserProfile.swift中

// MARK: - Onboarding数据容器
class OnboardingData: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var selectedGender: Gender?
    @Published var selectedMoodSkinPack: String?
    @Published var selectedColorScheme: ColorSchemeOption = .system
    @Published var selectedInterests: Set<InterestCategory> = []
    @Published var selectedBirthday: Date = Date()
    @Published var dailyReminderEnabled: Bool = true
    @Published var reminderTime: Date = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
    @Published var healthTipsEnabled: Bool = true
    @Published var pushNotificationEnabled: Bool = true
    
    var progress: Double {
        return Double(currentStep.rawValue) / Double(OnboardingStep.allCases.count - 1)
    }
    
    var canMoveNext: Bool {
        switch currentStep {
        case .welcome:
            return true
        case .gender:
            return selectedGender != nil
        case .moodSkinSelection:
            return selectedMoodSkinPack != nil
        case .colorScheme:
            return true
        case .interests:
            return selectedInterests.count > 0
        case .birthday:
            return true
        case .healthReminder:
            return true
        case .pushNotification:
            return true
        case .paywall:
            return true
        }
    }
    
    func moveToNext() {
        guard canMoveNext else { return }
        
        if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            currentStep = nextStep
            print("📋 移动到下一步: \(nextStep.title)")
        }
    }
    
    func moveToPrevious() {
        if let previousStep = OnboardingStep(rawValue: currentStep.rawValue - 1) {
            currentStep = previousStep
            print("📋 返回上一步: \(previousStep.title)")
        }
    }
    
    func completeOnboarding() {
        print("✅ 完成Onboarding设置")
        print("  - 性别: \(selectedGender?.displayName ?? "未选择")")
        print("  - 心情皮肤: \(selectedMoodSkinPack ?? "未选择")")
        print("  - 显示模式: \(selectedColorScheme.displayName)")
        print("  - 兴趣数量: \(selectedInterests.count)")
        print("  - 生日: \(selectedBirthday)")
        print("  - 每日提醒: \(dailyReminderEnabled)")
        print("  - 健康贴士: \(healthTipsEnabled)")
        print("  - 推送通知: \(pushNotificationEnabled)")
    }
} 