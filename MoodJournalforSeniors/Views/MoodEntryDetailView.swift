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
                    
                    // 媒体展示区域
                    if entry.hasMedia {
                        mediaDisplaySection
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
        .onAppear {
            print("📱 打开心情详情页面: \(entry.moodDescription)")
            print("   - 包含媒体: \(entry.hasMedia)")
            if let audioURL = entry.audioURL {
                print("   - 语音文件: \(audioURL.lastPathComponent)")
            }
            if let imageURL = entry.imageURL {
                print("   - 图片文件: \(imageURL.lastPathComponent)")
            }
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
                        Image(systemName: activity.icon)
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
    
    // 媒体展示区域
    private var mediaDisplaySection: some View {
        MediaDisplayView(audioURL: entry.audioURL, imageURL: entry.imageURL)
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

// MARK: - 编辑心情日记视图
struct EditMoodEntryView: View {
    let entry: MoodEntry
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedMood: Int
    @State private var selectedActivities: Set<Activity>
    @State private var noteText: String
    @State private var selectedDate: Date
    @State private var showingCustomActivityCreation = false
    @State private var showingActivityLimitAlert = false
    @State private var selectedAudioURL: URL?
    @State private var selectedImage: UIImage?
    @State private var originalImageURL: URL?
    
    init(entry: MoodEntry) {
        self.entry = entry
        self._selectedMood = State(initialValue: entry.moodLevel)
        self._selectedActivities = State(initialValue: Set(entry.activities))
        self._noteText = State(initialValue: entry.note ?? "")
        self._selectedDate = State(initialValue: entry.date)
        self._selectedAudioURL = State(initialValue: entry.audioURL)
        self._originalImageURL = State(initialValue: entry.imageURL)
        
        // 如果有原始图片，尝试加载
        if let imageURL = entry.imageURL {
            self._selectedImage = State(initialValue: UIImage(contentsOfFile: imageURL.path))
        } else {
            self._selectedImage = State(initialValue: nil)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
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
                .padding(.vertical, AppTheme.Spacing.sm)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("编辑心情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                        print("❌ 取消编辑心情日记")
                    }
                    .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            .onAppear {
                print("✏️ 开始编辑心情日记: \(entry.moodDescription)")
                print("   - 当前心情: \(selectedMood)")
                print("   - 当前活动: \(selectedActivities.map { $0.name })")
                print("   - 当前备注: \(noteText)")
            }
        }
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
    
    // 心情选择区域
    private var moodSelectionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Text("心情如何？")
                    .font(AppTheme.Fonts.title2)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                Text(moodDescription(for: selectedMood))
                    .font(AppTheme.Fonts.body)
                    .foregroundColor(AppTheme.Colors.moodColor(for: selectedMood))
            }
            
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ForEach(1...5, id: \.self) { mood in
                        Button(action: {
                            selectedMood = mood
                            print("😊 修改心情: \(moodDescription(for: mood))")
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
            .frame(height: 80)
        }
        .padding(AppTheme.Spacing.cardPadding)
        .cardStyle()
    }
    
    // 活动选择区域
    private var activitySelectionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("做了什么？")
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("选择您的活动（可多选）")
                .font(AppTheme.Fonts.callout)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: AppTheme.Spacing.xs), count: 2), 
                spacing: AppTheme.Spacing.sm
            ) {
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
                    .frame(minHeight: 80)
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
            Text("编辑语音")
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("修改或添加语音备忘")
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
            Text("编辑照片")
                .font(AppTheme.Fonts.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("修改或添加照片")
                .font(AppTheme.Fonts.callout)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            PhotoSelectorView(selectedImage: $selectedImage)
        }
        .padding(AppTheme.Spacing.cardPadding)
        .cardStyle()
    }
    
    // 保存按钮
    private var saveButton: some View {
        Button(action: saveChanges) {
            Text("保存修改")
                .frame(maxWidth: .infinity)
                .primaryButtonStyle()
        }
        .padding(.horizontal, AppTheme.Spacing.md)
    }
    
    // 辅助方法
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
    
    private func hasReachedActivityLimit() -> Bool {
        return getPreferredActivities().count >= 19
    }
    
    private func handleNewActivityButtonTap() {
        if hasReachedActivityLimit() {
            showingActivityLimitAlert = true
            print("⚠️ 活动数已达到上限(19个)，无法继续添加")
        } else {
            showingCustomActivityCreation = true
            print("➕ 点击新建活动按钮")
        }
    }
    
    private func getPreferredActivities() -> [Activity] {
        let allActivities = dataManager.getAllActivities()
        
        let preferredNames = [
            "散步", "太极", "与朋友聊天", "与家人聊天", 
            "阅读", "看电视", "听音乐", "休息", "烹饪"
        ]
        
        var preferredActivities: [Activity] = []
        
        // 首先添加所有自定义活动
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
        
        return preferredActivities
    }
    
    private func saveChanges() {
        var newImageURL: URL?
        
        // 处理图片更新
        if let image = selectedImage {
            // 如果有新图片，保存它
            if originalImageURL == nil || UIImage(contentsOfFile: originalImageURL!.path) != image {
                newImageURL = dataManager.saveImage(image)
                if newImageURL == nil {
                    print("❌ 图片保存失败")
                    return
                }
                
                // 删除旧图片（如果存在且不同）
                if let oldURL = originalImageURL, oldURL != newImageURL {
                    dataManager.deleteMediaFile(at: oldURL)
                }
            } else {
                // 图片没有变化，保持原URL
                newImageURL = originalImageURL
            }
        } else if let oldURL = originalImageURL {
            // 用户删除了图片，清理旧文件
            dataManager.deleteMediaFile(at: oldURL)
        }
        
        // 处理音频更新（如果原音频被删除，也需要清理）
        if selectedAudioURL != entry.audioURL {
            if let oldAudioURL = entry.audioURL, selectedAudioURL == nil {
                dataManager.deleteMediaFile(at: oldAudioURL)
            }
        }
        
        let updatedEntry = MoodEntry(
            existingEntry: entry,
            date: selectedDate,
            moodLevel: selectedMood,
            activities: Array(selectedActivities),
            note: noteText.isEmpty ? nil : noteText,
            audioURL: selectedAudioURL,
            imageURL: newImageURL
        )
        
        dataManager.updateMoodEntry(updatedEntry)
        presentationMode.wrappedValue.dismiss()
        
        let mediaInfo = buildMediaInfo()
        print("💾 保存心情日记修改成功: \(updatedEntry.moodDescription)\(mediaInfo)")
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