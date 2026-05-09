import SwiftUI
import WidgetKit

struct LockScreenCircularView: View {
    var entry: GrimEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Text(compactNumber(entry.daysRemaining))
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text("days")
                    .font(.system(size: 7, weight: .regular, design: .monospaced))
                    .opacity(0.6)
            }
        }
    }

    private func compactNumber(_ n: Int) -> String {
        if n >= 1000 { return "\(n / 1000)k" }
        return "\(n)"
    }
}

struct LockScreenRectangularView: View {
    var entry: GrimEntry

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 1) {
                Text(entry.daysRemaining.formatted())
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text("days remaining")
                    .font(.system(size: 8, weight: .regular, design: .monospaced))
                    .opacity(0.5)
            }
            Spacer()
            Text(String(format: "%.0f%%", entry.percentLived * 100))
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .opacity(0.7)
        }
        .padding(.horizontal, 4)
    }
}
