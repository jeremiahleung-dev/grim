import Foundation

class ContextManager {
    static let shared = ContextManager()

    private let health    = HealthService()
    private let calendar  = CalendarService()
    private let contacts  = ContactsService()
    private var weather   = WeatherService()

    private(set) var isRefreshing = false

    // MARK: - Permission requests

    func requestAll() {
        health.requestAuthorization { _ in }
        calendar.requestEventAccess { _ in }
        calendar.requestReminderAccess { _ in }
        contacts.requestAuthorization { _ in }
        weather.fetch { _ in }
    }

    // MARK: - Refresh

    func refresh(userData: UserData, force: Bool = false, completion: (() -> Void)? = nil) {
        guard !isRefreshing else { completion?(); return }

        if !force {
            let today = Calendar.current.startOfDay(for: Date())
            if let cached = userData.contextDate,
               Calendar.current.isDate(cached, inSameDayAs: today),
               let text = userData.contextBriefing, !text.isEmpty {
                completion?(); return
            }
        }

        isRefreshing = true

        var healthSnap = HealthSnapshot()
        var events: [String] = []
        var reminders: [String] = []
        var birthdays: [String] = []
        var weatherStr: String?

        let group = DispatchGroup()

        group.enter()
        health.fetchSnapshot { snap in healthSnap = snap; group.leave() }

        events = calendar.fetchUpcomingEvents()

        group.enter()
        calendar.fetchPendingReminders { r in reminders = r; group.leave() }

        birthdays = contacts.fetchUpcomingBirthdays()

        group.enter()
        weather.fetch { w in weatherStr = w; group.leave() }

        group.notify(queue: .main) { [weak self] in
            self?.callClaude(
                userData: userData,
                health: healthSnap,
                events: events,
                reminders: reminders,
                birthdays: birthdays,
                weather: weatherStr
            ) {
                self?.isRefreshing = false
                completion?()
            }
        }
    }

    // MARK: - Claude call

    private func callClaude(
        userData: UserData,
        health: HealthSnapshot,
        events: [String],
        reminders: [String],
        birthdays: [String],
        weather: String?,
        completion: @escaping () -> Void
    ) {
        var sections: [String] = []

        if !health.isEmpty {
            sections.append("Health (7-day avg): \(health.summaryString)")
        }
        if !events.isEmpty {
            sections.append("Upcoming events:\n" + events.map { "- \($0)" }.joined(separator: "\n"))
        }
        if !reminders.isEmpty {
            sections.append("Pending reminders: " + reminders.prefix(5).joined(separator: "; "))
        }
        if !birthdays.isEmpty {
            sections.append("Birthdays soon: " + birthdays.joined(separator: ", "))
        }
        if let w = weather {
            sections.append("Weather today: \(w)")
        }

        guard !sections.isEmpty else { completion(); return }

        let age = Calendar.current.dateComponents([.year], from: userData.dateOfBirth, to: Date()).year ?? 30
        let daysLeft = DateCalculator.daysRemaining(dob: userData.dateOfBirth, lifeExpectancy: userData.lifeExpectancy)
        let itemsList = userData.lifeItems.map { "- \($0.text)" }.joined(separator: "\n")

        let system = "You are embedded in a life-awareness app called grim. Help people live more intentionally by connecting what's happening in their life right now to what matters most. Be warm, specific, and human — never preachy."

        let user = """
        The user is \(age) years old with \(daysLeft.formatted()) days remaining.

        Their life goals:
        \(itemsList.isEmpty ? "none added yet" : itemsList)

        What's happening in their life right now:
        \(sections.joined(separator: "\n\n"))

        Write one grounding sentence of at most 30 words. Start with "right now," (lowercase). Be specific — mention a real event, real data, or a real person from their life. No emojis. No second sentence.
        """

        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "content-type")
        req.setValue(Secrets.anthropicAPIKey, forHTTPHeaderField: "x-api-key")
        req.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": "claude-haiku-4-5-20251001",
            "max_tokens": 200,
            "system": system,
            "messages": [["role": "user", "content": user]]
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            completion(); return
        }
        req.httpBody = httpBody

        URLSession.shared.dataTask(with: req) { data, _, _ in
            guard
                let data = data,
                let json    = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let content = json["content"] as? [[String: Any]],
                let text    = content.first?["text"] as? String
            else {
                DispatchQueue.main.async { completion() }
                return
            }
            DispatchQueue.main.async {
                userData.contextBriefing = text.trimmingCharacters(in: .whitespacesAndNewlines)
                userData.contextDate = Date()
                userData.save()
                completion()
            }
        }.resume()
    }
}
