import Foundation
import Combine

let appGroupID = "group.com.grim.app"

enum DisplayUnit: String, CaseIterable, Codable {
    case days = "days"
    case weeks = "weeks"
    case years = "years"
}

class UserData: ObservableObject {
    static let shared = UserData()

    private let defaults = UserDefaults(suiteName: appGroupID)!

    @Published var dateOfBirth: Date
    @Published var lifeExpectancy: Int
    @Published var displayUnit: DisplayUnit
    @Published var lifeItems: [LifeItem]
    @Published var dailyPromptText: String?
    @Published var dailyPromptDate: Date?
    @Published var weekTasks: [String: [DayTask]]
    @Published var contextBriefing: String?
    @Published var contextDate: Date?
    @Published var suggestionMemory: [SuggestionMemory]
    @Published var currentStreak: Int
    @Published var lastOpenedDate: Date?
    @Published var notificationHour: Int

    private init() {
        let defaultDOB: Date = {
            var c = DateComponents()
            c.year = 1996; c.month = 7; c.day = 17
            return Calendar.current.date(from: c) ?? Date()
        }()

        let storedDOB = defaults.object(forKey: "dob") as? Date ?? defaultDOB
        let storedLE = defaults.integer(forKey: "lifeExpectancy")
        let storedUnit = DisplayUnit(rawValue: defaults.string(forKey: "displayUnit") ?? "") ?? .days
        let storedItemsData = defaults.data(forKey: "lifeItems")
        let storedItems: [LifeItem] = storedItemsData.flatMap {
            try? JSONDecoder().decode([LifeItem].self, from: $0)
        } ?? []
        let storedWeekData = defaults.data(forKey: "weekTasks")
        let storedWeekTasks: [String: [DayTask]] = storedWeekData.flatMap {
            try? JSONDecoder().decode([String: [DayTask]].self, from: $0)
        } ?? [:]

        self.dateOfBirth = storedDOB
        self.lifeExpectancy = storedLE > 0 ? storedLE : 100
        self.displayUnit = storedUnit
        self.lifeItems = storedItems
        self.dailyPromptText = defaults.string(forKey: "dailyPromptText")
        self.dailyPromptDate = defaults.object(forKey: "dailyPromptDate") as? Date
        self.weekTasks = storedWeekTasks
        self.contextBriefing = defaults.string(forKey: "contextBriefing")
        self.contextDate = defaults.object(forKey: "contextDate") as? Date
        let storedMemoryData = defaults.data(forKey: "suggestionMemory")
        self.suggestionMemory = storedMemoryData.flatMap {
            try? JSONDecoder().decode([SuggestionMemory].self, from: $0)
        } ?? []
        self.currentStreak = max(0, defaults.integer(forKey: "currentStreak"))
        self.lastOpenedDate = defaults.object(forKey: "lastOpenedDate") as? Date
        let storedHour = defaults.integer(forKey: "notificationHour")
        self.notificationHour = storedHour > 0 ? storedHour : 9
    }

    func save() {
        defaults.set(dateOfBirth, forKey: "dob")
        defaults.set(lifeExpectancy, forKey: "lifeExpectancy")
        defaults.set(displayUnit.rawValue, forKey: "displayUnit")
        defaults.set(dailyPromptText, forKey: "dailyPromptText")
        defaults.set(dailyPromptDate, forKey: "dailyPromptDate")
        defaults.set(contextBriefing, forKey: "contextBriefing")
        defaults.set(contextDate, forKey: "contextDate")
        if let data = try? JSONEncoder().encode(lifeItems) {
            defaults.set(data, forKey: "lifeItems")
        }
        if let data = try? JSONEncoder().encode(weekTasks) {
            defaults.set(data, forKey: "weekTasks")
        }
        if let data = try? JSONEncoder().encode(suggestionMemory) {
            defaults.set(data, forKey: "suggestionMemory")
        }
        defaults.set(currentStreak, forKey: "currentStreak")
        defaults.set(lastOpenedDate, forKey: "lastOpenedDate")
        defaults.set(notificationHour, forKey: "notificationHour")
    }

    func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        if let last = lastOpenedDate {
            if Calendar.current.isDateInToday(last) { return }
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
            if Calendar.current.isDate(last, inSameDayAs: yesterday) {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }
        lastOpenedDate = Date()
        save()
    }

    func addLifeItem(_ text: String) {
        lifeItems.append(LifeItem(text: text))
        save()
    }

    func removeLifeItem(_ item: LifeItem) {
        lifeItems.removeAll { $0.id == item.id }
        dailyPromptText = nil
        dailyPromptDate = nil
        save()
    }

    func tasksForDate(_ date: Date) -> [DayTask] {
        weekTasks[dateKey(date)] ?? []
    }

    func addTask(_ text: String, for date: Date) {
        let key = dateKey(date)
        var tasks = weekTasks[key] ?? []
        tasks.append(DayTask(text: text))
        weekTasks[key] = tasks
        save()
    }

    func removeTask(_ task: DayTask, for date: Date) {
        let key = dateKey(date)
        weekTasks[key]?.removeAll { $0.id == task.id }
        save()
    }

    private func dateKey(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}
