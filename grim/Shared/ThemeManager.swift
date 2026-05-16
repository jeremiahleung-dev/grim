import SwiftUI

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var brightness: Double {
        didSet {
            UserDefaults(suiteName: "group.com.moretolife.app")?.set(brightness, forKey: "themeBrightness")
        }
    }

    var isDark: Bool { brightness < 0.5 }

    private init() {
        let defaults = UserDefaults(suiteName: "group.com.moretolife.app")
        if let stored = defaults?.object(forKey: "themeBrightness") as? Double {
            brightness = stored
        } else {
            // migrate legacy isDarkMode bool
            let legacyDark = defaults?.object(forKey: "isDarkMode") as? Bool ?? true
            brightness = legacyDark ? 0.0 : 1.0
        }
    }
}
