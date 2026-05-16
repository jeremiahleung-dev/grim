import SwiftUI

struct LifeListView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var userData = UserData.shared
    @Environment(\.dismiss) private var dismiss
    @State private var newItemText = ""
    @State private var isRefreshing = false
    @FocusState private var inputFocused: Bool

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Handle + header
                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.muted.opacity(0.3))
                        .frame(width: 36, height: 4)
                        .padding(.top, 12)
                        .padding(.bottom, 24)

                    HStack {
                        Text("your life list")
                            .font(Theme.fontLabel)
                            .foregroundColor(Theme.muted)
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Theme.muted)
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 24)
                }
                .frame(maxWidth: .infinity)

                // Today card — shown when list is non-empty
                if !userData.lifeItems.isEmpty {
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

                            Button { refreshPrompt() } label: {
                                Text("refresh →")
                                    .font(Theme.fontLabel)
                                    .foregroundColor(Theme.muted.opacity(0.5))
                            }
                            .padding(.top, 2)
                        } else {
                            Button { refreshPrompt() } label: {
                                Text("refresh →")
                                    .font(Theme.fontLabel)
                                    .foregroundColor(Theme.muted.opacity(0.5))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .overlay(Rectangle().stroke(Theme.border, lineWidth: 1))
                    .padding(.horizontal, 28)
                    .padding(.bottom, 24)
                }

                // List
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(userData.lifeItems) { item in
                            HStack(alignment: .top, spacing: 14) {
                                Circle()
                                    .fill(Theme.accent)
                                    .frame(width: 4, height: 4)
                                    .padding(.top, 5)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.text)
                                        .font(Theme.fontLabel)
                                        .foregroundColor(Theme.ink)
                                        .multilineTextAlignment(.leading)

                                    let days = daysSinceAdded(item)
                                    if days > 7 {
                                        Text("\(days)d")
                                            .font(.system(size: 10, weight: .regular, design: .monospaced))
                                            .foregroundColor(Theme.muted.opacity(0.35))
                                    }
                                }

                                Spacer()
                            }
                            .padding(.horizontal, 28)
                            .padding(.vertical, 10)
                            .contentShape(Rectangle())
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        userData.removeLifeItem(item)
                                        userData.contextBriefing = nil
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }

                Spacer()

                // Input
                HStack(spacing: 0) {
                    TextField("add something...", text: $newItemText)
                        .font(Theme.fontLabel)
                        .foregroundColor(Theme.ink)
                        .tint(Theme.accent)
                        .focused($inputFocused)
                        .submitLabel(.done)
                        .onSubmit { addItem() }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 18)

                    Button(action: addItem) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(newItemText.isEmpty ? Theme.muted : Theme.ink)
                            .padding(.trailing, 24)
                    }
                    .disabled(newItemText.isEmpty)
                }
                .overlay(Rectangle().stroke(Theme.border, lineWidth: 1))
                .padding(.horizontal, 28)
                .padding(.bottom, 48)
            }
        }
    }

    // MARK: - Actions

    private func addItem() {
        let text = newItemText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        let haptic = UIImpactFeedbackGenerator(style: .light)
        haptic.impactOccurred()
        withAnimation { userData.addLifeItem(text) }
        newItemText = ""
        inputFocused = false
        refreshPrompt()
    }

    private func refreshPrompt() {
        guard !isRefreshing else { return }
        isRefreshing = true
        AgentOrchestrator.shared.run(userData: userData) {
            isRefreshing = false
        }
    }

    private func daysSinceAdded(_ item: LifeItem) -> Int {
        Calendar.current.dateComponents([.day], from: item.createdAt, to: Date()).day ?? 0
    }
}
