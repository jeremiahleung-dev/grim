import WidgetKit
import Foundation

struct LiveMoreEntry: TimelineEntry {
    let date: Date
    let daysRemaining: Int
    let weeksRemaining: Int
    let yearsRemaining: Double
    let percentLived: Double
    let weeksLived: Int
    let lifeExpectancy: Int
    let dob: Date
    let widgetDisplayUnit: String
    let contextBriefing: String?
    let currentStreak: Int
}
