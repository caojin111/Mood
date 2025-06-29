import SwiftUI

// MARK: - 应用主题配置
struct AppTheme {
    
    // MARK: - 颜色配置
    struct Colors {
        // 主色调 - 浅墨绿色系
        static let primary = Color(red: 0.4, green: 0.7, blue: 0.6)       // 浅墨绿
        static let primaryDark = Color(red: 0.3, green: 0.6, blue: 0.5)   // 深一点的墨绿
        static let primaryLight = Color(red: 0.6, green: 0.8, blue: 0.7)  // 更浅的墨绿
        
        // 背景色
        static let background = Color(UIColor.systemGroupedBackground)
        static let cardBackground = Color(UIColor.secondarySystemGroupedBackground)
        static let surface = Color(UIColor.systemBackground)
        
        // 文字颜色
        static let textPrimary = Color(UIColor.label)
        static let textSecondary = Color(UIColor.secondaryLabel)
        static let textTertiary = Color(UIColor.tertiaryLabel)
        
        // 心情颜色
        static let moodVeryBad = Color(red: 0.9, green: 0.7, blue: 0.7)    // 很淡的红色
        static let moodBad = Color(red: 0.9, green: 0.8, blue: 0.6)        // 淡橙色
        static let moodNeutral = Color(red: 0.9, green: 0.9, blue: 0.7)    // 淡黄色
        static let moodGood = Color(red: 0.7, green: 0.9, blue: 0.8)       // 浅绿色
        static let moodVeryGood = Color(red: 0.6, green: 0.8, blue: 0.7)   // 墨绿色
        
        // 功能色
        static let success = Color(red: 0.2, green: 0.7, blue: 0.3)
        static let warning = Color(red: 0.9, green: 0.6, blue: 0.2)
        static let error = Color(red: 0.8, green: 0.3, blue: 0.3)
        static let info = Color(red: 0.3, green: 0.6, blue: 0.8)
        
        // 分割线
        static let separator = Color(UIColor.separator)
        
        // 获取心情颜色
        static func moodColor(for level: Int) -> Color {
            switch level {
            case 1: return moodVeryBad
            case 2: return moodBad
            case 3: return moodNeutral
            case 4: return moodGood
            case 5: return moodVeryGood
            default: return moodNeutral
            }
        }
    }
    
    // MARK: - 字体配置 (适老化)
    struct Fonts {
        // 标题字体
        static let largeTitle = Font.system(size: 32, weight: .bold, design: .rounded)
        static let title1 = Font.system(size: 26, weight: .semibold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
        static let title3 = Font.system(size: 20, weight: .medium, design: .rounded)
        
        // 正文字体
        static let headline = Font.system(size: 18, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 17, weight: .regular, design: .rounded)
        static let bodyBold = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let callout = Font.system(size: 16, weight: .regular, design: .rounded)
        
        // 辅助字体
        static let subheadline = Font.system(size: 15, weight: .regular, design: .rounded)
        static let footnote = Font.system(size: 14, weight: .regular, design: .rounded)
        static let caption = Font.system(size: 13, weight: .regular, design: .rounded)
        
        // 按钮字体
        static let buttonLarge = Font.system(size: 18, weight: .semibold, design: .rounded)
        static let buttonMedium = Font.system(size: 16, weight: .medium, design: .rounded)
        static let buttonSmall = Font.system(size: 14, weight: .medium, design: .rounded)
    }
    
    // MARK: - 间距配置
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 40
        
        // 适老化间距 - 稍微大一些
        static let cardPadding: CGFloat = 20
        static let sectionSpacing: CGFloat = 24
        static let buttonHeight: CGFloat = 52  // 更大的按钮高度
    }
    
    // MARK: - 圆角配置
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        
        // 按钮圆角
        static let button: CGFloat = 12
        static let card: CGFloat = 16
    }
    
    // MARK: - 阴影配置
    struct Shadow {
        static let light = Color.black.opacity(0.05)
        static let medium = Color.black.opacity(0.1)
        static let heavy = Color.black.opacity( 0.15)
    }
}

// MARK: - 视图扩展
extension View {
    // 应用卡片样式
    func cardStyle() -> some View {
        self
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.card)
            .shadow(color: AppTheme.Shadow.light, radius: 2, x: 0, y: 1)
    }
    
    // 应用主要按钮样式
    func primaryButtonStyle() -> some View {
        self
            .frame(height: AppTheme.Spacing.buttonHeight)
            .background(AppTheme.Colors.primary)
            .foregroundColor(.white)
            .font(AppTheme.Fonts.buttonLarge)
            .cornerRadius(AppTheme.CornerRadius.button)
            .shadow(color: AppTheme.Shadow.medium, radius: 4, x: 0, y: 2)
    }
    
    // 应用次要按钮样式
    func secondaryButtonStyle() -> some View {
        self
            .frame(height: AppTheme.Spacing.buttonHeight)
            .background(AppTheme.Colors.cardBackground)
            .foregroundColor(AppTheme.Colors.primary)
            .font(AppTheme.Fonts.buttonLarge)
            .cornerRadius(AppTheme.CornerRadius.button)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.button)
                    .stroke(AppTheme.Colors.primary, lineWidth: 1.5)
            )
    }
    
    // 应用心情按钮样式（固定宽度版本，保持向后兼容）
    func moodButtonStyle(isSelected: Bool, moodLevel: Int) -> some View {
        self
            .frame(width: 70, height: 70)
            .background(
                isSelected ? 
                AppTheme.Colors.moodColor(for: moodLevel) : 
                AppTheme.Colors.cardBackground
            )
            .foregroundColor(
                isSelected ? .white : AppTheme.Colors.textPrimary
            )
            .cornerRadius(AppTheme.CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .stroke(
                        isSelected ? AppTheme.Colors.moodColor(for: moodLevel) : AppTheme.Colors.separator,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? AppTheme.Shadow.medium : AppTheme.Shadow.light,
                radius: isSelected ? 4 : 2,
                x: 0,
                y: isSelected ? 2 : 1
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    // 应用响应式心情按钮样式（动态宽度版本）
    func responsiveMoodButtonStyle(isSelected: Bool, moodLevel: Int, buttonWidth: CGFloat) -> some View {
        self
            .frame(width: buttonWidth, height: 70)
            .background(
                isSelected ? 
                AppTheme.Colors.moodColor(for: moodLevel) : 
                AppTheme.Colors.cardBackground
            )
            .foregroundColor(
                isSelected ? .white : AppTheme.Colors.textPrimary
            )
            .cornerRadius(AppTheme.CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .stroke(
                        isSelected ? AppTheme.Colors.moodColor(for: moodLevel) : AppTheme.Colors.separator,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? AppTheme.Shadow.medium : AppTheme.Shadow.light,
                radius: isSelected ? 4 : 2,
                x: 0,
                y: isSelected ? 2 : 1
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    // 应用标题样式
    func titleStyle() -> some View {
        self
            .font(AppTheme.Fonts.title1)
            .foregroundColor(AppTheme.Colors.textPrimary)
    }
    
    // 应用副标题样式
    func subtitleStyle() -> some View {
        self
            .font(AppTheme.Fonts.body)
            .foregroundColor(AppTheme.Colors.textSecondary)
    }
}

// MARK: - 自定义按钮样式
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .primaryButtonStyle()
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .secondaryButtonStyle()
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
} 