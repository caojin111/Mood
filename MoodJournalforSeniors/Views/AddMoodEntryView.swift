import SwiftUI

// MARK: - 添加心情日记视图
struct AddMoodEntryView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedMood: Int = 3
    @State private var selectedActivities: Set<Activity> = []
    @State private var noteText: String = ""
    @State private var selectedDate = Date()
    @State private var showingCustomActivityCreation = false
    @State private var showingActivityLimitAlert = false
    @State private var selectedAudioURL: URL?
    @State private var selectedImage: UIImage?
    
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
                    
                    // 语音录制
                    voiceRecordingSection
                    
                    // 照片选择
                    photoSelectionSection
                    
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
        .onAppear {
            // 调试：检查自定义活动状态
            dataManager.debugCustomActivities()
            dataManager.checkActivityDisplayStatus()
            print("📱 AddMoodEntryView 出现，当前显示的活动: \(getPreferredActivities().map { $0.name })")
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
                // 显示优选的活动（确保包含"阅读"和自定义活动）
                ForEach(getPreferredActivities(), id: \.id) { activity in
                    ActivityTagView(
                        activity: activity,
                        isSelected: selectedActivities.contains(activity)
                    ) {
                        toggleActivity(activity)
                    }
                }
                
                // 新建活动按钮
                NewActivityButton(isDisabled: hasReachedActivityLimit()) {
                    handleNewActivityButtonTap()
                }
            }
            .animation(.easeInOut(duration: 0.3), value: dataManager.customActivities.count)
        }
        .padding(AppTheme.Spacing.cardPadding)
        .cardStyle()
        .sheet(isPresented: $showingCustomActivityCreation) {
            CustomActivityCreationView()
                .environmentObject(dataManager)
        }
        .alert("提示", isPresented: $showingActivityLimitAlert) {
            Button("确定") {
                showingActivityLimitAlert = false
            }
        } message: {
            Text("活动数已达到上限！")
        }
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
    
    // 语音录制区域
    private var voiceRecordingSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("添加语音")
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("录制语音备忘，留下珍贵的声音回忆")
                .font(AppTheme.Fonts.callout)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            VoiceRecorderView(audioURL: $selectedAudioURL)
        }
        .padding(AppTheme.Spacing.cardPadding)
        .cardStyle()
    }
    
    // 照片选择区域
    private var photoSelectionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("添加照片")
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("记录美好瞬间，为心情增添色彩")
                .font(AppTheme.Fonts.callout)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            PhotoSelectorView(selectedImage: $selectedImage)
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
        var imageURL: URL?
        
        // 处理图片保存
        if let image = selectedImage {
            imageURL = dataManager.saveImage(image)
            if imageURL == nil {
                print("❌ 图片保存失败")
                return
            }
        }
        
        let entry = MoodEntry(
            date: selectedDate,
            moodLevel: selectedMood,
            activities: Array(selectedActivities),
            note: noteText.isEmpty ? nil : noteText,
            audioURL: selectedAudioURL,
            imageURL: imageURL
        )
        
        dataManager.addMoodEntry(entry)
        presentationMode.wrappedValue.dismiss()
        
        let mediaInfo = buildMediaInfo()
        print("💾 保存心情日记成功: \(entry.moodDescription)\(mediaInfo)")
    }
    
    private func buildMediaInfo() -> String {
        var info = ""
        if selectedAudioURL != nil {
            info += "，包含语音"
        }
        if selectedImage != nil {
            info += "，包含照片"
        }
        return info
    }
    
    // 检查活动数量是否已达上限
    private func hasReachedActivityLimit() -> Bool {
        return getPreferredActivities().count >= 19
    }
    
    // 处理新建活动按钮点击
    private func handleNewActivityButtonTap() {
        if hasReachedActivityLimit() {
            showingActivityLimitAlert = true
            print("⚠️ 活动数已达到上限(19个)，无法继续添加")
        } else {
            showingCustomActivityCreation = true
            print("➕ 点击新建活动按钮")
        }
    }
    
    // 获取优选的活动列表（确保包含"阅读"和自定义活动）
    private func getPreferredActivities() -> [Activity] {
        let allActivities = dataManager.getAllActivities()
        
        // 优先显示的活动名称列表
        let preferredNames = [
            "散步", "太极", "与朋友聊天", "与家人聊天", 
            "阅读", "看电视", "听音乐", "休息", "烹饪"
        ]
        
        var preferredActivities: [Activity] = []
        
        // 首先添加所有自定义活动（优先显示用户创建的活动）
        let customActivities = allActivities.filter { $0.isCustom }
        preferredActivities.append(contentsOf: customActivities)
        
        // 按优先级顺序添加预定义活动
        for name in preferredNames {
            if let activity = allActivities.first(where: { $0.name == name && !$0.isCustom }) {
                preferredActivities.append(activity)
            }
            if preferredActivities.count >= 19 { break }
        }
        
        // 如果还不足19个，补充其他预定义活动
        if preferredActivities.count < 19 {
            let remainingActivities = allActivities.filter { activity in
                !preferredActivities.contains(where: { $0.id == activity.id }) && !activity.isCustom
            }
            let needed = 19 - preferredActivities.count
            preferredActivities.append(contentsOf: Array(remainingActivities.prefix(needed)))
        }
        
        print("📋 显示优选活动: \(preferredActivities.count)/19个，其中自定义活动: \(customActivities.count)个")
        print("   - 自定义活动: \(customActivities.map { $0.name })")
        print("   - 预定义活动: \(preferredActivities.filter { !$0.isCustom }.map { $0.name })")
        return preferredActivities
    }
}



#Preview {
    AddMoodEntryView()
        .environmentObject(DataManager.shared)
} 