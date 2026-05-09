import SwiftUI

enum Theme {
    static let background = Color(hex: "#0a0a0a")
    static let surface    = Color(hex: "#1a1a1a")
    static let ink        = Color(hex: "#f0ece0")
    static let muted      = Color(hex: "#555555")
    static let border     = Color(hex: "#222222")
    static let accent     = Color(hex: "#e8a045")

    static let fontHero    = Font.system(size: 72, weight: .medium, design: .monospaced)
    static let fontDisplay = Font.system(size: 40, weight: .medium, design: .monospaced)
    static let fontMono    = Font.system(size: 22, weight: .medium, design: .monospaced)
    static let fontLabel   = Font.system(size: 11, weight: .regular, design: .monospaced)
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
