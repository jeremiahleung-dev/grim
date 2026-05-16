import Foundation

struct CoordinatorAgent {
    func run(
        candidates: [CandidateSuggestion],
        memory: [SuggestionMemory],
        completion: @escaping (String?) -> Void
    ) {
        guard !candidates.isEmpty else { completion(nil); return }

        let system = "You are the decision layer of a life-awareness app called more to life. You receive suggestions from specialist agents plus a log of what the user was told recently. Pick the most timely, impactful suggestion they haven't heard recently. Return ONLY the suggestion text — max 12 words, lowercase, no punctuation at end, no explanation."

        var userParts: [String] = []

        userParts.append("Candidate suggestions:")
        for c in candidates {
            userParts.append("[\(c.domain), urgency \(c.urgency)]: \(c.suggestion)")
        }

        if !memory.isEmpty {
            userParts.append("\nRecent suggestions (do not repeat these domains back-to-back):")
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            for m in memory {
                userParts.append("[\(formatter.string(from: m.date)), \(m.domain)]: \(m.suggestion)")
            }
        }

        let user = userParts.joined(separator: "\n")

        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "content-type")
        req.setValue(Secrets.anthropicAPIKey, forHTTPHeaderField: "x-api-key")
        req.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        req.setValue("prompt-caching-2024-07-31", forHTTPHeaderField: "anthropic-beta")

        let body: [String: Any] = [
            "model": "claude-haiku-4-5-20251001",
            "max_tokens": 60,
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
            completion(text.trimmingCharacters(in: .whitespacesAndNewlines))
        }.resume()
    }
}
