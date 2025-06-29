import SwiftUI

// MARK: - 心情日记详情视图
struct MoodEntryDetailView: View {
    let entry: MoodEntry
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.sectionSpacing) {
                    // 心情概览
                    moodOverviewSection
                    
                    // 活动列表
                    if !entry.activities.isEmpty {
                        activitiesSection
                    }
                    
                    // 备注内容
                    if let note = entry.note, !note.isEmpty {
                        noteSection(note: note)
                    }
                    
                    // 时间信息
                    timeInfoSection
                }
                .padding(AppTheme.Spacing.md)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("心情详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            showingEditView = true
                            print("✏️ 编辑心情日记: \(entry.moodDescription)")
                        }) {
                            Label("编辑", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: {
                            showingDeleteAlert = true
                        }) {
                            Label("删除", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            EditMoodEntryView(entry: entry)
                .environmentObject(dataManager)
        }
        .alert("删除确认", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                deleteMoodEntry()
            }
        } message: {
            Text("确定要删除这条心情记录吗？此操作无法撤销。")
        }
    }
    
    // 心情概览区域
    private var moodOverviewSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // 心情显示
            Circle()
                .fill(AppTheme.Colors.moodColor(for: entry.moodLevel))
                .frame(width: 120, height: 120)
                .overlay(
                    Text(dataManager.getMoodDisplay(for: entry.moodLevel))
                        .font(.system(size: 60))
                )
                .shadow(color: AppTheme.Shadow.medium, radius: 8, x: 0, y: 4)
            
            VStack(spacing: AppTheme.Spacing.xs) {
                Text(entry.moodDescription)
                    .font(AppTheme.Fonts.title1)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text(formatDetailDate(entry.date))
                    .font(AppTheme.Fonts.body)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
        .padding(AppTheme.Spacing.cardPadding)
        .cardStyle()
    }
    
    // 活动列表区域
    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("活动记录")
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: AppTheme.Spacing.sm) {
                ForEach(entry.activities, id: \.id) { activity in
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: activity.category.icon)
                            .font(.caption)
                            .foregroundColor(AppTheme.Colors.primary)
                        
                        Text(activity.name)
                            .font(AppTheme.Fonts.callout)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, AppTheme.Spacing.xs)
                    .background(AppTheme.Colors.primaryLight)
                    .cornerRadius(AppTheme.CornerRadius.sm)
                }
            }
        }
        .padding(AppTheme.Spacing.cardPadding)
        .cardStyle()
    }
    
    // 备注区域
    private func noteSection(note: String) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("备注")
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text(note)
                .font(AppTheme.Fonts.body)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.Spacing.cardPadding)
        .cardStyle()
    }
    
    // 时间信息区域
    private var timeInfoSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("时间信息")
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                HStack {
                    Text("记录时间:")
                        .font(AppTheme.Fonts.callout)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    Spacer()
                    
                    Text(formatDetailDate(entry.createdAt))
                        .font(AppTheme.Fonts.callout)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
                
                if entry.createdAt != entry.updatedAt {
                    HStack {
                        Text("更新时间:")
                            .font(AppTheme.Fonts.callout)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        
                        Spacer()
                        
                        Text(formatDetailDate(entry.updatedAt))
                            .font(AppTheme.Fonts.callout)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                }
            }
        }
        .padding(AppTheme.Spacing.cardPadding)
        .cardStyle()
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
    
    private func formatDetailDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        return formatter.string(from: date)
    }
    
    private func deleteMoodEntry() {
        dataManager.deleteMoodEntry(entry)
        presentationMode.wrappedValue.dismiss()
        print("🗑️ 删除心情日记: \(entry.moodDescription)")
    }
}

// MARK: - 编辑心情日记视图（占位）
struct EditMoodEntryView: View {
    let entry: MoodEntry
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                VStack(spacing: AppTheme.Spacing.md) {
                    Image(systemName: "pencil")
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.Colors.textTertiary)
                    
                    Text("编辑功能")
                        .titleStyle()
                    
                    Text("即将推出")
                        .subtitleStyle()
                }
                
                Spacer()
            }
            .navigationTitle("编辑心情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
        }
    }
}

#Preview {
    let sampleEntry = MoodEntry(
        moodLevel: 4,
        activities: [
            Activity(name: "散步", category: .exercise),
            Activity(name: "阅读", category: .hobby)
        ],
        note: "今天天气很好，心情不错。"
    )
    
    return MoodEntryDetailView(entry: sampleEntry)
        .environmentObject(DataManager.shared)
} 