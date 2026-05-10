import Foundation

struct HealthAgent {
    func run(snap: HealthSnapshot, completion: @escaping (CandidateSuggestion?) -> Void) {
        guard !snap.isEmpty else { completion(nil); return }

        let system = "You are the health advisor in a life-awareness app. Given a health snapshot, identify the single most important thing this person should attend to for their body."

        let user = """
        Health data (7-day average): \(snap.summaryString)

        Respond only with JSON: {"suggestion":"...","urgency":N}
        The suggestion must be max 15 words, specific and actionable. Urgency is 1–10. No explanation.
        """

        callHaiku(system: system, user: user) { text in
            completion(parse(text: text, domain: "health"))
        }
    }

    private func callHaiku(system: String, user: String, completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "content-type")
        req.setValue(Secrets.anthropicAPIKey, forHTTPHeaderField: "x-api-key")
        req.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        req.setValue("prompt-caching-2024-07-31", forHTTPHeaderField: "anthropic-beta")

        let body: [String: Any] = [
            "model": "claude-haiku-4-5-20251001",
            "max_tokens": 80,
            "system": [["type": "text", "text": system, "cache_control": ["type": "ephemeral"]]],
            "messages": [["role": "user", "content": user]]
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            completion(nil); return
        }
        req.httpBody = httpBody

        URLSession.shared.dataTask(with: req) { data, _, _ in
            guard
                let data = data,
                let json    = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let content = json["content"] as? [[String: Any]],
                let text    = content.first?["text"] as? String
            else { completion(nil); return }
            completion(text)
        }.resume()
    }

    private func parse(text: String?, domain: String) -> CandidateSuggestion? {
        guard let text else { return nil }
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
        guard
            let data = cleaned.data(using: .utf8),
            let obj  = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let sug  = obj["suggestion"] as? String,
            let urg  = obj["urgency"] as? Int
        else { return nil }
        return CandidateSuggestion(domain: domain, suggestion: sug, urgency: urg)
    }
}
