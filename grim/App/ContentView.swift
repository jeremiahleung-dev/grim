import SwiftUI

struct ContentView: View {
    @StateObject private var userData = UserData.shared
    @State private var displayUnit: DisplayUnit = .days
    @State private var showSettings = false
    @State private var showLifeList = false
    @State private var appeared = false
    @State private var dragOffset: CGFloat = 0
    @State private var selectedDay: Date?

    private let units = DisplayUnit.allCases

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            // Countdown — truly centered on screen
            VStack(alignment: .leading, spacing: 10) {
                Text(formattedCount)
                    .font(Theme.fontHero)
                    .foregroundColor(Theme.ink)
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)
                    .contentTransition(.numericText())

                Text(unitLabel)
                    .font(Theme.fontLabel)
                    .foregroundColor(Theme.muted)

                Text(todayLabel)
                    .font(Theme.fontLabel)
                    .foregroundColor(Theme.muted.opacity(0.45))

                HStack(spacing: 6) {
                    ForEach(units, id: \.self) { unit in
                        Circle()
                            .fill(unit == displayUnit ? Theme.muted : Theme.muted.opacity(0.25))
                            .frame(width: 4, height: 4)
                            .animation(.easeInOut(duration: 0.2), value: displayUnit)
                    }
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 28)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .offset(x: dragOffset)
            .gesture(
                DragGesture(minimumDistance: 10, coordinateSpace: .local)
                    .onChanged { value in
                        let h = value.translation.width
                        let v = value.translation.height
                        if abs(h) > abs(v) { dragOffset = h * 0.25 }
                    }
                    .onEnded { value in
                        let h = value.translation.width
                        let v = value.translation.height
                        if abs(h) > abs(v) && abs(h) > 30 { handleHorizontalSwipe(h) }
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { dragOffset = 0 }
                    }
            )
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(.easeIn(duration: 0.6)) { appeared = true }
            }

            // Top chrome — header + week strip
            VStack(spacing: 0) {
                HStack {
                    Text("grim")
                        .font(Theme.fontLabel)
                        .foregroundColor(Theme.muted)
                    Spacer()
                    Button { showSettings = true } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.muted)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 60)

                WeekStripView(userData: userData) { day in selectedDay = day }
                    .padding(.top, 20)

                Spacer()
            }

            // Bottom chrome — context card + daily prompt + swipe hint
            VStack(spacing: 0) {
                Spacer()

                ContextCardView()
                    .padding(.horizontal, 28)
                    .padding(.bottom, 12)

                if !userData.lifeItems.isEmpty || !userData.dailyPromptText.isNilOrEmpty {
                    dailyPromptHint
                        .padding(.horizontal, 28)
                        .padding(.bottom, 24)
                }

                Button { showLifeList = true } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 9, weight: .medium))
                        Text(userData.lifeItems.isEmpty ? "your life list" : "\(userData.lifeItems.count) things")
                            .font(Theme.fontLabel)
                    }
                    .foregroundColor(Theme.muted.opacity(0.4))
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 48)
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 50, coordinateSpace: .local)
                .onEnded { value in
                    let h = value.translation.width
                    let v = value.translation.height
                    if abs(v) > abs(h) && v < -50 { showLifeList = true }
                }
        )
        .sheet(isPresented: $showSettings) { SettingsView() }
        .sheet(isPresented: $showLifeList) { LifeListView() }
        .sheet(isPresented: Binding(
            get: { selectedDay != nil },
            set: { if !$0 { selectedDay = nil } }
        )) {
            if let day = selectedDay { DayDetailView(date: day) }
        }
    }

    // MARK: - Daily prompt hint

    private var dailyPromptHint: some View {
        Button { showLifeList = true } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text("today")
                    .font(Theme.fontLabel)
                    .foregroundColor(Theme.muted)

                if let prompt = userData.dailyPromptText, !prompt.isEmpty {
                    Text(prompt)
                        .font(Theme.fontLabel)
                        .foregroundColor(Theme.ink.opacity(0.8))
                        .lineSpacing(4)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                } else {
                    Text("tap to add things you want to do with your days →")
                        .font(Theme.fontLabel)
                        .foregroundColor(Theme.muted.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .overlay(Rectangle().stroke(Theme.border, lineWidth: 1))
        }
    }

    // MARK: - Helpers

    private func handleHorizontalSwipe(_ dx: CGFloat) {
        guard let current = units.firstIndex(of: displayUnit) else { return }
        let haptic = UIImpactFeedbackGenerator(style: .light)
        haptic.impactOccurred()
        withAnimation(.easeInOut(duration: 0.2)) {
            if dx < 0, current < units.count - 1 {
                displayUnit = units[current + 1]
            } else if dx > 0, current > 0 {
                displayUnit = units[current - 1]
            }
        }
    }

    private var formattedCount: String {
        if isExpired { return "0" }
        return DateCalculator.remaining(
            dob: userData.dateOfBirth,
            lifeExpectancy: userData.lifeExpectancy,
            unit: displayUnit
        ).formatted()
    }

    private var isExpired: Bool {
        DateCalculator.daysRemaining(dob: userData.dateOfBirth, lifeExpectancy: userData.lifeExpectancy) == 0
    }

    private var unitLabel: String {
        if isExpired { return "you made it." }
        switch displayUnit {
        case .days:  return "days remaining"
        case .weeks: return "weeks remaining"
        case .years: return "years remaining"
        }
    }

    private var todayLabel: String {
        Date().formatted(.dateTime.weekday(.wide).month(.wide).day())
    }
}

private extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool { self?.isEmpty ?? true }
}
