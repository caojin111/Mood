import SwiftUI

// MARK: - 活动标签视图
struct ActivityTagView: View {
    let activity: Activity
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: activity.icon)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : AppTheme.Colors.primary)
                
                Text(activity.name)
                    .font(AppTheme.Fonts.callout)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8) // 允许文字缩放以适应空间
                    .truncationMode(.tail)
            }
            .frame(maxWidth: .infinity) // 让标签占满可用宽度
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(
                isSelected ? AppTheme.Colors.primary : AppTheme.Colors.surface
            )
            .foregroundColor(
                isSelected ? .white : AppTheme.Colors.textPrimary
            )
            .cornerRadius(AppTheme.CornerRadius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                    .stroke(
                        isSelected ? AppTheme.Colors.primary : AppTheme.Colors.separator,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0) // 减小缩放效果避免布局跳动
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - 新建活动按钮
struct NewActivityButton: View {
    let isDisabled: Bool
    let action: () -> Void
    
    init(isDisabled: Bool = false, action: @escaping () -> Void) {
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: isDisabled ? "exclamationmark.circle" : "plus.circle")
                    .font(.caption)
                    .foregroundColor(isDisabled ? AppTheme.Colors.textTertiary : AppTheme.Colors.primary)
                
                Text(isDisabled ? "已满" : "新建")
                    .font(AppTheme.Fonts.callout)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(isDisabled ? AppTheme.Colors.separator.opacity(0.3) : AppTheme.Colors.surface)
            .foregroundColor(isDisabled ? AppTheme.Colors.textTertiary : AppTheme.Colors.primary)
            .cornerRadius(AppTheme.CornerRadius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                    .stroke(
                        isDisabled ? AppTheme.Colors.textTertiary : AppTheme.Colors.primary, 
                        style: StrokeStyle(lineWidth: 1.5, dash: isDisabled ? [2, 2] : [4, 4])
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.2), value: isDisabled)
    }
} 