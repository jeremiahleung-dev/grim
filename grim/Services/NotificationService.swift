import UserNotifications
import Foundation

struct NotificationService {

    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    static func scheduleDailyNotification(text: String, daysRemaining: Int, hour: Int) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            center.removePendingNotificationRequests(withIdentifiers: ["grim.daily"])

            let content = UNMutableNotificationContent()
            content.title = "\(daysRemaining.formatted(.number)) days"
            content.body = text
            content.sound = .default

            var dc = DateComponents()
            dc.hour = hour
            dc.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
            let request = UNNotificationRequest(identifier: "grim.daily", content: content, trigger: trigger)
            center.add(request)
        }
    }

    static func scheduleWeeklyNotification(tasksThisWeek: Int, daysRemaining: Int) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            center.removePendingNotificationRequests(withIdentifiers: ["grim.weekly"])

            let content = UNMutableNotificationContent()
            content.title = "this week"
            content.body = "you logged \(tasksThisWeek) of 7 days. \(daysRemaining.formatted(.number)) days left."
            content.sound = .default

            var dc = DateComponents()
            dc.weekday = 1  // Sunday
            dc.hour = 18
            dc.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
            let request = UNNotificationRequest(identifier: "grim.weekly", content: content, trigger: trigger)
            center.add(request)
        }
    }
}
