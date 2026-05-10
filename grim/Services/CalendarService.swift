import EventKit

class CalendarService {
    private let store = EKEventStore()

    func requestEventAccess(completion: @escaping (Bool) -> Void) {
        if #available(iOS 17, *) {
            store.requestFullAccessToEvents { ok, _ in DispatchQueue.main.async { completion(ok) } }
        } else {
            store.requestAccess(to: .event) { ok, _ in DispatchQueue.main.async { completion(ok) } }
        }
    }

    func requestReminderAccess(completion: @escaping (Bool) -> Void) {
        if #available(iOS 17, *) {
            store.requestFullAccessToReminders { ok, _ in DispatchQueue.main.async { completion(ok) } }
        } else {
            store.requestAccess(to: .reminder) { ok, _ in DispatchQueue.main.async { completion(ok) } }
        }
    }

    func fetchUpcomingEvents(days: Int = 7) -> [String] {
        let start = Date()
        let end = Calendar.current.date(byAdding: .day, value: days, to: start)!
        let pred = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        return store.events(matching: pred)
            .prefix(12)
            .map { event in
                let day = event.startDate.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
                let time = event.isAllDay ? "all day" : event.startDate.formatted(.dateTime.hour().minute())
                return "\(event.title ?? "event") — \(day), \(time)"
            }
    }

    func fetchPendingReminders(completion: @escaping ([String]) -> Void) {
        let pred = store.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: nil)
        store.fetchReminders(matching: pred) { reminders in
            let titles = (reminders ?? []).prefix(8).compactMap { $0.title }
            DispatchQueue.main.async { completion(titles) }
        }
    }
}
