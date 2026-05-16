import SwiftUI

enum Theme {
    private static var t: Double { ThemeManager.shared.brightness }

    // Dark endpoint RGB                 Light endpoint RGB
    static var background: Color { lerp((0.039, 0.039, 0.039), (0.961, 0.941, 0.910), t) }
    static var surface:    Color { lerp((0.102, 0.102, 0.102), (0.925, 0.910, 0.871), t) }
    static var ink:        Color { lerp((0.941, 0.925, 0.878), (0.102, 0.090, 0.063), t) }
    static var muted:      Color { lerp((0.533, 0.533, 0.533), (0.478, 0.439, 0.376), t) }
    static var border:     Color { lerp((0.180, 0.180, 0.180), (0.847, 0.827, 0.792), t) }
    static var accent:     Color { lerp((0.910, 0.627, 0.271), (0.788, 0.486, 0.118), t) }

    static let fontHero    = Font.system(size: 72, weight: .medium, design: .monospaced)
    static let fontDisplay = Font.system(size: 40, weight: .medium, design: .monospaced)
    static let fontMono    = Font.system(size: 22, weight: .medium, design: .monospaced)
    static let fontLabel   = Font.system(size: 11, weight: .regular, design: .monospaced)

    private static func lerp(_ dark: (Double, Double, Double), _ light: (Double, Double, Double), _ t: Double) -> Color {
        Color(.sRGB,
              red:   dark.0 + (light.0 - dark.0) * t,
              green: dark.1 + (light.1 - dark.1) * t,
              blue:  dark.2 + (light.2 - dark.2) * t)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
