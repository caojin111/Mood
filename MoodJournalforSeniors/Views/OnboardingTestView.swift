import SwiftUI

struct OnboardingTestView: View {
    @StateObject private var dataManager = DataManager()
    
    var body: some View {
        OnboardingView()
            .environmentObject(dataManager)
    }
}

#Preview {
    OnboardingTestView()
}

// 单独测试各个步骤的Preview
#Preview("欢迎页面") {
    WelcomeStepView()
        .environmentObject(OnboardingData())
}

#Preview("性别选择") {
    GenderSelectionStepView(selectedGender: .constant(nil))
        .environmentObject(DataManager())
}

#Preview("皮肤选择") {
    MoodSkinSelectionStepView(selectedSkinPack: .constant(nil))
        .environmentObject(DataManager())
}

#Preview("兴趣选择") {
    InterestsStepView(selectedInterests: .constant([]))
}

#Preview("生日选择") {
    BirthdayStepView(selectedBirthday: .constant(Date()))
}

// 测试数据状态的Preview  
#Preview("Paywall页面") {
    PaywallView()
        .environmentObject(OnboardingData())
        .environmentObject(DataManager())
} 