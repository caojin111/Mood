import SwiftUI

// MARK: - 心情图片皮肤包模型
struct MoodSkinPack: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let category: String              // 分类：如"动物"、"表情"、"自然"等
    let moodImages: [Int: String]     // 键为心情等级(1-5)，值为图片名称
    let previewImage: String          // 商店展示缩略图
    let isPremium: Bool              // 是否为付费皮肤包
    let price: String?               // 价格文本，如"¥6"
    var isUnlocked: Bool            // 是否已解锁
    
    // 获取指定心情等级的表情符号（作为默认图片）
    func getMoodEmoji(for level: Int) -> String {
        switch level {
        case 1: return "😢"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "😊"
        case 5: return "😄"
        default: return "😐"
        }
    }
    
    // 获取指定心情等级的图片名称
    func getMoodImageName(for level: Int) -> String {
        return moodImages[level] ?? "\(id)_mood_\(level)"
    }
    
    // 静态皮肤包数据
    static let availablePacks: [MoodSkinPack] = [
        // 默认表情包（免费）
        MoodSkinPack(
            id: "default_emoji",
            name: "经典表情",
            description: "传统的表情符号，简洁明了",
            category: "表情",
            moodImages: [
                1: "😢",    // 很难过
                2: "😕",    // 难过
                3: "😐",    // 一般
                4: "😊",    // 开心
                5: "😄"     // 很开心
            ],
            previewImage: "pack_default_preview",
            isPremium: false,
            price: nil,
            isUnlocked: true
        ),
        
        // 可爱动物包（免费试用）
        MoodSkinPack(
            id: "cute_animals",
            name: "可爱动物",
            description: "萌萌的小动物陪您记录心情",
            category: "动物",
            moodImages: [
                1: "😿",    // 哭泣的猫
                2: "🐶",    // 小狗
                3: "🐼",    // 熊猫
                4: "🐰",    // 兔子
                5: "🦊"     // 狐狸
            ],
            previewImage: "pack_animals_preview",
            isPremium: false,
            price: nil,
            isUnlocked: true
        ),
        
        // 自然风光包（付费）
        MoodSkinPack(
            id: "nature_scenes",
            name: "自然风光",
            description: "美丽的自然景色，感受大自然的力量",
            category: "自然",
            moodImages: [
                1: "⛈️",    // 暴风雨
                2: "☁️",    // 阴天
                3: "🌊",    // 海浪
                4: "☀️",    // 阳光
                5: "🌈"     // 彩虹
            ],
            previewImage: "pack_nature_preview",
            isPremium: true,
            price: "¥6",
            isUnlocked: false
        ),
        
        // 美食心情包（付费）
        MoodSkinPack(
            id: "food_mood",
            name: "美食心情",
            description: "用美食来表达您的心情",
            category: "美食",
            moodImages: [
                1: "🥒",    // 黄瓜（苦涩）
                2: "🍋",    // 柠檬（酸涩）
                3: "🍞",    // 面包（平淡）
                4: "🍰",    // 蛋糕（甜蜜）
                5: "🍭"     // 棒棒糖（超甜）
            ],
            previewImage: "pack_food_preview",
            isPremium: true,
            price: "¥6",
            isUnlocked: false
        ),
        
        // 花朵心情包（付费）
        MoodSkinPack(
            id: "flowers",
            name: "花朵物语",
            description: "用花朵的美丽表达内心的感受",
            category: "自然",
            moodImages: [
                1: "🥀",    // 枯萎的花
                2: "🌹",    // 玫瑰花蕾
                3: "🌼",    // 雏菊
                4: "🌻",    // 向日葵
                5: "🌺"     // 盛开的花
            ],
            previewImage: "pack_flowers_preview",
            isPremium: true,
            price: "¥8",
            isUnlocked: false
        ),
        
        // 天气心情包（付费）
        MoodSkinPack(
            id: "weather",
            name: "天气心情",
            description: "像天气一样变化的心情",
            category: "天气",
            moodImages: [
                1: "⛈️",    // 雷暴
                2: "🌧️",    // 下雨
                3: "☁️",    // 多云
                4: "⛅",    // 晴间多云
                5: "☀️"     // 晴天
            ],
            previewImage: "pack_weather_preview",
            isPremium: true,
            price: "¥6",
            isUnlocked: false
        )
    ]
}

// MARK: - 皮肤包分类
enum SkinPackCategory: String, CaseIterable {
    case all = "全部"
    case emoji = "表情"
    case animals = "动物"
    case nature = "自然"
    case food = "美食"
    case weather = "天气"
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .emoji: return "face.smiling"
        case .animals: return "pawprint"
        case .nature: return "leaf"
        case .food: return "fork.knife"
        case .weather: return "cloud.sun"
        }
    }
} 