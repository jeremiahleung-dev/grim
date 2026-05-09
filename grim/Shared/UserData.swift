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

    @Published var dateOfBirth: Date {
        didSet { save() }
    }

    @Published var lifeExpectancy: Int {
        didSet { save() }
    }

    @Published var displayUnit: DisplayUnit {
        didSet { save() }
    }

    private init() {
        let defaultDOB: Date = {
            var c = DateComponents()
            c.year = 1996; c.month = 7; c.day = 17
            return Calendar.current.date(from: c) ?? Date()
        }()

        let storedDOB = defaults.object(forKey: "dob") as? Date ?? defaultDOB
        let storedLE = defaults.integer(forKey: "lifeExpectancy")
        let storedUnit = DisplayUnit(rawValue: defaults.string(forKey: "displayUnit") ?? "") ?? .days

        self.dateOfBirth = storedDOB
        self.lifeExpectancy = storedLE > 0 ? storedLE : 100
        self.displayUnit = storedUnit
    }

    func save() {
        defaults.set(dateOfBirth, forKey: "dob")
        defaults.set(lifeExpectancy, forKey: "lifeExpectancy")
        defaults.set(displayUnit.rawValue, forKey: "displayUnit")
    }
}
