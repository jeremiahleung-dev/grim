import SwiftUI

struct SettingsView: View {
    @StateObject private var userData = UserData.shared
    @Environment(\.dismiss) private var dismiss
    @State private var dob: Date = UserData.shared.dateOfBirth
    @State private var lifeExpectancy: Double = Double(UserData.shared.lifeExpectancy)
    @State private var apiKey: String = UserData.shared.anthropicAPIKey
    @State private var focusedSection: SettingsSection = .dob
    @State private var saved = false

    enum SettingsSection { case dob, lifeExpectancy, apiKey }

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
                        Text("settings")
                            .font(Theme.fontLabel)
                            .foregroundColor(Theme.muted)
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Theme.muted)
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {

                        // Section: Date of Birth
                        settingSection(
                            label: "date of birth",
                            isActive: focusedSection == .dob
                        ) {
                            DOBPickerView(dob: $dob)
                                .padding(.horizontal, 12)
                        }
                        .onTapGesture { withAnimation { focusedSection = .dob } }

                        Divider()
                            .background(Theme.border)
                            .padding(.vertical, 32)

                        // Section: Life Expectancy
                        settingSection(
                            label: "life expectancy",
                            isActive: focusedSection == .lifeExpectancy
                        ) {
                            LifeExpectancyPicker(value: $lifeExpectancy)
                        }
                        .onTapGesture { withAnimation { focusedSection = .lifeExpectancy } }
                        .padding(.horizontal, 28)

                        Divider()
                            .background(Theme.border)
                            .padding(.vertical, 32)

                        // Section: Anthropic API Key
                        settingSection(
                            label: "anthropic api key",
                            isActive: focusedSection == .apiKey
                        ) {
                            TextField("sk-ant-...", text: $apiKey)
                                .font(Theme.fontLabel)
                                .foregroundColor(Theme.ink)
                                .tint(Theme.accent)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .padding(.horizontal, 28)
                                .onTapGesture { withAnimation { focusedSection = .apiKey } }
                        }
                        .onTapGesture { withAnimation { focusedSection = .apiKey } }
                    }
                }

                Spacer()

                // Save
                Button {
                    let haptic = UINotificationFeedbackGenerator()
                    haptic.notificationOccurred(.success)
                    userData.dateOfBirth = dob
                    userData.lifeExpectancy = Int(lifeExpectancy)
                    userData.anthropicAPIKey = apiKey.trimmingCharacters(in: .whitespaces)
                    userData.save()
                    withAnimation(.easeInOut(duration: 0.15)) { saved = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { dismiss() }
                } label: {
                    HStack {
                        Text(saved ? "saved" : "save")
                            .font(Theme.fontLabel)
                            .foregroundColor(saved ? Theme.ink : Theme.background)
                            .animation(.easeInOut(duration: 0.15), value: saved)
                        Spacer()
                        Image(systemName: saved ? "checkmark" : "arrow.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(saved ? Theme.ink : Theme.background)
                            .animation(.easeInOut(duration: 0.15), value: saved)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 18)
                    .background(saved ? Theme.accent : Theme.ink)
                    .animation(.easeInOut(duration: 0.2), value: saved)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 48)
            }
        }
    }

    private func settingSection<Content: View>(
        label: String,
        isActive: Bool,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(label)
                .font(Theme.fontLabel)
                .foregroundColor(isActive ? Theme.ink : Theme.muted)
                .padding(.horizontal, 28)

            content()
        }
        .opacity(isActive ? 1.0 : 0.45)
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}
