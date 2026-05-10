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

            ZStack(alignment: .topTrailing) {

                // Number fills full width — fades on the right so stats remain legible
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.daysRemaining.formatted())
                        .font(.system(size: 250, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(hex: "#f0ece0"))
                        .minimumScaleFactor(0.1)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .mask(
                            LinearGradient(
                                stops: [
                                    .init(color: .black, location: 0),
                                    .init(color: .black, location: 0.28),
                                    .init(color: .clear,  location: 0.50)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("days remaining")
                        .font(.system(size: 9, weight: .regular, design: .monospaced))
                        .foregroundColor(Color(hex: "#555555"))
                }

                // Stats overlaid top-right
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
