import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    var entry: GrimEntry

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.daysRemaining.formatted())
                    .font(.system(size: 42, weight: .medium, design: .monospaced))
                    .foregroundColor(Color(hex: "#f0ece0"))
                    .minimumScaleFactor(0.4)
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
