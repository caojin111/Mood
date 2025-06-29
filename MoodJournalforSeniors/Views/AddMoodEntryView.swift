import SwiftUI

// MARK: - 添加心情日记视图
struct AddMoodEntryView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedMood: Int = 3
    @State private var selectedActivities: Set<Activity> = []
    @State private var noteText: String = ""
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) { // 减少区域间距
                    // 心情选择
                    moodSelectionSection
                    
                    // 活动选择
                    activitySelectionSection
                    
                    // 日期选择
                    dateSelectionSection
                    
                    // 备注输入
                    noteInputSection
                    
                    // 保存按钮
                    saveButton
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm) // 减少垂直边距
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("记录心情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                        print("❌ 取消添加心情日记")
                    }
                    .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
        }
    }
    
    // 心情选择区域
    private var moodSelectionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Text("今天的心情如何？")
                    .font(AppTheme.Fonts.title2)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                Text(moodDescription(for: selectedMood))
                    .font(AppTheme.Fonts.body)
                    .foregroundColor(AppTheme.Colors.moodColor(for: selectedMood))
            }
            
            // 使用 GeometryReader 来动态计算按钮宽度
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ForEach(1...5, id: \.self) { mood in
                        Button(action: {
                            selectedMood = mood
                            print("😊 选择心情: \(moodDescription(for: mood))")
                        }) {
                            VStack(spacing: AppTheme.Spacing.xs) {
                                Text(dataManager.getMoodDisplay(for: mood))
                                    .font(.title)
                                
                                Text(moodDescription(for: mood))
                                    .font(AppTheme.Fonts.caption)
                                    .foregroundColor(selectedMood == mood ? .white : AppTheme.Colors.textSecondary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            .responsiveMoodButtonStyle(
                                isSelected: selectedMood == mood, 
                                moodLevel: mood,
                                buttonWidth: (geometry.size.width - 4 * AppTheme.Spacing.xs) / 5
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if mood < 5 {
                            Spacer()
                                .frame(width: AppTheme.Spacing.xs)
                        }
                    }
                }
            }
            .frame(height: 80) // 固定高度以确保 GeometryReader 正常工作
        }
        .padding(AppTheme.Spacing.cardPadding)
        .cardStyle()
    }
    
    // 活动选择区域
    private var activitySelectionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("今天做了什么？")
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("选择您今天的活动（可多选）")
                .font(AppTheme.Fonts.callout)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: AppTheme.Spacing.xs), count: 2), 
                spacing: AppTheme.Spacing.sm
            ) {
                ForEach(dataManager.getAllActivities().prefix(8), id: \.id) { activity in
                    ActivityTagView(
                        activity: activity,
                        isSelected: selectedActivities.contains(activity)
                    ) {
                        toggleActivity(activity)
                    }
                }
            }
        }
        .padding(AppTheme.Spacing.cardPadding)
        .cardStyle()
    }
    
    // 日期选择区域
    private var dateSelectionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("记录日期")
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            DatePicker("选择日期", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(CompactDatePickerStyle())
                .font(AppTheme.Fonts.body)
        }
        .padding(AppTheme.Spacing.cardPadding)
        .cardStyle()
    }
    
    // 备注输入区域
    private var noteInputSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("备注")
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            ZStack(alignment: .topLeading) {
                if noteText.isEmpty {
                    Text("记录更多想法...")
                        .font(AppTheme.Fonts.body)
                        .foregroundColor(AppTheme.Colors.textTertiary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                }
                
                TextEditor(text: $noteText)
                    .font(AppTheme.Fonts.body)
                    .frame(minHeight: 80) // 减少最小高度
                    .scrollContentBackground(.hidden)
            }
            .background(AppTheme.Colors.surface)
            .cornerRadius(AppTheme.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .stroke(AppTheme.Colors.separator, lineWidth: 1)
            )
        }
        .padding(AppTheme.Spacing.cardPadding)
        .cardStyle()
    }
    
    // 保存按钮
    private var saveButton: some View {
        Button(action: saveMoodEntry) {
            Text("保存记录")
                .frame(maxWidth: .infinity)
                .primaryButtonStyle()
        }
        .padding(.horizontal, AppTheme.Spacing.md)
    }
    
    // 辅助方法
    private func moodEmoji(for level: Int) -> String {
        switch level {
        case 1: return "😢"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "😊"
        case 5: return "😄"
        default: return "😐"
        }
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
    
    private func toggleActivity(_ activity: Activity) {
        if selectedActivities.contains(activity) {
            selectedActivities.remove(activity)
            print("➖ 取消选择活动: \(activity.name)")
        } else {
            selectedActivities.insert(activity)
            print("➕ 选择活动: \(activity.name)")
        }
    }
    
    private func saveMoodEntry() {
        let entry = MoodEntry(
            date: selectedDate,
            moodLevel: selectedMood,
            activities: Array(selectedActivities),
            note: noteText.isEmpty ? nil : noteText
        )
        
        dataManager.addMoodEntry(entry)
        presentationMode.wrappedValue.dismiss()
        
        print("💾 保存心情日记成功: \(entry.moodDescription)")
    }
}

// MARK: - 活动标签视图
struct ActivityTagView: View {
    let activity: Activity
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: activity.category.icon)
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

#Preview {
    AddMoodEntryView()
        .environmentObject(DataManager.shared)
} 