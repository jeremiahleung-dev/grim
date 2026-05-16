import ActivityKit
import Foundation

@available(iOS 16.2, *)
final class ActivityManager {
    static let shared = ActivityManager()
    private var currentActivity: Activity<LiveMoreActivityAttributes>?

    func update(dob: Date, lifeExpectancy: Int, daysRemaining: Int, briefing: String, domain: String, streak: Int) {
        let state = LiveMoreActivityAttributes.ContentState(
            daysRemaining: daysRemaining,
            contextBriefing: briefing,
            domain: domain,
            streakCount: streak
        )
        if let activity = currentActivity {
            Task { await activity.update(ActivityContent(state: state, staleDate: nil)) }
        } else {
            guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
            let attrs = LiveMoreActivityAttributes(dob: dob, lifeExpectancy: lifeExpectancy)
            do {
                currentActivity = try Activity<LiveMoreActivityAttributes>.request(
                    attributes: attrs,
                    content: ActivityContent(state: state, staleDate: nil),
                    pushType: nil
                )
            } catch { }
        }
    }

    func end() {
        guard let activity = currentActivity else { return }
        Task {
            await activity.end(dismissalPolicy: .immediate)
            currentActivity = nil
        }
    }
}
