import Foundation

// MARK: - 活动分类枚举
enum ActivityCategory: String, CaseIterable, Codable {
    case exercise = "运动"
    case social = "社交"
    case hobby = "爱好"
    case family = "家庭"
    case health = "健康"
    case entertainment = "娱乐"
    case work = "工作"
    case custom = "自定义"
    
    var icon: String {
        switch self {
        case .exercise: return "figure.walk"
        case .social: return "person.2"
        case .hobby: return "paintbrush"
        case .family: return "house"
        case .health: return "heart"
        case .entertainment: return "tv"
        case .work: return "briefcase"
        case .custom: return "star"
        }
    }
    
    var color: String {
        switch self {
        case .exercise: return "category_exercise"
        case .social: return "category_social"
        case .hobby: return "category_hobby"
        case .family: return "category_family"
        case .health: return "category_health"
        case .entertainment: return "category_entertainment"
        case .work: return "category_work"
        case .custom: return "category_custom"
        }
    }
}

// MARK: - 活动模型
struct Activity: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let category: ActivityCategory
    let isCustom: Bool
    let customIcon: String? // 自定义图标名称
    
    init(name: String, category: ActivityCategory, isCustom: Bool = false, customIcon: String? = nil) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.isCustom = isCustom
        self.customIcon = customIcon
        
        print("🎯 创建活动: \(name) - \(category.rawValue)" + (customIcon != nil ? " 图标: \(customIcon!)" : ""))
    }
    
    // 获取活动图标
    var icon: String {
        return customIcon ?? category.icon
    }
}

// MARK: - 预定义活动数据
extension Activity {
    static let predefinedActivities: [Activity] = [
        // 运动类
        Activity(name: "散步", category: .exercise),
        Activity(name: "太极", category: .exercise),
        Activity(name: "游泳", category: .exercise),
        Activity(name: "骑车", category: .exercise),
        
        // 社交类
        Activity(name: "与朋友聊天", category: .social),
        Activity(name: "参加聚会", category: .social),
        Activity(name: "社区活动", category: .social),
        Activity(name: "志愿服务", category: .social),
        
        // 爱好类
        Activity(name: "阅读", category: .hobby),
        Activity(name: "书法", category: .hobby),
        Activity(name: "绘画", category: .hobby),
        Activity(name: "园艺", category: .hobby),
        Activity(name: "烹饪", category: .hobby),
        
        // 家庭类
        Activity(name: "与家人聊天", category: .family),
        Activity(name: "带孙子", category: .family),
        Activity(name: "家务", category: .family),
        Activity(name: "家庭聚餐", category: .family),
        
        // 健康类
        Activity(name: "体检", category: .health),
        Activity(name: "吃药", category: .health),
        Activity(name: "按摩", category: .health),
        Activity(name: "休息", category: .health),
        
        // 娱乐类
        Activity(name: "看电视", category: .entertainment),
        Activity(name: "听音乐", category: .entertainment),
        Activity(name: "看电影", category: .entertainment),
        Activity(name: "打牌", category: .entertainment)
    ]
} 