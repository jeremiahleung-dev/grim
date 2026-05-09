import SwiftUI
import WidgetKit

struct LargeWidgetView: View {
    var entry: GrimEntry

    private let cols = Array(repeating: GridItem(.fixed(5), spacing: 2), count: 52)

    var body: some View {
        ZStack {
            Color(hex: "#0a0a0a")

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.daysRemaining.formatted())
                            .font(.system(size: 36, weight: .medium, design: .monospaced))
                            .foregroundColor(Color(hex: "#f0ece0"))
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                        Text("days remaining")
                            .font(.system(size: 8, weight: .regular, design: .monospaced))
                            .foregroundColor(Color(hex: "#555555"))
                    }
                    Spacer()
                    Text(String(format: "%.1f%%", entry.percentLived * 100))
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(hex: "#e8a045"))
                }

                let totalWeeks = entry.lifeExpectancy * 52
                LazyVGrid(columns: cols, spacing: 2) {
                    ForEach(0..<min(totalWeeks, 52 * entry.lifeExpectancy), id: \.self) { i in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(dotColor(i))
                            .frame(width: 5, height: 5)
                    }
                }

                HStack(spacing: 12) {
                    legendItem(color: Color(hex: "#333333"), label: "lived")
                    legendItem(color: Color(hex: "#e8a045"), label: "now")
                    legendItem(color: Color(hex: "#1a1a1a"), label: "ahead")
                }
            }
            .padding(16)
        }
    }

    private func dotColor(_ i: Int) -> Color {
        if i < entry.weeksLived { return Color(hex: "#333333") }
        if i == entry.weeksLived { return Color(hex: "#e8a045") }
        return Color(hex: "#1a1a1a")
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 1)
                .fill(color)
                .frame(width: 5, height: 5)
            Text(label)
                .font(.system(size: 7, weight: .regular, design: .monospaced))
                .foregroundColor(Color(hex: "#555555"))
        }
    }
}
