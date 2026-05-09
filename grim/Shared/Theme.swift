import SwiftUI

struct ColorPalette: Identifiable {
    let id: String
    let name: String
    let background: Color
    let surface: Color
    let ink: Color
    let muted: Color
    let border: Color
    let accent: Color

    static let all: [ColorPalette] = [ember, steel, moss, dusk, bone]

    static let ember = ColorPalette(
        id: "ember", name: "ember",
        background: Color(hex: "#0a0a0a"), surface: Color(hex: "#1a1a1a"),
        ink: Color(hex: "#f0ece0"), muted: Color(hex: "#555555"),
        border: Color(hex: "#222222"), accent: Color(hex: "#e8a045")
    )
    static let steel = ColorPalette(
        id: "steel", name: "steel",
        background: Color(hex: "#09090f"), surface: Color(hex: "#13131e"),
        ink: Color(hex: "#e8edf5"), muted: Color(hex: "#505870"),
        border: Color(hex: "#1c1c2e"), accent: Color(hex: "#5b8dd9")
    )
    static let moss = ColorPalette(
        id: "moss", name: "moss",
        background: Color(hex: "#080d09"), surface: Color(hex: "#111a12"),
        ink: Color(hex: "#e5f0e6"), muted: Color(hex: "#4a6650"),
        border: Color(hex: "#182219"), accent: Color(hex: "#5db85d")
    )
    static let dusk = ColorPalette(
        id: "dusk", name: "dusk",
        background: Color(hex: "#0b0910"), surface: Color(hex: "#181220"),
        ink: Color(hex: "#ede8f5"), muted: Color(hex: "#5a4d6a"),
        border: Color(hex: "#231a30"), accent: Color(hex: "#9d70e0")
    )
    static let bone = ColorPalette(
        id: "bone", name: "bone",
        background: Color(hex: "#f2ede0"), surface: Color(hex: "#e8e0cf"),
        ink: Color(hex: "#1a1814"), muted: Color(hex: "#8a806e"),
        border: Color(hex: "#d4cbb8"), accent: Color(hex: "#c17a30")
    )
}

enum Theme {
    static var background: Color { UserData.shared.selectedPalette.background }
    static var surface: Color    { UserData.shared.selectedPalette.surface }
    static var ink: Color        { UserData.shared.selectedPalette.ink }
    static var muted: Color      { UserData.shared.selectedPalette.muted }
    static var border: Color     { UserData.shared.selectedPalette.border }
    static var accent: Color     { UserData.shared.selectedPalette.accent }

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
