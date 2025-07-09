import Foundation
import SwiftUI

// MARK: - 数据管理器
class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var userProfile: UserProfile
    @Published var moodEntries: [MoodEntry] = []
    @Published var customActivities: [Activity] = []
    @Published var currentTheme: ThemeModel = ThemeModel.availableThemes.first!
    @Published var unlockedThemes: Set<String> = ["default", "warm_orange", "calm_blue"]
    @Published var currentMoodSkinPack: MoodSkinPack = MoodSkinPack.availablePacks.first!
    @Published var unlockedMoodSkinPacks: Set<String> = ["default_emoji", "cute_animals"]
    
    // 可用的皮肤包列表
    var availableSkinPacks: [MoodSkinPack] {
        return MoodSkinPack.availablePacks.map { pack in
            var updatedPack = pack
            updatedPack.isUnlocked = unlockedMoodSkinPacks.contains(pack.id)
            return updatedPack
        }
    }
    
    private let userDefaultsKey = "MoodJournalData"
    private let userProfileKey = "UserProfile"
    private let moodEntriesKey = "MoodEntries"
    private let customActivitiesKey = "CustomActivities"
    private let currentThemeKey = "CurrentTheme"
    private let unlockedThemesKey = "UnlockedThemes"
    private let currentMoodSkinPackKey = "CurrentMoodSkinPack"
    private let unlockedMoodSkinPacksKey = "UnlockedMoodSkinPacks"
    
    init() {
        print("🗃️ 初始化数据管理器")
        
        // 加载用户配置
        if let data = UserDefaults.standard.data(forKey: userProfileKey),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.userProfile = profile
            print("📂 加载已存在的用户配置")
        } else {
            self.userProfile = UserProfile()
            print("📂 创建新的用户配置")
        }
        
        // 加载心情日记
        if let data = UserDefaults.standard.data(forKey: moodEntriesKey),
           let entries = try? JSONDecoder().decode([MoodEntry].self, from: data) {
            self.moodEntries = entries.sorted { $0.date > $1.date }
            print("📂 加载了 \(entries.count) 条心情日记")
        } else {
            // 如果没有数据，创建一些示例数据用于演示
            createSampleData()
        }
        
        // 加载自定义活动
        if let data = UserDefaults.standard.data(forKey: customActivitiesKey),
           let activities = try? JSONDecoder().decode([Activity].self, from: data) {
            self.customActivities = activities
            print("📂 加载了 \(activities.count) 个自定义活动")
        }
        
        // 加载当前主题
        if let data = UserDefaults.standard.data(forKey: currentThemeKey),
           let theme = try? JSONDecoder().decode(ThemeModel.self, from: data) {
            self.currentTheme = theme
            print("🎨 加载当前主题: \(theme.name)")
        }
        
        // 加载已解锁主题
        if let themesArray = UserDefaults.standard.array(forKey: unlockedThemesKey) as? [String] {
            self.unlockedThemes = Set(themesArray)
            print("🔓 加载了 \(themesArray.count) 个已解锁主题")
        } else {
            // 默认解锁前三个主题
            self.unlockedThemes = ["default", "warm_orange", "calm_blue"]
            saveUnlockedThemes()
        }
        
        // 加载当前心情皮肤包
        if let data = UserDefaults.standard.data(forKey: currentMoodSkinPackKey),
           let skinPack = try? JSONDecoder().decode(MoodSkinPack.self, from: data) {
            self.currentMoodSkinPack = skinPack
            print("🎨 加载当前心情皮肤包: \(skinPack.name)")
        }
        
        // 加载已解锁心情皮肤包
        if let packsArray = UserDefaults.standard.array(forKey: unlockedMoodSkinPacksKey) as? [String] {
            self.unlockedMoodSkinPacks = Set(packsArray)
            print("🔓 加载了 \(packsArray.count) 个已解锁心情皮肤包")
        } else {
            // 默认解锁前两个皮肤包
            self.unlockedMoodSkinPacks = ["default_emoji", "cute_animals"]
            saveUnlockedMoodSkinPacks()
        }
    }
    
    // MARK: - 创建示例数据
    private func createSampleData() {
        let calendar = Calendar.current
        let now = Date()
        
        // 创建最近两周的示例数据
        var sampleEntries: [MoodEntry] = []
        
        for i in 0..<14 {
            if let date = calendar.date(byAdding: .day, value: -13 + i, to: now) {
                // 随机心情等级，但有一定趋势
                let baseMood = 3
                let variation = Int.random(in: -1...1)
                let moodLevel = max(1, min(5, baseMood + variation))
                
                // 随机选择1-3个活动
                let allActivities = Activity.predefinedActivities
                let activityCount = Int.random(in: 1...3)
                let selectedActivities = Array(allActivities.shuffled().prefix(activityCount))
                
                // 部分日期添加备注
                let notes = [
                    "今天天气很好",
                    "和朋友聊天很开心",
                    "散步后心情不错",
                    "今天比较累",
                    nil, nil, nil // 部分没有备注
                ]
                let note = notes.randomElement() ?? nil
                
                let entry = MoodEntry(
                    date: date,
                    moodLevel: moodLevel,
                    activities: selectedActivities,
                    note: note
                )
                
                sampleEntries.append(entry)
            }
        }
        
        self.moodEntries = sampleEntries.sorted { $0.date > $1.date }
        saveMoodEntries()
        print("📝 创建了 \(sampleEntries.count) 条示例心情日记")
    }
    
    // MARK: - 用户配置管理
    func updateUserProfile(_ profile: UserProfile) {
        self.userProfile = profile
        saveUserProfile()
        print("👤 更新用户配置")
    }
    
    // 更新通知设置
    func updateNotificationSettings(dailyReminder: Bool, reminderTime: Date, weeklyReview: Bool, healthTips: Bool) {
        var updatedProfile = userProfile
        updatedProfile.enableDailyReminder = dailyReminder
        updatedProfile.dailyReminderTime = reminderTime
        updatedProfile.enableWeeklyReview = weeklyReview
        updatedProfile.enableHealthTips = healthTips
        updatedProfile.updatedAt = Date()
        
        updateUserProfile(updatedProfile)
        print("🔔 更新通知设置: 每日提醒 \(dailyReminder), 周回顾 \(weeklyReview)")
    }
    
    // 更新触感设置
    func updateHapticSettings(enabled: Bool, intensity: Double) {
        var updatedProfile = userProfile
        updatedProfile.enableHapticFeedback = enabled
        updatedProfile.hapticIntensity = intensity
        updatedProfile.updatedAt = Date()
        
        updateUserProfile(updatedProfile)
        print("📳 更新触感设置: 启用 \(enabled), 强度 \(intensity)")
    }
    
    private func saveUserProfile() {
        if let data = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(data, forKey: userProfileKey)
            print("💾 保存用户配置成功")
        }
    }
    
    // MARK: - 心情日记管理
    func addMoodEntry(_ entry: MoodEntry) {
        moodEntries.insert(entry, at: 0) // 最新的在前面
        saveMoodEntries()
        print("📝 添加心情日记: \(entry.moodDescription)")
    }
    
    func updateMoodEntry(_ entry: MoodEntry) {
        if let index = moodEntries.firstIndex(where: { $0.id == entry.id }) {
            moodEntries[index] = entry
            saveMoodEntries()
            print("✏️ 更新心情日记: \(entry.moodDescription)")
        }
    }
    
    func deleteMoodEntry(_ entry: MoodEntry) {
        moodEntries.removeAll { $0.id == entry.id }
        saveMoodEntries()
        print("🗑️ 删除心情日记: \(entry.moodDescription)")
    }
    
    private func saveMoodEntries() {
        if let data = try? JSONEncoder().encode(moodEntries) {
            UserDefaults.standard.set(data, forKey: moodEntriesKey)
            print("💾 保存心情日记成功，共 \(moodEntries.count) 条")
        }
    }
    
    // MARK: - 自定义活动管理
    func addCustomActivity(_ activity: Activity) {
        customActivities.append(activity)
        saveCustomActivities()
        print("🎯 添加自定义活动: \(activity.name)，当前自定义活动总数: \(customActivities.count)")
        print("🎯 活动详情: 分类=\(activity.category.rawValue), 图标=\(activity.icon), isCustom=\(activity.isCustom)")
        
        // 触发UI更新（强制刷新）
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    func deleteCustomActivity(_ activity: Activity) {
        customActivities.removeAll { $0.id == activity.id }
        saveCustomActivities()
        print("🗑️ 删除自定义活动: \(activity.name)")
    }
    
    private func saveCustomActivities() {
        if let data = try? JSONEncoder().encode(customActivities) {
            UserDefaults.standard.set(data, forKey: customActivitiesKey)
            print("💾 保存自定义活动成功，共 \(customActivities.count) 个")
        }
    }
    
    // MARK: - 获取所有可用活动
    func getAllActivities() -> [Activity] {
        let allActivities = Activity.predefinedActivities + customActivities
        print("📋 获取所有活动: 预定义=\(Activity.predefinedActivities.count), 自定义=\(customActivities.count), 总计=\(allActivities.count)")
        return allActivities
    }
    
    // 调试方法：打印当前自定义活动状态
    func debugCustomActivities() {
        print("🔍 调试自定义活动状态:")
        print("   - 自定义活动数量: \(customActivities.count)")
        for (index, activity) in customActivities.enumerated() {
            print("   - [\(index)] \(activity.name) (分类: \(activity.category.rawValue), 图标: \(activity.icon))")
        }
    }
    
    // 检查活动显示限制情况
    func checkActivityDisplayStatus() {
        let totalActivities = getAllActivities().count
        let customCount = customActivities.count
        let predefinedCount = Activity.predefinedActivities.count
        
        print("📊 活动显示状态检查:")
        print("   - 总活动数: \(totalActivities) (自定义: \(customCount), 预定义: \(predefinedCount))")
        print("   - 最大显示数: 19 + 1个新建按钮 = 20个")
        
        if customCount > 19 {
            print("   ⚠️ 警告: 自定义活动数量(\(customCount))超过最大显示限制(19)，部分活动将不会显示")
        } else {
            let remainingSlots = 19 - customCount
            print("   ✅ 可显示所有自定义活动，剩余 \(remainingSlots) 个位置给预定义活动")
        }
    }
    
    // MARK: - 数据统计
    func getMoodStatistics(for period: StatisticsPeriod = .week) -> MoodStatistics {
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date
        
        switch period {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        }
        
        let filteredEntries = moodEntries.filter { $0.date >= startDate }
        
        let averageMood = filteredEntries.isEmpty ? 0.0 : 
            Double(filteredEntries.map { $0.moodLevel }.reduce(0, +)) / Double(filteredEntries.count)
        
        let moodCounts = Dictionary(grouping: filteredEntries, by: { $0.moodLevel })
            .mapValues { $0.count }
        
        print("📊 生成心情统计: 平均心情 \(String(format: "%.1f", averageMood))")
        
        return MoodStatistics(
            period: period,
            averageMood: averageMood,
            totalEntries: filteredEntries.count,
            moodCounts: moodCounts,
            entries: filteredEntries
        )
    }
    
    // MARK: - 主题管理
    func applyTheme(_ theme: ThemeModel) {
        guard unlockedThemes.contains(theme.id) else {
            print("❌ 主题未解锁: \(theme.name)")
            return
        }
        
        self.currentTheme = theme
        saveCurrentTheme()
        print("🎨 应用主题: \(theme.name)")
    }
    
    func unlockTheme(_ theme: ThemeModel) {
        unlockedThemes.insert(theme.id)
        saveUnlockedThemes()
        print("🔓 解锁主题: \(theme.name)")
    }
    
    func isThemeUnlocked(_ theme: ThemeModel) -> Bool {
        return unlockedThemes.contains(theme.id)
    }
    
    private func saveCurrentTheme() {
        if let data = try? JSONEncoder().encode(currentTheme) {
            UserDefaults.standard.set(data, forKey: currentThemeKey)
            print("💾 保存当前主题成功")
        }
    }
    
    private func saveUnlockedThemes() {
        let themesArray = Array(unlockedThemes)
        UserDefaults.standard.set(themesArray, forKey: unlockedThemesKey)
        print("💾 保存已解锁主题成功")
    }
    
    // MARK: - 心情皮肤包管理
    func applyMoodSkinPack(_ skinPack: MoodSkinPack) {
        guard unlockedMoodSkinPacks.contains(skinPack.id) else {
            print("❌ 心情皮肤包未解锁: \(skinPack.name)")
            return
        }
        
        self.currentMoodSkinPack = skinPack
        saveCurrentMoodSkinPack()
        print("🎨 应用心情皮肤包: \(skinPack.name)")
    }
    
    func unlockMoodSkinPack(_ skinPack: MoodSkinPack) {
        unlockedMoodSkinPacks.insert(skinPack.id)
        saveUnlockedMoodSkinPacks()
        print("🔓 解锁心情皮肤包: \(skinPack.name)")
    }
    
    func isMoodSkinPackUnlocked(_ skinPack: MoodSkinPack) -> Bool {
        return unlockedMoodSkinPacks.contains(skinPack.id)
    }
    
    private func saveCurrentMoodSkinPack() {
        if let data = try? JSONEncoder().encode(currentMoodSkinPack) {
            UserDefaults.standard.set(data, forKey: currentMoodSkinPackKey)
            print("💾 保存当前心情皮肤包成功")
        }
    }
    
    private func saveUnlockedMoodSkinPacks() {
        let packsArray = Array(unlockedMoodSkinPacks)
        UserDefaults.standard.set(packsArray, forKey: unlockedMoodSkinPacksKey)
        print("💾 保存已解锁心情皮肤包成功")
    }
    
    // 获取指定心情等级的显示内容（使用当前皮肤包）
    func getMoodDisplay(for level: Int) -> String {
        return currentMoodSkinPack.getMoodEmoji(for: level)
    }
    
    // 获取按分类筛选的皮肤包
    func getMoodSkinPacks(for category: SkinPackCategory) -> [MoodSkinPack] {
        if category == .all {
            return MoodSkinPack.availablePacks
        } else {
            return MoodSkinPack.availablePacks.filter { $0.category == category.rawValue }
        }
    }
    
    // MARK: - 数据导出功能
    func exportDataAsJSON() -> String {
        let exportData = [
            "userProfile": userProfile,
            "moodEntries": moodEntries,
            "customActivities": customActivities,
            "exportDate": Date()
        ] as [String : Any]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📤 数据导出成功，共 \(moodEntries.count) 条心情记录")
                return jsonString
            }
        } catch {
            print("❌ 数据导出失败: \(error)")
        }
        
        return ""
    }
    
    // 计算数据统计摘要
    func getDataSummary() -> [String: Any] {
        let totalEntries = moodEntries.count
        let averageMood = totalEntries > 0 ? Double(moodEntries.map { $0.moodLevel }.reduce(0, +)) / Double(totalEntries) : 0.0
        let dateRange = getDateRange()
        
        return [
            "totalEntries": totalEntries,
            "averageMood": averageMood,
            "dateRange": dateRange,
            "customActivitiesCount": customActivities.count,
            "isPremium": userProfile.isPremium
        ]
    }
    
    private func getDateRange() -> String {
        guard !moodEntries.isEmpty else { return "无数据" }
        
        let sortedEntries = moodEntries.sorted { $0.date < $1.date }
        let startDate = sortedEntries.first?.date ?? Date()
        let endDate = sortedEntries.last?.date ?? Date()
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年MM月dd日"
        
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
    
    // MARK: - 媒体文件管理
    
    // 保存图片到文档目录
    func saveImage(_ image: UIImage) -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filename = "mood_image_\(Date().timeIntervalSince1970).jpg"
        let fileURL = documentsPath.appendingPathComponent(filename)
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ 图片数据转换失败")
            return nil
        }
        
        do {
            try imageData.write(to: fileURL)
            print("📸 图片保存成功: \(filename)")
            return fileURL
        } catch {
            print("❌ 图片保存失败: \(error)")
            return nil
        }
    }
    
    // 删除媒体文件
    func deleteMediaFile(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            print("🗑️ 删除媒体文件成功: \(url.lastPathComponent)")
        } catch {
            print("❌ 删除媒体文件失败: \(error)")
        }
    }
    
    // 获取媒体文件大小
    func getMediaFileSize(at url: URL) -> String {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let size = attributes[.size] as? NSNumber {
                let bytes = size.doubleValue
                let formatter = ByteCountFormatter()
                formatter.allowedUnits = [.useKB, .useMB]
                formatter.countStyle = .file
                return formatter.string(fromByteCount: Int64(bytes))
            }
        } catch {
            print("❌ 获取文件大小失败: \(error)")
        }
        return "未知"
    }
    
    // 清理孤立的媒体文件（没有被任何心情日记引用的文件）
    func cleanupOrphanedMediaFiles() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsPath, 
                                                                       includingPropertiesForKeys: nil)
            
            // 获取所有被引用的媒体文件URL
            var referencedURLs = Set<URL>()
            for entry in moodEntries {
                if let audioURL = entry.audioURL {
                    referencedURLs.insert(audioURL)
                }
                if let imageURL = entry.imageURL {
                    referencedURLs.insert(imageURL)
                }
            }
            
            // 删除未被引用的媒体文件
            var deletedCount = 0
            for fileURL in fileURLs {
                let filename = fileURL.lastPathComponent
                if (filename.hasPrefix("mood_image_") || filename.hasPrefix("recording_")) 
                   && !referencedURLs.contains(fileURL) {
                    try FileManager.default.removeItem(at: fileURL)
                    deletedCount += 1
                    print("🗑️ 清理孤立文件: \(filename)")
                }
            }
            
            print("✅ 媒体文件清理完成，删除了 \(deletedCount) 个孤立文件")
            
        } catch {
            print("❌ 媒体文件清理失败: \(error)")
        }
    }
}

// MARK: - 统计相关模型
enum StatisticsPeriod: String, CaseIterable {
    case week = "本周"
    case month = "本月"  
    case year = "本年"
}

struct MoodStatistics {
    let period: StatisticsPeriod
    let averageMood: Double
    let totalEntries: Int
    let moodCounts: [Int: Int]
    let entries: [MoodEntry]
    
    var moodStability: Double {
        guard !entries.isEmpty else { return 0.0 }
        
        let moods = entries.map { Double($0.moodLevel) }
        let avg = averageMood
        let variance = moods.map { pow($0 - avg, 2) }.reduce(0, +) / Double(moods.count)
        let standardDeviation = sqrt(variance)
        
        // 转换为稳定性分数 (0-1)，越接近1越稳定
        return max(0, 1 - (standardDeviation / 2.0))
    }
} 