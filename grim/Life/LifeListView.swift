import SwiftUI

struct LifeListView: View {
    @StateObject private var userData = UserData.shared
    @Environment(\.dismiss) private var dismiss
    @State private var newItemText = ""
    @State private var isGenerating = false
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
                    .padding(.bottom, 32)
                }
                .frame(maxWidth: .infinity)

                // Daily prompt
                if !userData.lifeItems.isEmpty {
                    dailyPromptSection
                        .padding(.horizontal, 28)
                        .padding(.bottom, 32)
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

                                Text(item.text)
                                    .font(Theme.fontLabel)
                                    .foregroundColor(Theme.ink)
                                    .multilineTextAlignment(.leading)

                                Spacer()
                            }
                            .padding(.horizontal, 28)
                            .padding(.vertical, 10)
                            .contentShape(Rectangle())
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        userData.removeLifeItem(item)
                                        refreshPromptIfNeeded()
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
        .onAppear { refreshPromptIfNeeded() }
    }

    // MARK: - Daily prompt

    private var dailyPromptSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("today")
                .font(Theme.fontLabel)
                .foregroundColor(Theme.muted)

            if isGenerating {
                HStack(spacing: 8) {
                    ProgressView()
                        .tint(Theme.muted)
                        .scaleEffect(0.7)
                    Text("thinking...")
                        .font(Theme.fontLabel)
                        .foregroundColor(Theme.muted)
                }
            } else if let prompt = userData.dailyPromptText, !prompt.isEmpty {
                Text(prompt)
                    .font(Theme.fontLabel)
                    .foregroundColor(Theme.ink)
                    .lineSpacing(5)

                Button {
                    regeneratePrompt()
                } label: {
                    Text("refresh →")
                        .font(Theme.fontLabel)
                        .foregroundColor(Theme.muted.opacity(0.5))
                }
                .padding(.top, 2)
            } else {
                Text("no suggestion yet — add items to your list.")
                    .font(Theme.fontLabel)
                    .foregroundColor(Theme.muted)
            }
        }
        .padding(20)
        .overlay(Rectangle().stroke(Theme.border, lineWidth: 1))
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
        regeneratePrompt()
    }

    private func refreshPromptIfNeeded() {
        guard !userData.lifeItems.isEmpty else { return }

        let today = Calendar.current.startOfDay(for: Date())
        if let cached = userData.dailyPromptDate,
           Calendar.current.isDate(cached, inSameDayAs: today),
           let text = userData.dailyPromptText, !text.isEmpty {
            return
        }
        regeneratePrompt()
    }

    private func regeneratePrompt() {
        guard !userData.lifeItems.isEmpty else { return }
        isGenerating = true
        AnthropicService.generateDailyPrompt(
            items: userData.lifeItems,
            dob: userData.dateOfBirth,
            lifeExpectancy: userData.lifeExpectancy
        ) { result in
            isGenerating = false
            if let result {
                userData.dailyPromptText = result
                userData.dailyPromptDate = Date()
                userData.save()
            }
        }
    }
}
