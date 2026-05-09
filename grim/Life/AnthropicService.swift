import Foundation

struct AnthropicService {

    static func generateDailyPrompt(
        items: [LifeItem],
        dob: Date,
        lifeExpectancy: Int,
        completion: @escaping (String?) -> Void
    ) {
        guard !items.isEmpty else {
            completion(nil)
            return
        }
        let apiKey = Secrets.anthropicAPIKey

        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("prompt-caching-2024-07-31", forHTTPHeaderField: "anthropic-beta")

        let age = Calendar.current.dateComponents([.year], from: dob, to: Date()).year ?? 30
        let daysLeft = DateCalculator.daysRemaining(dob: dob, lifeExpectancy: lifeExpectancy)
        let itemsList = items.map { "- \($0.text)" }.joined(separator: "\n")

        let systemText = """
        You are embedded in a life-awareness app called grim. Your job is to help people live more intentionally by turning their deepest wishes into small, concrete actions they can take today. Be warm, specific, and grounded — never preachy.
        """

        let userText = """
        The user is \(age) years old with \(daysLeft.formatted()) days left based on their life expectancy.

        Things they want to do, feel, or achieve in their life:
        \(itemsList)

        Pick one of their goals and suggest ONE specific action they can take today — something small enough to actually do, meaningful enough to matter.

        Rules:
        - Start with "today," (lowercase)
        - 2–3 sentences only
        - Be specific, not vague ("text Sarah" not "reach out to someone")
        - Never mention death, time running out, or the countdown
        - No emojis
        """

        let body: [String: Any] = [
            "model": "claude-haiku-4-5-20251001",
            "max_tokens": 150,
            "system": [
                ["type": "text", "text": systemText, "cache_control": ["type": "ephemeral"]]
            ],
            "messages": [
                ["role": "user", "content": userText]
            ]
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            completion(nil)
            return
        }
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let content = json["content"] as? [[String: Any]],
                let text = content.first?["text"] as? String
            else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            DispatchQueue.main.async {
                completion(text.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }.resume()
    }
}
