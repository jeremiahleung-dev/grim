import XCTest
@testable import grim

final class DateCalculatorTests: XCTestCase {

    var dob: Date {
        var c = DateComponents()
        c.year = 1996; c.month = 7; c.day = 17
        return Calendar.current.date(from: c)!
    }

    func testDaysRemainingIsPositive() {
        let days = DateCalculator.daysRemaining(dob: dob, lifeExpectancy: 100)
        XCTAssertGreaterThan(days, 0)
    }

    func testWeeksRemainingLessThanDays() {
        let days = DateCalculator.daysRemaining(dob: dob, lifeExpectancy: 100)
        let weeks = DateCalculator.weeksRemaining(dob: dob, lifeExpectancy: 100)
        XCTAssertLessThan(weeks, days)
    }

    func testEndDateIsCorrect() {
        let end = DateCalculator.endDate(dob: dob, lifeExpectancy: 100)
        let components = Calendar.current.dateComponents([.year, .month, .day], from: end)
        XCTAssertEqual(components.year, 2096)
        XCTAssertEqual(components.month, 7)
        XCTAssertEqual(components.day, 17)
    }

    func testPercentLivedBetweenZeroAndOne() {
        let pct = DateCalculator.percentLived(dob: dob, lifeExpectancy: 100)
        XCTAssertGreaterThan(pct, 0)
        XCTAssertLessThan(pct, 1)
    }

    func testWeeksLivedIsPositive() {
        let weeks = DateCalculator.weeksLived(from: dob)
        XCTAssertGreaterThan(weeks, 0)
    }
}
