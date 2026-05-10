import ActivityKit
import Foundation

@available(iOS 16.2, *)
final class ActivityManager {
    static let shared = ActivityManager()
    private var currentActivity: Activity<GrimActivityAttributes>?

    func update(dob: Date, lifeExpectancy: Int, daysRemaining: Int, briefing: String, domain: String, streak: Int) {
        let state = GrimActivityAttributes.ContentState(
            daysRemaining: daysRemaining,
            contextBriefing: briefing,
            domain: domain,
            streakCount: streak
        )
        if let activity = currentActivity {
            Task { await activity.update(ActivityContent(state: state, staleDate: nil)) }
        } else {
            guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
            let attrs = GrimActivityAttributes(dob: dob, lifeExpectancy: lifeExpectancy)
            do {
                currentActivity = try Activity<GrimActivityAttributes>.request(
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
