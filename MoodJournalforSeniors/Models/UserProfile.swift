import Foundation

// MARK: - 性别枚举
enum Gender: String, CaseIterable, Codable {
    case male = "男"
    case female = "女"
    case other = "其他"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .male:
            return "person.fill"
        case .female:
            return "person.fill"
        case .other:
            return "person.2.fill"
        }
    }
}

// MARK: - 心情风格枚举
enum MoodStyle: String, CaseIterable, Codable {
    case emoji = "表情符号"
    case simple = "简约风格"
    case colorful = "彩色风格"
    case classic = "经典风格"
    
    var previewIcon: String {
        switch self {
        case .emoji: return "😊"
        case .simple: return "○"
        case .colorful: return "●"
        case .classic: return "★"
        }
    }
}

// MARK: - 颜色主题枚举
enum ColorScheme: String, CaseIterable, Codable {
    case lightGreen = "浅墨绿"
    case warmGray = "暖灰色"
    case softBlue = "柔和蓝"
    case classic = "经典色"
    
    var primaryColor: String {
        switch self {
        case .lightGreen: return "primary_light_green"
        case .warmGray: return "primary_warm_gray"
        case .softBlue: return "primary_soft_blue"
        case .classic: return "primary_classic"
        }
    }
}

// MARK: - 订阅类型枚举
enum SubscriptionType: String, CaseIterable, Codable {
    case monthly = "月度订阅"
    case yearly = "年度订阅"
    case lifetime = "终身订阅"
}

// MARK: - 兴趣分类枚举
enum InterestCategory: String, CaseIterable, Codable {
    case exercise = "运动健身"
    case reading = "阅读学习"
    case art = "艺术创作"
    case cooking = "烹饪美食"
    case gardening = "园艺花草"
    case music = "音乐娱乐"
    case travel = "旅游出行"
    case family = "家庭生活"
    case health = "健康养生"
    case social = "社交活动"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .exercise: return "figure.walk"
        case .reading: return "book.fill"
        case .art: return "paintbrush"
        case .cooking: return "frying.pan"
        case .gardening: return "leaf.fill"
        case .music: return "music.note"
        case .travel: return "airplane"
        case .family: return "house.fill"
        case .health: return "heart.fill"
        case .social: return "person.2.fill"
        }
    }
}

// MARK: - 用户配置模型
struct UserProfile: Identifiable, Codable {
    let id: UUID
    var gender: Gender?
    var birthday: Date?
    var preferredMoodStyle: MoodStyle
    var preferredColorScheme: String // 使用String类型以兼容OnboardingData
    var selectedMoodSkinPack: String? // 添加选择的心情皮肤包
    var interestedCategories: [String] // 使用String数组以兼容OnboardingData
    var isPremium: Bool
    var subscriptionType: SubscriptionType?
    var createdAt: Date
    var updatedAt: Date
    
    // 设置提醒相关
    var enableDailyReminder: Bool
    var dailyReminderTime: Date
    var enableWeeklyReview: Bool
    var enableHealthTips: Bool
    
    init(gender: Gender? = nil,
         birthday: Date? = nil,
         preferredMoodStyle: MoodStyle = .emoji,
         preferredColorScheme: String = "system",
         selectedMoodSkinPack: String? = nil,
         interestedCategories: [String] = [],
         isPremium: Bool = false,
         subscriptionType: SubscriptionType? = nil) {
        
        self.id = UUID()
        self.gender = gender
        self.birthday = birthday
        self.preferredMoodStyle = preferredMoodStyle
        self.preferredColorScheme = preferredColorScheme
        self.selectedMoodSkinPack = selectedMoodSkinPack
        self.interestedCategories = interestedCategories
        self.isPremium = isPremium
        self.subscriptionType = subscriptionType
        self.createdAt = Date()
        self.updatedAt = Date()
        
        // 默认提醒设置
        self.enableDailyReminder = true
        self.dailyReminderTime = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
        self.enableWeeklyReview = true
        self.enableHealthTips = true
        
        print("👤 创建用户配置: 心情风格 \(preferredMoodStyle.rawValue), 颜色主题 \(preferredColorScheme)")
    }
    
    // 计算年龄
    var age: Int? {
        guard let birthday = birthday else { return nil }
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: Date())
        return ageComponents.year
    }
    
    // 用户是否已完成初始设置
    var isOnboardingCompleted: Bool {
        return gender != nil && !interestedCategories.isEmpty && selectedMoodSkinPack != nil
    }
} 