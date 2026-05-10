import Foundation

struct CandidateSuggestion {
    let domain: String
    let suggestion: String
    let urgency: Int
}

struct SuggestionMemory: Codable {
    let date: Date
    let suggestion: String
    let domain: String
}
