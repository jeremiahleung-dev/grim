import AppIntents
import WidgetKit
import Foundation

enum WidgetDisplayUnit: String, CaseIterable {
    case days, weeks, years
}

struct CycleDisplayUnit: AppIntent {
    static var title: LocalizedStringResource = "Cycle Unit"

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.moretolife.app")!
        let current = WidgetDisplayUnit(rawValue: defaults.string(forKey: "widgetDisplayUnit") ?? "days") ?? .days
        let all = WidgetDisplayUnit.allCases
        let next = all[(all.firstIndex(of: current)! + 1) % all.count]
        defaults.set(next.rawValue, forKey: "widgetDisplayUnit")
        return .result()
    }
}
