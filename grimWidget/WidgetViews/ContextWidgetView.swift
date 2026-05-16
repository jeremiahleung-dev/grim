import SwiftUI
import WidgetKit
import AppIntents

struct ContextSmallWidgetView: View {
    var entry: LiveMoreEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("right now")
                .font(.system(size: 8, weight: .regular, design: .monospaced))
                .foregroundColor(Color(hex: "#555555"))
                .padding(.bottom, 6)

            if let briefing = entry.contextBriefing, !briefing.isEmpty {
                Text(briefing)
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundColor(Color(hex: "#f0ece0"))
                    .lineSpacing(3)
                    .lineLimit(5)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("no suggestion yet")
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundColor(Color(hex: "#555555"))
            }

            Spacer()

            HStack {
                if entry.currentStreak >= 2 {
                    Text("\(entry.currentStreak)d streak")
                        .font(.system(size: 8, weight: .regular, design: .monospaced))
                        .foregroundColor(Color(hex: "#555555"))
                }
                Spacer()
                Circle()
                    .fill(Color(hex: "#e8a045"))
                    .frame(width: 4, height: 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(16)
    }
}

struct ContextMediumWidgetView: View {
    var entry: LiveMoreEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("right now")
                    .font(.system(size: 8, weight: .regular, design: .monospaced))
                    .foregroundColor(Color(hex: "#555555"))
                Spacer()
                Text(entry.daysRemaining.formatted() + " days left")
                    .font(.system(size: 8, weight: .regular, design: .monospaced))
                    .foregroundColor(Color(hex: "#555555"))
            }
            .padding(.bottom, 10)

            if let briefing = entry.contextBriefing, !briefing.isEmpty {
                Text(briefing)
                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                    .foregroundColor(Color(hex: "#f0ece0"))
                    .lineSpacing(4)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("no suggestion yet.\nopen more to life to generate one.")
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundColor(Color(hex: "#555555"))
                    .lineSpacing(3)
            }

            Spacer()

            if entry.currentStreak >= 2 {
                Text("\(entry.currentStreak) day streak")
                    .font(.system(size: 8, weight: .regular, design: .monospaced))
                    .foregroundColor(Color(hex: "#555555"))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(18)
    }
}

struct ContextLockScreenRectangularView: View {
    var entry: LiveMoreEntry

    var body: some View {
        if #available(iOS 17, *) {
            lockContent
                .buttonStyle(.plain)
        } else {
            lockContent
        }
    }

    private var lockContent: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("right now")
                .font(.system(size: 7, weight: .regular, design: .monospaced))
                .opacity(0.45)
            if let briefing = entry.contextBriefing, !briefing.isEmpty {
                Text(briefing)
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .lineLimit(2)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("open more to life to generate a suggestion")
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .opacity(0.5)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 4)
    }
}
