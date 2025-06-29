import Foundation

// MARK: - 心情日记模型
struct MoodEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let moodLevel: Int // 1-5 (1=很差, 2=不好, 3=一般, 4=不错, 5=很好)
    let activities: [Activity]
    let note: String?
    let audioURL: URL?
    let imageURL: URL?
    let createdAt: Date
    let updatedAt: Date
    
    init(date: Date = Date(), 
         moodLevel: Int, 
         activities: [Activity] = [], 
         note: String? = nil, 
         audioURL: URL? = nil, 
         imageURL: URL? = nil) {
        self.id = UUID()
        self.date = date
        self.moodLevel = moodLevel
        self.activities = activities
        self.note = note
        self.audioURL = audioURL
        self.imageURL = imageURL
        self.createdAt = Date()
        self.updatedAt = Date()
        
        print("📝 创建新的心情日记: 心情等级 \(moodLevel)")
    }
    
    // 心情描述
    var moodDescription: String {
        switch moodLevel {
        case 1: return "很差"
        case 2: return "不好" 
        case 3: return "一般"
        case 4: return "不错"
        case 5: return "很好"
        default: return "未知"
        }
    }
    
    // 心情颜色（浅墨绿色系）
    var moodColor: String {
        switch moodLevel {
        case 1: return "mood_very_bad"     // 很淡的红色
        case 2: return "mood_bad"          // 淡橙色  
        case 3: return "mood_neutral"      // 淡黄色
        case 4: return "mood_good"         // 浅墨绿色
        case 5: return "mood_very_good"    // 深一点的墨绿色
        default: return "mood_neutral"
        }
    }
} 