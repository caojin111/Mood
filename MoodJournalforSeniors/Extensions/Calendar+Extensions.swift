import Foundation

// MARK: - Calendar 扩展
extension Calendar {
    /// 判断指定日期是否为今天
    func isToday(_ date: Date) -> Bool {
        return isDate(date, inSameDayAs: Date())
    }
    
    /// 判断指定日期是否为昨天
    func isYesterday(_ date: Date) -> Bool {
        guard let yesterday = self.date(byAdding: .day, value: -1, to: Date()) else {
            return false
        }
        return isDate(date, inSameDayAs: yesterday)
    }
} 