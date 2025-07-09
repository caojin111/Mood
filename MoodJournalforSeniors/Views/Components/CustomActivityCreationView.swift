import SwiftUI

// MARK: - 自定义活动创建视图
struct CustomActivityCreationView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var activityName: String = ""
    @State private var selectedCategory: ActivityCategory = .hobby
    @State private var selectedIcon: String = "star"
    @State private var showingIconPicker = false
    
    // 常用图标列表
    private let availableIcons = [
        "star", "heart", "book", "music.note", "paintbrush", "camera",
        "pencil", "gamecontroller", "tv", "phone", "car", "airplane",
        "house", "tree", "flower", "sun.max", "moon", "cloud",
        "flame", "drop", "leaf", "snowflake", "bolt", "wind",
        "gift", "bell", "flag", "crown", "gem", "key"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // 标题说明
                    instructionSection
                    
                    // 活动名称输入
                    nameInputSection
                    
                    // 分类选择
                    categorySelectionSection
                    
                    // 图标选择
                    iconSelectionSection
                    
                    // 预览区域
                    previewSection
                    
                    Spacer(minLength: AppTheme.Spacing.lg)
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("新建活动")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                        print("❌ 取消创建自定义活动")
                    }
                    .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveCustomActivity()
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                    .disabled(activityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    // 说明区域
    private var instructionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("创建您的专属活动")
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("为您的日常活动起个名字，选择合适的图标和分类，让记录更个性化。")
                .font(AppTheme.Fonts.body)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.Spacing.cardPadding)
        .cardStyle()
    }
    
    // 名称输入区域
    private var nameInputSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("活动名称")
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            TextField("请输入活动名称", text: $activityName)
                .font(AppTheme.Fonts.body)
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Colors.surface)
                .cornerRadius(AppTheme.CornerRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .stroke(AppTheme.Colors.separator, lineWidth: 1)
                )
                .onChange(of: activityName) { newValue in
                    // 限制字符数
                    if newValue.count > 10 {
                        activityName = String(newValue.prefix(10))
                    }
                }
            
            Text("建议不超过10个字符")
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.textTertiary)
        }
        .padding(AppTheme.Spacing.cardPadding)
        .cardStyle()
    }
    
    // 分类选择区域
    private var categorySelectionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("活动分类")
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("选择最适合的分类，有助于后续的数据统计")
                .font(AppTheme.Fonts.callout)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: AppTheme.Spacing.sm) {
                ForEach(ActivityCategory.allCases.filter { $0 != .custom }, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                        print("📋 选择分类: \(category.rawValue)")
                    }) {
                        HStack(spacing: AppTheme.Spacing.xs) {
                            Image(systemName: category.icon)
                                .font(.caption)
                                .foregroundColor(selectedCategory == category ? .white : AppTheme.Colors.primary)
                            
                            Text(category.rawValue)
                                .font(AppTheme.Fonts.callout)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .background(selectedCategory == category ? AppTheme.Colors.primary : AppTheme.Colors.surface)
                        .foregroundColor(selectedCategory == category ? .white : AppTheme.Colors.textPrimary)
                        .cornerRadius(AppTheme.CornerRadius.sm)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                                .stroke(
                                    selectedCategory == category ? AppTheme.Colors.primary : AppTheme.Colors.separator,
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(AppTheme.Spacing.cardPadding)
        .cardStyle()
    }
    
    // 图标选择区域
    private var iconSelectionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Text("活动图标")
                    .font(AppTheme.Fonts.title2)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                Button("更多图标") {
                    showingIconPicker = true
                }
                .font(AppTheme.Fonts.callout)
                .foregroundColor(AppTheme.Colors.primary)
            }
            
            Text("选择一个能代表您活动的图标")
                .font(AppTheme.Fonts.callout)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: AppTheme.Spacing.sm) {
                ForEach(availableIcons.prefix(12), id: \.self) { icon in
                    Button(action: {
                        selectedIcon = icon
                        print("🎨 选择图标: \(icon)")
                    }) {
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(selectedIcon == icon ? .white : AppTheme.Colors.primary)
                            .frame(width: 44, height: 44)
                            .background(selectedIcon == icon ? AppTheme.Colors.primary : AppTheme.Colors.surface)
                            .cornerRadius(AppTheme.CornerRadius.sm)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                                    .stroke(
                                        selectedIcon == icon ? AppTheme.Colors.primary : AppTheme.Colors.separator,
                                        lineWidth: 1
                                    )
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(AppTheme.Spacing.cardPadding)
        .cardStyle()
        .sheet(isPresented: $showingIconPicker) {
            IconPickerView(selectedIcon: $selectedIcon)
        }
    }
    
    // 预览区域
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("预览效果")
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            HStack {
                Spacer()
                
                // 模拟活动标签样式
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: selectedIcon)
                        .font(.caption)
                        .foregroundColor(AppTheme.Colors.primary)
                    
                    Text(activityName.isEmpty ? "活动名称" : activityName)
                        .font(AppTheme.Fonts.callout)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(AppTheme.Colors.surface)
                .cornerRadius(AppTheme.CornerRadius.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                        .stroke(AppTheme.Colors.separator, lineWidth: 1)
                )
                
                Spacer()
            }
        }
        .padding(AppTheme.Spacing.cardPadding)
        .cardStyle()
    }
    
    // 保存自定义活动
    private func saveCustomActivity() {
        let trimmedName = activityName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            print("❌ 活动名称不能为空")
            return
        }
        
        // 检查是否已存在同名活动
        let existingActivities = dataManager.getAllActivities()
        if existingActivities.contains(where: { $0.name == trimmedName }) {
            print("❌ 活动名称已存在: \(trimmedName)")
            // TODO: 显示错误提示
            return
        }
        
        // 创建自定义活动（使用选中的图标作为自定义图标）
        let customActivity = CustomActivity(
            name: trimmedName,
            category: selectedCategory,
            icon: selectedIcon
        )
        
        // 转换为Activity对象保存
        let activity = Activity(
            name: customActivity.name,
            category: customActivity.category,
            isCustom: true,
            customIcon: customActivity.icon
        )
        
        dataManager.addCustomActivity(activity)
        presentationMode.wrappedValue.dismiss()
        
        print("✅ 保存自定义活动成功: \(trimmedName)")
    }
}

// MARK: - 自定义活动模型
struct CustomActivity {
    let name: String
    let category: ActivityCategory
    let icon: String
}

// MARK: - 图标选择器视图
struct IconPickerView: View {
    @Binding var selectedIcon: String
    @Environment(\.presentationMode) var presentationMode
    
    private let allIcons = [
        // 基础图标
        "star", "heart", "star.fill", "heart.fill", "circle", "square",
        // 学习教育
        "book", "book.fill", "graduationcap", "pencil", "highlighter", "note.text",
        // 艺术创作
        "paintbrush", "paintbrush.fill", "camera", "music.note", "mic", "guitar",
        // 运动健康
        "figure.walk", "bicycle", "heart.text.square", "leaf", "drop", "flame",
        // 娱乐休闲
        "gamecontroller", "tv", "phone", "headphones", "popcorn", "puzzlepiece",
        // 交通出行
        "car", "airplane", "train.side.front.car", "ferry", "scooter", "bicycle",
        // 居家生活
        "house", "bed.double", "sofa", "lamp.table", "shower", "washer",
        // 自然环境
        "tree", "flower", "sun.max", "moon", "cloud", "snow",
        // 工具用品
        "hammer", "wrench", "screwdriver", "gear", "key", "lock",
        // 食物饮品
        "fork.knife", "cup.and.saucer", "birthday.cake", "leaf", "carrot", "fish",
        // 其他
        "gift", "bell", "flag", "crown", "gem", "diamond"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: AppTheme.Spacing.md) {
                    ForEach(allIcons, id: \.self) { icon in
                        Button(action: {
                            selectedIcon = icon
                            presentationMode.wrappedValue.dismiss()
                            print("🎨 选择图标: \(icon)")
                        }) {
                            Image(systemName: icon)
                                .font(.title2)
                                .foregroundColor(selectedIcon == icon ? .white : AppTheme.Colors.primary)
                                .frame(width: 50, height: 50)
                                .background(selectedIcon == icon ? AppTheme.Colors.primary : AppTheme.Colors.surface)
                                .cornerRadius(AppTheme.CornerRadius.md)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                        .stroke(
                                            selectedIcon == icon ? AppTheme.Colors.primary : AppTheme.Colors.separator,
                                            lineWidth: selectedIcon == icon ? 2 : 1
                                        )
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(AppTheme.Spacing.md)
            }
            .navigationTitle("选择图标")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                }
            }
        }
    }
}

#Preview {
    CustomActivityCreationView()
        .environmentObject(DataManager.shared)
} 