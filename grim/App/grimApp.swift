import SwiftUI

@main
struct grimApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .onAppear {
                    let userData = UserData.shared
                    userData.updateStreak()
                    NotificationService.requestPermission()
                    scheduleWeeklyNotification(userData: userData)
                }
        }
    }

    private func scheduleWeeklyNotification(userData: UserData) {
        let calendar = Calendar.current
        let daysWithTasks = (0..<7).filter { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: Date()) else { return false }
            return !userData.tasksForDate(day).isEmpty
        }.count
        let daysRemaining = DateCalculator.daysRemaining(dob: userData.dateOfBirth, lifeExpectancy: userData.lifeExpectancy)
        NotificationService.scheduleWeeklyNotification(tasksThisWeek: daysWithTasks, daysRemaining: daysRemaining)
    }
}

struct RootView: View {
    @AppStorage("hasOnboarded", store: UserDefaults(suiteName: "group.com.grim.app"))
    private var hasOnboarded: Bool = false

    var body: some View {
        if hasOnboarded {
            ContentView()
        } else {
            OnboardingView()
        }
    }
}
