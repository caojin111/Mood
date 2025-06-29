//
//  ContentView.swift
//  MoodJournalforSeniors
//
//  Created by LazyG on 2025/6/28.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager()
    @State private var showingOnboarding = false
    
    var body: some View {
        Group {
            if showingOnboarding {
                OnboardingView()
                    .environmentObject(dataManager)
            } else {
                MainTabView()
                    .environmentObject(dataManager)
            }
        }
        .onAppear {
            checkOnboardingStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OnboardingCompleted"))) { _ in
            print("📢 收到Onboarding完成通知")
            DispatchQueue.main.async {
                print("📢 在主线程中处理Onboarding完成通知")
                self.checkOnboardingStatus()
            }
        }
    }
    
    private func checkOnboardingStatus() {
        let onboardingCompleted = UserDefaults.standard.bool(forKey: "OnboardingCompleted")
        let profileCompleted = dataManager.userProfile.isOnboardingCompleted
        
        showingOnboarding = !onboardingCompleted || !profileCompleted
        
        print("🚀 检查Onboarding状态")
        print("  - UserDefaults标记: \(onboardingCompleted)")
        print("  - 用户配置完成: \(profileCompleted)")
        print("  - 显示Onboarding: \(showingOnboarding)")
    }
}

#Preview {
    ContentView()
}
