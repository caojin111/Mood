import SwiftUI

// MARK: - 主题模型
struct ThemeModel: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let primaryColor: String        // 主色调的十六进制值
    let backgroundImage: String?    // 背景图片名称（可选）
    let isUnlocked: Bool           // 是否已解锁
    let price: Int                 // 价格（0为免费）
    let previewImage: String       // 预览图片名称
    
    // 获取Color对象
    var primarySwiftUIColor: Color {
        Color(hex: primaryColor) ?? Color.green
    }
    
    // 静态主题数据
    static let availableThemes: [ThemeModel] = [
        // 默认主题（浅墨绿）
        ThemeModel(
            id: "default",
            name: "清新绿意",
            description: "经典的浅墨绿色主题，清新自然",
            primaryColor: "#66B399",
            backgroundImage: nil,
            isUnlocked: true,
            price: 0,
            previewImage: "theme_default"
        ),
        
        // 温暖橙色主题
        ThemeModel(
            id: "warm_orange",
            name: "温暖夕阳",
            description: "温暖的橙色主题，如夕阳般舒适",
            primaryColor: "#E67E22",
            backgroundImage: nil,
            isUnlocked: true,
            price: 0,
            previewImage: "theme_orange"
        ),
        
        // 宁静蓝色主题
        ThemeModel(
            id: "calm_blue",
            name: "宁静海洋",
            description: "宁静的蓝色主题，如大海般平静",
            primaryColor: "#3498DB",
            backgroundImage: nil,
            isUnlocked: true,
            price: 0,
            previewImage: "theme_blue"
        ),
        
        // 优雅紫色主题
        ThemeModel(
            id: "elegant_purple",
            name: "优雅薰衣草",
            description: "优雅的紫色主题，如薰衣草般迷人",
            primaryColor: "#9B59B6",
            backgroundImage: nil,
            isUnlocked: false,
            price: 0,
            previewImage: "theme_purple"
        ),
        
        // 活力粉色主题
        ThemeModel(
            id: "vibrant_pink",
            name: "活力樱花",
            description: "活力的粉色主题，如樱花般浪漫",
            primaryColor: "#E91E63",
            backgroundImage: nil,
            isUnlocked: false,
            price: 0,
            previewImage: "theme_pink"
        ),
        
        // 深色主题
        ThemeModel(
            id: "dark_theme",
            name: "深邃夜空",
            description: "深色主题，护眼模式",
            primaryColor: "#2C3E50",
            backgroundImage: nil,
            isUnlocked: false,
            price: 0,
            previewImage: "theme_dark"
        )
    ]
}

// MARK: - Color扩展，支持十六进制颜色
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 