import SwiftUI

@main
struct grimApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
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
