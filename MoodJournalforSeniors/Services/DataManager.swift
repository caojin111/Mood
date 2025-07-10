import Foundation
import SwiftUI
import UIKit

// MARK: - 导出格式枚举
enum ExportFormat {
    case pdf
    case csv
    
    var fileExtension: String {
        switch self {
        case .pdf: return "pdf"
        case .csv: return "csv"
        }
    }
    
    var mimeType: String {
        switch self {
        case .pdf: return "application/pdf"
        case .csv: return "text/csv"
        }
    }
    
    var displayName: String {
        switch self {
        case .pdf: return "PDF报告"
        case .csv: return "CSV表格"
        }
    }
}

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
    
    // 导出为CSV格式
    func exportDataAsCSV() -> String {
        print("📤 开始导出CSV格式数据")
        
        var csvContent = "日期,时间,心情等级,心情描述,活动,备注,包含语音,包含图片\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh_CN")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "zh_CN")
        timeFormatter.dateFormat = "HH:mm"
        
        for entry in moodEntries.sorted(by: { $0.date > $1.date }) {
            let date = dateFormatter.string(from: entry.date)
            let time = timeFormatter.string(from: entry.date)
            let activities = entry.activities.map { $0.name }.joined(separator: "; ")
            let note = entry.note?.replacingOccurrences(of: "\"", with: "\"\"") ?? ""
            let hasAudio = entry.audioURL != nil ? "是" : "否"
            let hasImage = entry.imageURL != nil ? "是" : "否"
            
            csvContent += "\"\(date)\",\"\(time)\",\(entry.moodLevel),\"\(entry.moodDescription)\",\"\(activities)\",\"\(note)\",\"\(hasAudio)\",\"\(hasImage)\"\n"
        }
        
        print("📤 CSV导出成功，共 \(moodEntries.count) 条记录")
        return csvContent
    }
    
    // 导出为PDF格式
    func exportDataAsPDF() -> Data? {
        print("📤 开始导出PDF格式数据，当前记录数: \(moodEntries.count)")
        
        // 检查是否有数据
        if moodEntries.isEmpty {
            print("⚠️ 没有心情记录数据，仍生成包含说明的PDF")
        }
        
        let pdfMetaData = [
            kCGPDFContextCreator: "心情日记应用",
            kCGPDFContextAuthor: getUserDisplayName(),
            kCGPDFContextTitle: "心情日记数据报告"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth: CGFloat = 8.5 * 72.0
        let pageHeight: CGFloat = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let margin: CGFloat = 50
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            var yPosition: CGFloat = margin
            let availableWidth = pageWidth - 2 * margin
            
            print("📄 开始绘制PDF页面，页面尺寸: \(pageWidth)x\(pageHeight)")
            
            // 开始新页面
            context.beginPage()
            
            // 标题
            yPosition = drawPDFTitle(in: pageRect, at: yPosition, margin: margin)
            
            // 用户信息
            yPosition = drawPDFUserInfo(in: pageRect, at: yPosition, margin: margin, availableWidth: availableWidth)
            
            // 统计概览
            yPosition = drawPDFStatistics(in: pageRect, at: yPosition, margin: margin, availableWidth: availableWidth)
            
            // 心情记录详情
            yPosition = drawPDFEntries(in: pageRect, at: yPosition, margin: margin, availableWidth: availableWidth, context: context)
            
            print("📄 PDF页面绘制完成，最终Y位置: \(yPosition)")
        }
        
        print("📤 PDF导出成功，文件大小: \(data.count) 字节")
        return data
    }
    
    // PDF标题绘制
    private func drawPDFTitle(in pageRect: CGRect, at yPosition: CGFloat, margin: CGFloat) -> CGFloat {
        print("📄 绘制PDF标题，Y位置: \(yPosition)")
        
        let titleText = "心情日记数据报告"
        let titleFont = UIFont.boldSystemFont(ofSize: 24)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.black
        ]
        
        let titleRect = CGRect(x: margin, y: yPosition, width: pageRect.width - 2 * margin, height: 30)
        titleText.draw(in: titleRect, withAttributes: titleAttributes)
        
        print("📄 标题绘制完成")
        return yPosition + 50
    }
    
    // PDF用户信息绘制
    private func drawPDFUserInfo(in pageRect: CGRect, at yPosition: CGFloat, margin: CGFloat, availableWidth: CGFloat) -> CGFloat {
        var currentY = yPosition
        let font = UIFont.systemFont(ofSize: 12)
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.black]
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh_CN")
        dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        
        let userInfo = [
            "用户: \(getUserDisplayName())",
            "导出时间: \(dateFormatter.string(from: Date()))",
            "记录总数: \(moodEntries.count) 条",
            "自定义活动: \(customActivities.count) 个"
        ]
        
        for info in userInfo {
            let rect = CGRect(x: margin, y: currentY, width: availableWidth, height: 20)
            info.draw(in: rect, withAttributes: attributes)
            currentY += 25
        }
        
        return currentY + 20
    }
    
    // PDF统计概览绘制
    private func drawPDFStatistics(in pageRect: CGRect, at yPosition: CGFloat, margin: CGFloat, availableWidth: CGFloat) -> CGFloat {
        print("📄 绘制统计概览，Y位置: \(yPosition)")
        
        var currentY = yPosition
        let titleFont = UIFont.boldSystemFont(ofSize: 16)
        let font = UIFont.systemFont(ofSize: 12)
        
        // 标题
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont, .foregroundColor: UIColor.black]
        let titleRect = CGRect(x: margin, y: currentY, width: availableWidth, height: 20)
        "数据统计概览".draw(in: titleRect, withAttributes: titleAttributes)
        currentY += 30
        
        // 统计数据
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.black]
        
        if moodEntries.isEmpty {
            // 没有数据时的显示
            let emptyStatistics = [
                "记录总数: 0 条",
                "平均心情评分: 暂无数据",
                "记录时间跨度: 暂无数据",
                "自定义活动: \(customActivities.count) 个"
            ]
            
            for stat in emptyStatistics {
                let rect = CGRect(x: margin, y: currentY, width: availableWidth, height: 20)
                stat.draw(in: rect, withAttributes: attributes)
                currentY += 25
            }
        } else {
            // 有数据时的正常统计
            let stats = getMoodStatistics(for: .year)
            let statistics = [
                "记录总数: \(moodEntries.count) 条",
                "平均心情评分: \(String(format: "%.1f", stats.averageMood))",
                "最好心情次数: \(stats.moodCounts[5] ?? 0) 次",
                "最差心情次数: \(stats.moodCounts[1] ?? 0) 次",
                "记录时间跨度: \(getDateRange())",
                "自定义活动: \(customActivities.count) 个"
            ]
            
            for stat in statistics {
                let rect = CGRect(x: margin, y: currentY, width: availableWidth, height: 20)
                stat.draw(in: rect, withAttributes: attributes)
                currentY += 25
            }
        }
        
        print("📄 统计概览绘制完成")
        return currentY + 30
    }
    
    // PDF心情记录详情绘制
    private func drawPDFEntries(in pageRect: CGRect, at yPosition: CGFloat, margin: CGFloat, availableWidth: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        print("📄 绘制心情记录详情，Y位置: \(yPosition)")
        
        var currentY = yPosition
        let titleFont = UIFont.boldSystemFont(ofSize: 16)
        let font = UIFont.systemFont(ofSize: 10)
        let pageHeight = pageRect.height
        
        // 标题
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont, .foregroundColor: UIColor.black]
        let titleRect = CGRect(x: margin, y: currentY, width: availableWidth, height: 20)
        "详细心情记录".draw(in: titleRect, withAttributes: titleAttributes)
        currentY += 30
        
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.black]
        
        if moodEntries.isEmpty {
            // 没有数据时显示提示信息
            let emptyMessage = "暂时还没有心情记录数据。\n\n开始记录您的第一份心情日记吧！"
            let rect = CGRect(x: margin, y: currentY, width: availableWidth, height: 60)
            emptyMessage.draw(in: rect, withAttributes: attributes)
            currentY += 80
            
            print("📄 显示空数据提示")
        } else {
            // 有数据时显示详细记录
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "zh_CN")
            dateFormatter.dateFormat = "MM-dd HH:mm"
            
            let sortedEntries = moodEntries.sorted { $0.date > $1.date }
            print("📄 开始绘制 \(sortedEntries.count) 条心情记录")
            
            for (index, entry) in sortedEntries.enumerated() {
                // 检查是否需要新页面
                if currentY > pageHeight - 100 {
                    print("📄 创建新页面，当前记录: \(index + 1)/\(sortedEntries.count)")
                    context.beginPage()
                    currentY = margin
                }
                
                let dateStr = dateFormatter.string(from: entry.date)
                let activities = entry.activities.map { $0.name }.joined(separator: ", ")
                let mediaInfo = buildMediaInfoString(entry: entry)
                
                let entryLines = [
                    "\(dateStr) - \(entry.moodDescription) (\(entry.moodLevel)/5)",
                    activities.isEmpty ? "无活动记录" : "活动: \(activities)",
                    entry.note?.isEmpty == false ? "备注: \(entry.note!)" : "无备注",
                    mediaInfo.isEmpty ? "无媒体文件" : mediaInfo
                ]
                
                for line in entryLines {
                    let rect = CGRect(x: margin, y: currentY, width: availableWidth, height: 15)
                    line.draw(in: rect, withAttributes: attributes)
                    currentY += 18
                }
                
                currentY += 10 // 记录间距
            }
            
            print("📄 所有记录绘制完成")
        }
        
        return currentY
    }
    
    // 构建媒体信息字符串
    private func buildMediaInfoString(entry: MoodEntry) -> String {
        var mediaInfo: [String] = []
        if entry.audioURL != nil {
            mediaInfo.append("包含语音")
        }
        if entry.imageURL != nil {
            mediaInfo.append("包含图片")
        }
        return mediaInfo.isEmpty ? "" : "媒体: \(mediaInfo.joined(separator: "、"))"
    }
    
    // 获取用户显示名称
    private func getUserDisplayName() -> String {
        var displayName = "心情日记用户"
        
        if let gender = userProfile.gender {
            if let age = userProfile.age {
                displayName = "\(age)岁\(gender.displayName)"
            } else {
                displayName = gender.displayName
            }
        }
        
        print("👤 生成用户显示名称: \(displayName)")
        return displayName
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