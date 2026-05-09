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
    @Published var anthropicAPIKey: String
    @Published var dailyPromptText: String?
    @Published var dailyPromptDate: Date?

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

        self.dateOfBirth = storedDOB
        self.lifeExpectancy = storedLE > 0 ? storedLE : 100
        self.displayUnit = storedUnit
        self.lifeItems = storedItems
        self.anthropicAPIKey = defaults.string(forKey: "anthropicAPIKey") ?? ""
        self.dailyPromptText = defaults.string(forKey: "dailyPromptText")
        self.dailyPromptDate = defaults.object(forKey: "dailyPromptDate") as? Date
    }

    func save() {
        defaults.set(dateOfBirth, forKey: "dob")
        defaults.set(lifeExpectancy, forKey: "lifeExpectancy")
        defaults.set(displayUnit.rawValue, forKey: "displayUnit")
        defaults.set(anthropicAPIKey, forKey: "anthropicAPIKey")
        defaults.set(dailyPromptText, forKey: "dailyPromptText")
        defaults.set(dailyPromptDate, forKey: "dailyPromptDate")
        if let data = try? JSONEncoder().encode(lifeItems) {
            defaults.set(data, forKey: "lifeItems")
        }
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
}
