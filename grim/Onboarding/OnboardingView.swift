import SwiftUI

struct OnboardingView: View {
    @StateObject private var userData = UserData.shared
    @State private var step: Int = 0
    @State private var dob: Date = Calendar.current.date(
        byAdding: .year, value: -30, to: Date()) ?? Date()
    @State private var lifeExpectancy: Double = 90
    @State private var welcomePulse = false

    @AppStorage("hasOnboarded", store: UserDefaults(suiteName: "group.com.moretolife.app"))
    private var hasOnboarded: Bool = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                // Step content slides in from right
                ZStack(alignment: .leading) {
                    if step == 0 { welcomeStep.transition(stepTransition) }
                    if step == 1 { dobStep.transition(stepTransition) }
                    if step == 2 { lifeExpectancyStep.transition(stepTransition) }
                }
                .padding(.horizontal, 28)

                Spacer()

                // CTA button
                if step > 0 {
                    Button(action: advance) {
                        HStack {
                            Text(step == 2 ? "start" : "next")
                                .font(Theme.fontLabel)
                                .foregroundColor(Theme.background)
                            Spacer()
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Theme.background)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 18)
                        .background(Theme.ink)
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 48)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if step == 0 { advance() }
        }
    }

    private var stepTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }

    private var welcomeStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                WeekMark(size: 60)
                Text("live more")
                    .font(Theme.fontDisplay)
                    .foregroundColor(Theme.ink)
            }

            Text("you have a finite number\nof days.\n\nthis is how many remain.")
                .font(Theme.fontLabel)
                .foregroundColor(Theme.muted)
                .lineSpacing(6)

            Text("tap to begin")
                .font(Theme.fontLabel)
                .foregroundColor(Theme.muted.opacity(welcomePulse ? 0.6 : 0.25))
                .padding(.top, 8)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                        welcomePulse = true
                    }
                }
        }
    }

    private var dobStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("when were\nyou born?")
                .font(Theme.fontDisplay)
                .foregroundColor(Theme.ink)
                .lineSpacing(4)

            DOBPickerView(dob: $dob)
        }
    }

    private var lifeExpectancyStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("how long\nwill you live?")
                .font(Theme.fontDisplay)
                .foregroundColor(Theme.ink)
                .lineSpacing(4)

            LifeExpectancyPicker(value: $lifeExpectancy)
        }
    }

    private func advance() {
        let haptic = UIImpactFeedbackGenerator(style: .light)
        haptic.impactOccurred()

        withAnimation(.easeInOut(duration: 0.35)) {
            if step < 2 {
                step += 1
            } else {
                userData.dateOfBirth = dob
                userData.lifeExpectancy = Int(lifeExpectancy)
                userData.save()
                hasOnboarded = true
            }
        }
    }
}

struct LifeExpectancyPicker: View {
    @Binding var value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(Int(value))")
                .font(Theme.fontHero)
                .foregroundColor(Theme.ink)
                .contentTransition(.numericText())

            Slider(value: $value, in: 70...120, step: 1)
                .tint(Theme.accent)

            HStack {
                Text("70")
                    .font(Theme.fontLabel)
                    .foregroundColor(Theme.muted)
                Spacer()
                Text("120")
                    .font(Theme.fontLabel)
                    .foregroundColor(Theme.muted)
            }
        }
    }
}
