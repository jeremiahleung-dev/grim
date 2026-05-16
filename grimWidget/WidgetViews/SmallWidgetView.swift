import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    var entry: LiveMoreEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Spacer()
            Text(entry.daysRemaining.formatted())
                .font(.system(size: 28, weight: .medium, design: .monospaced))
                .foregroundColor(Color(hex: "#f0ece0"))
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            HStack(spacing: 4) {
                Text("days left")
                    .font(.system(size: 9, weight: .regular, design: .monospaced))
                    .foregroundColor(Color(hex: "#555555"))
                Spacer()
                Circle()
                    .fill(Color(hex: "#e8a045"))
                    .frame(width: 4, height: 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
    }
}
