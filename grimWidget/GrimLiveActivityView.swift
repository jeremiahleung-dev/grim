import SwiftUI
import ActivityKit
import WidgetKit

@available(iOS 16.1, *)
struct LiveMoreLockScreenView: View {
    let context: ActivityViewContext<LiveMoreActivityAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(context.state.daysRemaining.formatted(.number))
                    .font(.system(size: 32, weight: .medium, design: .monospaced))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text("days")
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .opacity(0.5)
            }

            Spacer().frame(height: 12)

            Text(context.state.contextBriefing)
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .opacity(0.85)
                .lineLimit(2)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            Spacer().frame(height: 10)

            HStack {
                if context.state.streakCount >= 2 {
                    Text("\(context.state.streakCount) day streak")
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .opacity(0.35)
                }
                Spacer()
                Text(domainSymbol(context.state.domain))
                    .font(.system(size: 11, design: .monospaced))
                    .opacity(0.3)
            }
        }
        .padding(16)
        .foregroundColor(.white)
        .background(Color(hex: "#0a0a0a"))
    }
}

@available(iOS 16.1, *)
struct LiveMoreLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveMoreActivityAttributes.self) { context in
            LiveMoreLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(compactDays(context.state.daysRemaining))
                        .font(.system(size: 26, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(domainSymbol(context.state.domain))
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.trailing, 4)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.contextBriefing)
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                        .lineSpacing(3)
                        .padding(.horizontal, 4)
                        .padding(.bottom, 4)
                }
            } compactLeading: {
                Text(compactDays(context.state.daysRemaining))
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
            } compactTrailing: {
                Text(domainSymbol(context.state.domain))
                    .font(.system(size: 10, design: .monospaced))
                    .opacity(0.7)
            } minimal: {
                Text(compactDays(context.state.daysRemaining))
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
            }
        }
    }
}

func domainSymbol(_ domain: String) -> String {
    switch domain {
    case "health":      return "♥"
    case "social":      return "◉"
    case "calendar":    return "◻"
    case "environment": return "◈"
    default:            return "▪"
    }
}

func compactDays(_ n: Int) -> String {
    n >= 1000 ? "\(n / 1000)k" : "\(n)"
}
