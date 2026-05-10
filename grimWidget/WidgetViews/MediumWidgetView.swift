import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    var entry: GrimEntry

    private var hpRemaining: Double { 1.0 - entry.percentLived }

    private var hpColor: Color {
        if hpRemaining > 0.5 { return Color(hex: "#4ade80") }
        if hpRemaining > 0.2 { return Color(hex: "#e8a045") }
        return Color(hex: "#ef4444")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(entry.daysRemaining.formatted())
                        .font(.custom("Helvetica", size: 102))
                        .foregroundColor(Color(hex: "#f0ece0"))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Text("days remaining")
                        .font(.system(size: 9, weight: .regular, design: .monospaced))
                        .foregroundColor(Color(hex: "#555555"))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    statItem(value: entry.weeksRemaining.formatted(), label: "weeks")
                    statItem(value: String(format: "%.1f", entry.yearsRemaining), label: "years")
                    statItem(
                        value: String(format: "%.0f%%", entry.percentLived * 100),
                        label: "lived",
                        highlight: true
                    )
                }
            }

            Spacer()

            // HP bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color(hex: "#1a1a1a"))
                    Rectangle().fill(hpColor).frame(width: geo.size.width * hpRemaining)
                }
                .cornerRadius(1)
            }
            .frame(height: 5)
        }
        .padding(18)
    }

    private func statItem(value: String, label: String, highlight: Bool = false) -> some View {
        VStack(alignment: .trailing, spacing: 1) {
            Text(value)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundColor(highlight ? Color(hex: "#e8a045") : Color(hex: "#f0ece0"))
            Text(label)
                .font(.system(size: 8, weight: .regular, design: .monospaced))
                .foregroundColor(Color(hex: "#555555"))
        }
    }
}
