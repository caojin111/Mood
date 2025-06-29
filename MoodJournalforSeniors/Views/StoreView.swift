import SwiftUI

// MARK: - 心情皮肤商店视图
struct StoreView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedSkinPack: MoodSkinPack?
    @State private var showingPreview = false
    @State private var selectedCategory: SkinPackCategory = .all
    
    // 网格布局配置
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // 顶部说明
                    headerSection
                    
                    // 当前使用皮肤包
                    currentSkinPackSection
                    
                    // 分类筛选
                    categoryFilterSection
                    
                    // 皮肤包商店网格
                    skinPackStoreSection
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.bottom, AppTheme.Spacing.lg)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("心情皮肤")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingPreview) {
            if let skinPack = selectedSkinPack {
                SkinPackPreviewView(skinPack: skinPack)
                    .environmentObject(dataManager)
            }
        }
        .onAppear {
            print("🎨 心情皮肤商店页面加载完成")
        }
    }
    
    // 顶部说明区域
    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            HStack {
                Image(systemName: "face.smiling.fill")
                    .font(.title2)
                    .foregroundColor(AppTheme.Colors.primary)
                
                Text("心情图片皮肤")
                    .font(AppTheme.Fonts.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
            }
            
            Text("选择您喜欢的心情图片风格，让记录心情更加生动有趣")
                .font(AppTheme.Fonts.callout)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .lineLimit(nil)
        }
        .padding(AppTheme.Spacing.cardPadding)
        .cardStyle()
    }
    
    // 当前使用皮肤包区域
    private var currentSkinPackSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                Text("当前皮肤")
                    .font(AppTheme.Fonts.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
            }
            
            CurrentSkinPackCard(skinPack: dataManager.currentMoodSkinPack)
        }
    }
    
    // 分类筛选区域
    private var categoryFilterSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                Text("分类浏览")
                    .font(AppTheme.Fonts.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(SkinPackCategory.allCases, id: \.self) { category in
                        CategoryFilterButton(
                            category: category,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                            print("📂 切换分类筛选: \(category.rawValue)")
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.sm)
            }
        }
    }
    
    // 皮肤包商店区域
    private var skinPackStoreSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                Text(selectedCategory == .all ? "所有皮肤包" : selectedCategory.rawValue)
                    .font(AppTheme.Fonts.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                let filteredPacks = dataManager.getMoodSkinPacks(for: selectedCategory)
                let unlockedCount = filteredPacks.filter { dataManager.isMoodSkinPackUnlocked($0) }.count
                
                Text("\(unlockedCount)/\(filteredPacks.count) 已解锁")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            LazyVGrid(columns: columns, spacing: AppTheme.Spacing.md) {
                ForEach(dataManager.getMoodSkinPacks(for: selectedCategory)) { skinPack in
                    SkinPackCard(
                        skinPack: skinPack,
                        isUnlocked: dataManager.isMoodSkinPackUnlocked(skinPack),
                        isCurrent: skinPack.id == dataManager.currentMoodSkinPack.id,
                        onPreview: {
                            selectedSkinPack = skinPack
                            showingPreview = true
                        },
                        onApply: {
                            dataManager.applyMoodSkinPack(skinPack)
                        },
                        onUnlock: {
                            dataManager.unlockMoodSkinPack(skinPack)
                        }
                    )
                }
            }
        }
    }
}

// MARK: - 当前皮肤包卡片
struct CurrentSkinPackCard: View {
    let skinPack: MoodSkinPack
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // 皮肤包预览（显示五个心情）
            VStack(spacing: AppTheme.Spacing.xs) {
                HStack(spacing: AppTheme.Spacing.xs) {
                    ForEach(1...5, id: \.self) { mood in
                        Text(skinPack.getMoodEmoji(for: mood))
                            .font(.system(size: 16))
                    }
                }
                
                Text("✓ 使用中")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.primary)
                    .fontWeight(.medium)
            }
            .frame(width: 80)
            
            // 皮肤包信息
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(skinPack.name)
                    .font(AppTheme.Fonts.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text(skinPack.description)
                    .font(AppTheme.Fonts.callout)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .lineLimit(2)
                
                HStack {
                    Text(skinPack.category)
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.primary)
                        .padding(.horizontal, AppTheme.Spacing.xs)
                        .padding(.vertical, 2)
                        .background(AppTheme.Colors.primaryLight.opacity(0.3))
                        .cornerRadius(AppTheme.CornerRadius.sm)
                    
                    Spacer()
                }
            }
            
            Spacer()
        }
        .padding(AppTheme.Spacing.cardPadding)
        .cardStyle()
    }
}

// MARK: - 分类筛选按钮
struct CategoryFilterButton: View {
    let category: SkinPackCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: category.icon)
                    .font(.caption)
                
                Text(category.rawValue)
                    .font(AppTheme.Fonts.callout)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(
                isSelected ? AppTheme.Colors.primary : AppTheme.Colors.surface
            )
            .foregroundColor(
                isSelected ? .white : AppTheme.Colors.textPrimary
            )
            .cornerRadius(AppTheme.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .stroke(
                        isSelected ? AppTheme.Colors.primary : AppTheme.Colors.separator,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - 皮肤包卡片
struct SkinPackCard: View {
    let skinPack: MoodSkinPack
    let isUnlocked: Bool
    let isCurrent: Bool
    let onPreview: () -> Void
    let onApply: () -> Void
    let onUnlock: () -> Void
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            // 皮肤包预览区域
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(AppTheme.Colors.surface)
                    .frame(height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                            .stroke(
                                isCurrent ? AppTheme.Colors.primary : AppTheme.Colors.separator,
                                lineWidth: isCurrent ? 2 : 1
                            )
                    )
                
                if isUnlocked {
                    // 显示五个心情表情
                    VStack(spacing: AppTheme.Spacing.xs) {
                        Text(skinPack.name)
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        
                        HStack(spacing: AppTheme.Spacing.xs) {
                            ForEach(1...5, id: \.self) { mood in
                                Text(skinPack.getMoodEmoji(for: mood))
                                    .font(.system(size: 20))
                            }
                        }
                        
                        if isCurrent {
                            Text("✓ 使用中")
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(AppTheme.Colors.primary)
                                .fontWeight(.medium)
                        }
                    }
                } else {
                    // 锁定状态
                    VStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "lock.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.Colors.textTertiary)
                        
                        Text("未解锁")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.textTertiary)
                    }
                }
            }
            .onTapGesture {
                if isUnlocked {
                    onPreview()
                }
            }
            
            // 皮肤包信息
            VStack(spacing: AppTheme.Spacing.xs) {
                HStack {
                    Text(skinPack.name)
                        .font(AppTheme.Fonts.callout)
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if skinPack.isPremium {
                        Text("付费")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                
                Text(skinPack.description)
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            
            // 操作按钮
            if isCurrent {
                Text("使用中")
                    .font(AppTheme.Fonts.caption)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.Colors.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
                    .background(AppTheme.Colors.primaryLight)
                    .cornerRadius(AppTheme.CornerRadius.sm)
            } else if isUnlocked {
                Button("应用") {
                    onApply()
                }
                .font(AppTheme.Fonts.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(AppTheme.Colors.primary)
                .cornerRadius(AppTheme.CornerRadius.sm)
            } else {
                Button(skinPack.isPremium ? (skinPack.price ?? "购买") : "解锁") {
                    onUnlock()
                }
                .font(AppTheme.Fonts.caption)
                .fontWeight(.medium)
                .foregroundColor(AppTheme.Colors.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(AppTheme.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                        .stroke(AppTheme.Colors.primary, lineWidth: 1)
                )
            }
        }
        .padding(AppTheme.Spacing.sm)
        .cardStyle()
    }
}

// MARK: - 皮肤包预览视图
struct SkinPackPreviewView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    let skinPack: MoodSkinPack
    
    var body: some View {
        NavigationView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // 预览区域
                VStack(spacing: AppTheme.Spacing.md) {
                    Text("皮肤包预览")
                        .font(AppTheme.Fonts.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text(skinPack.name)
                        .font(AppTheme.Fonts.title3)
                        .foregroundColor(AppTheme.Colors.primary)
                    
                    Text(skinPack.description)
                        .font(AppTheme.Fonts.callout)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    // 五个心情等级预览
                    skinPackPreviewGrid
                }
                
                Spacer()
                
                // 底部按钮
                VStack(spacing: AppTheme.Spacing.md) {
                    if dataManager.isMoodSkinPackUnlocked(skinPack) {
                        Button("应用此皮肤") {
                            dataManager.applyMoodSkinPack(skinPack)
                            dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .primaryButtonStyle()
                    } else {
                        Button(skinPack.isPremium ? "购买皮肤包 \(skinPack.price ?? "")" : "免费解锁") {
                            dataManager.unlockMoodSkinPack(skinPack)
                            dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .primaryButtonStyle()
                    }
                    
                    Button("取消") {
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .secondaryButtonStyle()
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
            }
            .padding(AppTheme.Spacing.lg)
            .background(AppTheme.Colors.background)
            .navigationBarHidden(true)
        }
    }
    
    private var skinPackPreviewGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: AppTheme.Spacing.md) {
            ForEach(1...5, id: \.self) { mood in
                VStack(spacing: AppTheme.Spacing.xs) {
                    Text(skinPack.getMoodEmoji(for: mood))
                        .font(.system(size: 40))
                    
                    Text(moodDescription(for: mood))
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                .frame(width: 60, height: 80)
                .background(AppTheme.Colors.surface)
                .cornerRadius(AppTheme.CornerRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .stroke(AppTheme.Colors.moodColor(for: mood), lineWidth: 1)
                )
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.lg)
    }
    
    private func moodDescription(for level: Int) -> String {
        switch level {
        case 1: return "很差"
        case 2: return "不好"
        case 3: return "一般"
        case 4: return "不错"
        case 5: return "很好"
        default: return "未知"
        }
    }
}

#Preview {
    StoreView()
        .environmentObject(DataManager.shared)
} 