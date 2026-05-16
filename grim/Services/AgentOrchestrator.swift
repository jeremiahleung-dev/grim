import Foundation

class AgentOrchestrator {
    static let shared = AgentOrchestrator()

    private let health   = HealthService()
    private let calendar = CalendarService()
    private let contacts = ContactsService()
    private var weather  = WeatherService()

    private(set) var isRunning = false

    func run(userData: UserData, completion: @escaping () -> Void) {
        guard !isRunning else { completion(); return }
        isRunning = true

        var healthSnap = HealthSnapshot()
        var events: [String] = []
        var reminders: [String] = []
        var birthdays: [String] = []
        var weatherStr: String?

        let fetchGroup = DispatchGroup()

        fetchGroup.enter()
        health.fetchSnapshot { snap in healthSnap = snap; fetchGroup.leave() }

        events = calendar.fetchUpcomingEvents()

        fetchGroup.enter()
        calendar.fetchPendingReminders { r in reminders = r; fetchGroup.leave() }

        fetchGroup.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            birthdays = self.contacts.fetchUpcomingBirthdays()
            fetchGroup.leave()
        }

        fetchGroup.enter()
        weather.fetch { w in weatherStr = w; fetchGroup.leave() }

        fetchGroup.notify(queue: .global()) { [weak self] in
            guard let self else { return }

            var candidates: [CandidateSuggestion] = []
            let agentGroup = DispatchGroup()
            let lock = NSLock()

            agentGroup.enter()
            HealthAgent().run(snap: healthSnap) { candidate in
                if let c = candidate { lock.withLock { candidates.append(c) } }
                agentGroup.leave()
            }

            agentGroup.enter()
            SocialAgent().run(birthdays: birthdays) { candidate in
                if let c = candidate { lock.withLock { candidates.append(c) } }
                agentGroup.leave()
            }

            agentGroup.enter()
            CalendarAgent().run(events: events, reminders: reminders) { candidate in
                if let c = candidate { lock.withLock { candidates.append(c) } }
                agentGroup.leave()
            }

            agentGroup.enter()
            EnvironmentAgent().run(weather: weatherStr) { candidate in
                if let c = candidate { lock.withLock { candidates.append(c) } }
                agentGroup.leave()
            }

            let goals = userData.lifeItems.map { $0.text }
            agentGroup.enter()
            LifeGoalsAgent().run(goals: goals) { candidate in
                if let c = candidate { lock.withLock { candidates.append(c) } }
                agentGroup.leave()
            }

            agentGroup.notify(queue: .global()) {
                let memory = userData.suggestionMemory
                    .sorted { $0.date > $1.date }
                    .prefix(14)
                    .map { $0 }

                CoordinatorAgent().run(candidates: candidates, memory: Array(memory)) { result in
                    DispatchQueue.main.async {
                        let cleanResult = result.flatMap { t -> String? in
                            let lower = t.lowercased()
                            let junk = ["cannot provide", "no suggestion", "i cannot", "all candidates", "no candidates", "unable to"]
                            return junk.contains(where: { lower.contains($0) }) ? nil : t
                        }
                        if let text = cleanResult, !text.isEmpty {
                            userData.contextBriefing = text
                            userData.contextDate = Date()
                            let domain = candidates.max(by: { $0.urgency < $1.urgency })?.domain ?? "unknown"
                            let entry = SuggestionMemory(date: Date(), suggestion: text, domain: domain)
                            userData.suggestionMemory.append(entry)
                            if userData.suggestionMemory.count > 30 {
                                userData.suggestionMemory = Array(userData.suggestionMemory.suffix(30))
                            }
                            userData.save()
                            let daysLeft = DateCalculator.daysRemaining(dob: userData.dateOfBirth, lifeExpectancy: userData.lifeExpectancy)
                            NotificationService.scheduleDailyNotification(text: text, daysRemaining: daysLeft, hour: userData.notificationHour)
                            if
                                #available(iOS 16.2, *) {
                                ActivityManager.shared.update(
                                    dob: userData.dateOfBirth,
                                    lifeExpectancy: userData.lifeExpectancy,
                                    daysRemaining: daysLeft,
                                    briefing: text,
                                    domain: domain,
                                    streak: userData.currentStreak
                                )
                            }
                        }
                        self.isRunning = false
                        completion()
                    }
                }
            }
        }
    }
}
