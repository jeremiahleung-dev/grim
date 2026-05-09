import SwiftUI

struct ContentView: View {
    @StateObject private var userData = UserData.shared
    @State private var displayUnit: DisplayUnit = .days
    @State private var showSettings = false
    @State private var appeared = false

    private let units = DisplayUnit.allCases

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Text("grim")
                        .font(Theme.fontLabel)
                        .foregroundColor(Theme.muted)
                    Spacer()
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.muted)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 60)

                Spacer()

                // Main countdown — swipeable
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

                    // Page dots
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
                .gesture(
                    DragGesture(minimumDistance: 30, coordinateSpace: .local)
                        .onEnded { value in
                            handleSwipe(value.translation.width)
                        }
                )
                .opacity(appeared ? 1 : 0)
                .onAppear {
                    withAnimation(.easeIn(duration: 0.6)) {
                        appeared = true
                    }
                }

                Spacer()
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    private func handleSwipe(_ dx: CGFloat) {
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

    private var isExpired: Bool {
        DateCalculator.daysRemaining(
            dob: userData.dateOfBirth,
            lifeExpectancy: userData.lifeExpectancy
        ) == 0
    }

    private var formattedCount: String {
        if isExpired { return "0" }
        let n = DateCalculator.remaining(
            dob: userData.dateOfBirth,
            lifeExpectancy: userData.lifeExpectancy,
            unit: displayUnit
        )
        return n.formatted()
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
