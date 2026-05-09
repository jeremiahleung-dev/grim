import Foundation

struct DateCalculator {

    static func endDate(dob: Date, lifeExpectancy: Int) -> Date {
        Calendar.current.date(byAdding: .year, value: lifeExpectancy, to: dob) ?? dob
    }

    static func daysRemaining(dob: Date, lifeExpectancy: Int) -> Int {
        let end = endDate(dob: dob, lifeExpectancy: lifeExpectancy)
        let days = Calendar.current.dateComponents([.day], from: Date(), to: end).day ?? 0
        return max(0, days)
    }

    static func weeksRemaining(dob: Date, lifeExpectancy: Int) -> Int {
        return max(0, daysRemaining(dob: dob, lifeExpectancy: lifeExpectancy) / 7)
    }

    static func yearsRemaining(dob: Date, lifeExpectancy: Int) -> Double {
        return max(0, Double(daysRemaining(dob: dob, lifeExpectancy: lifeExpectancy)) / 365.25)
    }

    static func weeksLived(from dob: Date) -> Int {
        let weeks = Calendar.current.dateComponents([.weekOfYear], from: dob, to: Date()).weekOfYear ?? 0
        return max(0, weeks)
    }

    static func percentLived(dob: Date, lifeExpectancy: Int) -> Double {
        let totalDays = Double(lifeExpectancy) * 365.25
        let lived = totalDays - Double(daysRemaining(dob: dob, lifeExpectancy: lifeExpectancy))
        return min(1.0, max(0.0, lived / totalDays))
    }
}
