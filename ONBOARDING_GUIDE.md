# 心情日记 - 问卷调查功能开发指南

## 功能概述

为心情日记应用开发了完整的Onboarding问卷调查功能，专门为老年用户设计，采用适老化界面和交互方式。

## 主要特性

### 🎯 适老化设计
- **大字体显示**：使用 AppTheme.Fonts 确保文字清晰易读
- **高对比度**：主要使用浅墨绿色主题，便于老年人识别
- **简洁布局**：每屏一个主要任务，避免复杂操作
- **大按钮设计**：所有交互元素都采用大尺寸，便于点击

### 📋 问卷调查步骤

1. **欢迎页面** - 应用介绍和功能说明
2. **性别选择** - 男性/女性/其他选项
3. **心情皮肤选择** - 选择喜欢的心情表达方式
4. **显示模式** - 浅色/深色/跟随系统
5. **兴趣爱好** - 多选兴趣类别（运动、阅读、音乐等）
6. **生日设置** - 日期选择器
7. **健康提醒** - 每日提醒和健康贴士设置
8. **推送通知** - 请求通知权限
9. **完成页面** - 设置完成确认

### 🔧 技术实现

#### 核心组件

**OnboardingModel.swift**
- `OnboardingStep` 枚举：定义所有问卷步骤
- `ColorSchemeOption` 枚举：显示模式选项
- `OnboardingData` 类：管理问卷数据状态

**OnboardingView.swift**
- 主要的问卷调查视图
- 包含进度指示器和步骤切换动画
- 自动保存数据到 DataManager

**OnboardingStepViews.swift**
- 所有步骤的子视图实现
- 使用 `OnboardingStepContainer` 统一布局
- 支持数据双向绑定

#### 数据流程

```
OnboardingData → UserProfile → DataManager → UserDefaults
```

1. 用户在问卷中做出选择
2. 数据存储在 `OnboardingData` 中
3. 完成时转换为 `UserProfile` 格式
4. 通过 `DataManager` 保存到本地
5. 设置 `OnboardingCompleted` 标记

### 🎨 界面设计

#### 视觉元素
- **进度条**：显示当前完成进度
- **步骤指示器**：第 X 步，共 Y 步
- **流畅动画**：左右滑动切换效果
- **图标展示**：每个选项都有对应的 SF Symbols 图标

#### 交互模式
- **单选题**：性别、显示模式、皮肤选择
- **多选题**：兴趣爱好（支持多选）
- **日期选择**：生日和提醒时间
- **开关控制**：各种提醒设置

### 🔄 状态管理

#### 前进/后退逻辑
- `canMoveNext` 属性检查当前步骤是否完成
- 必填项未完成时禁用"继续"按钮
- 支持返回上一步修改选择

#### 数据验证
```swift
var canMoveNext: Bool {
    switch currentStep {
    case .gender:
        return selectedGender != nil
    case .moodSkinSelection:
        return selectedMoodSkinPack != nil
    case .interests:
        return selectedInterests.count > 0
    // ... 其他验证逻辑
    }
}
```

### 🚀 启动流程

#### 检查逻辑
```swift
private func checkOnboardingStatus() {
    let onboardingCompleted = UserDefaults.standard.bool(forKey: "OnboardingCompleted")
    let profileCompleted = dataManager.userProfile.isOnboardingCompleted
    
    showingOnboarding = !onboardingCompleted || !profileCompleted
}
```

#### ContentView 集成
- 应用启动时自动检查是否需要显示问卷
- 首次使用或用户配置不完整时显示 Onboarding
- 完成后直接跳转到主界面

### 📱 推送通知

#### 权限请求
```swift
private func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        DispatchQueue.main.async {
            pushNotificationEnabled = granted
        }
    }
}
```

### 🎯 用户体验优化

#### 适老化特性
1. **清晰的步骤说明**：每个页面都有标题和副标题说明
2. **视觉反馈**：选中状态有明显的颜色和图标变化
3. **错误预防**：必填项验证，防止用户跳过重要设置
4. **进度可见**：实时显示完成进度和剩余步骤

#### 无障碍支持
- 所有元素支持 VoiceOver
- 合理的内容分组和标签
- 键盘导航支持

### 🔧 开发和测试

#### Preview 支持
```swift
#Preview("欢迎页面") {
    WelcomeStepView()
}

#Preview("完整流程") {
    OnboardingTestView()
}
```

#### 调试日志
- 每个步骤切换都有详细日志
- 数据保存和加载过程可追踪
- 通知权限请求结果记录

### 📝 使用说明

#### 开发者使用
1. 在 ContentView 中自动检查 Onboarding 状态
2. 首次启动或配置不完整时自动显示
3. 用户完成后自动跳转到主界面

#### 数据访问
```swift
// 检查用户是否完成了问卷
let isCompleted = dataManager.userProfile.isOnboardingCompleted

// 获取用户选择的设置
let gender = dataManager.userProfile.gender
let interests = dataManager.userProfile.interestedCategories
let skinPack = dataManager.userProfile.selectedMoodSkinPack
```

### 🎉 成果总结

✅ **完成的功能**
- 9个完整的问卷调查步骤
- 适老化界面设计
- 数据验证和状态管理
- 流畅的切换动画
- 完整的数据保存流程
- 推送通知权限请求
- Preview 和调试支持

✅ **技术亮点**
- SwiftUI 响应式设计
- MVVM 架构模式
- 环境对象数据流
- 适老化设计原则
- 无障碍功能支持

这个问卷调查功能为老年用户提供了友好的初始设置体验，确保他们能够轻松完成应用的个性化配置。 