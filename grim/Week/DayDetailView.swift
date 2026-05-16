import SwiftUI

struct DayDetailView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var userData = UserData.shared
    @Environment(\.dismiss) private var dismiss
    let date: Date

    @State private var newTaskText = ""
    @FocusState private var inputFocused: Bool

    private let calendar = Calendar.current

    private var isToday: Bool { calendar.isDateInToday(date) }
    private var isPast: Bool { !isToday && date < calendar.startOfDay(for: Date()) }

    private var headerLabel: String {
        date.formatted(.dateTime.weekday(.wide).month(.wide).day())
    }

    private var prompt: String {
        if isToday { return "what will you do with today?" }
        if isPast  { return "what did you do on \(date.formatted(.dateTime.weekday(.wide)).lowercased())?" }
        return "what will you do on \(date.formatted(.dateTime.weekday(.wide)).lowercased())?"
    }

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
                        Text(headerLabel.lowercased())
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
                    .padding(.bottom, 28)
                }
                .frame(maxWidth: .infinity)

                // Prompt
                Text(prompt)
                    .font(Theme.fontLabel)
                    .foregroundColor(Theme.muted.opacity(0.5))
                    .padding(.horizontal, 28)
                    .padding(.bottom, 28)

                // Task list
                let tasks = userData.tasksForDate(date)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        if tasks.isEmpty {
                            Text("nothing yet.")
                                .font(Theme.fontLabel)
                                .foregroundColor(Theme.muted.opacity(0.3))
                                .padding(.horizontal, 28)
                                .padding(.vertical, 10)
                        } else {
                            ForEach(tasks) { task in
                                HStack(alignment: .top, spacing: 14) {
                                    Circle()
                                        .fill(isToday ? Theme.accent : Theme.muted)
                                        .frame(width: 4, height: 4)
                                        .padding(.top, 5)
                                    Text(task.text)
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
                                        withAnimation { userData.removeTask(task, for: date) }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }

                Spacer()

                // Input
                HStack(spacing: 0) {
                    TextField("add something...", text: $newTaskText)
                        .font(Theme.fontLabel)
                        .foregroundColor(Theme.ink)
                        .tint(Theme.accent)
                        .focused($inputFocused)
                        .submitLabel(.done)
                        .onSubmit { addTask() }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 18)

                    Button(action: addTask) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(newTaskText.isEmpty ? Theme.muted : Theme.ink)
                            .padding(.trailing, 24)
                    }
                    .disabled(newTaskText.isEmpty)
                }
                .overlay(Rectangle().stroke(Theme.border, lineWidth: 1))
                .padding(.horizontal, 28)
                .padding(.bottom, 48)
            }
        }
    }

    private func addTask() {
        let text = newTaskText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        let haptic = UIImpactFeedbackGenerator(style: .light)
        haptic.impactOccurred()
        withAnimation { userData.addTask(text, for: date) }
        newTaskText = ""
        inputFocused = false
    }
}
