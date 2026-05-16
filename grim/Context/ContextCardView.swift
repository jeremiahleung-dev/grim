import SwiftUI

struct ContextCardView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var userData = UserData.shared
    @State private var isRefreshing = false

    var body: some View {
        Button { refresh() } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text("today")
                    .font(Theme.fontLabel)
                    .foregroundColor(Theme.muted)

                if isRefreshing {
                    HStack(spacing: 8) {
                        ProgressView().tint(Theme.muted).scaleEffect(0.7)
                        Text("thinking...")
                            .font(Theme.fontLabel)
                            .foregroundColor(Theme.muted)
                    }
                } else if let briefing = userData.contextBriefing, !briefing.isEmpty {
                    Text(briefing)
                        .font(Theme.fontLabel)
                        .foregroundColor(Theme.ink.opacity(0.8))
                        .lineSpacing(4)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text("refresh →")
                        .font(Theme.fontLabel)
                        .foregroundColor(Theme.muted.opacity(0.5))
                        .padding(.top, 2)
                } else {
                    Text("tap to add things you want to do with your days →")
                        .font(Theme.fontLabel)
                        .foregroundColor(Theme.muted.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
        }
        .overlay(Rectangle().stroke(Theme.border, lineWidth: 1))
        .onAppear { refresh() }
    }

    private func refresh() {
        guard !isRefreshing else { return }
        isRefreshing = true
        AgentOrchestrator.shared.run(userData: userData) {
            isRefreshing = false
        }
    }
}
