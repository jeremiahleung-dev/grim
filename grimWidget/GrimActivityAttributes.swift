import ActivityKit
import Foundation

@available(iOS 16.1, *)
struct LiveMoreActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var daysRemaining: Int
        var contextBriefing: String
        var domain: String
        var streakCount: Int
    }
    let dob: Date
    let lifeExpectancy: Int
}
