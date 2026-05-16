import SwiftUI
import WidgetKit
import AppIntents

struct LockScreenCircularView: View {
    var entry: LiveMoreEntry

    var body: some View {
        if #available(iOS 17, *) {
            Button(intent: CycleDisplayUnit()) { circularContent }
                .buttonStyle(.plain)
        } else {
            circularContent
        }
    }

    private var circularContent: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Text(displayValue)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text(displayLabel)
                    .font(.system(size: 7, weight: .regular, design: .monospaced))
                    .opacity(0.6)
            }
        }
    }

    private var displayValue: String {
        switch entry.widgetDisplayUnit {
        case "weeks": return "\(entry.weeksRemaining)"
        case "years": return String(format: "%.1f", entry.yearsRemaining)
        default:      return compactDays(entry.daysRemaining)
        }
    }

    private var displayLabel: String {
        switch entry.widgetDisplayUnit {
        case "weeks": return "weeks"
        case "years": return "years"
        default:      return "days"
        }
    }
}

struct LockScreenRectangularView: View {
    var entry: LiveMoreEntry

    var body: some View {
        if #available(iOS 17, *) {
            Button(intent: CycleDisplayUnit()) { rectangularContent }
                .buttonStyle(.plain)
        } else {
            rectangularContent
        }
    }

    private var rectangularContent: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 1) {
                Text(displayValue)
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text(displayLabel)
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

    private var displayValue: String {
        switch entry.widgetDisplayUnit {
        case "weeks": return entry.weeksRemaining.formatted()
        case "years": return String(format: "%.1f", entry.yearsRemaining)
        default:      return entry.daysRemaining.formatted()
        }
    }

    private var displayLabel: String {
        switch entry.widgetDisplayUnit {
        case "weeks": return "weeks remaining"
        case "years": return "years remaining"
        default:      return "days remaining"
        }
    }
}
