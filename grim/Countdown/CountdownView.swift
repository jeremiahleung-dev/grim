import SwiftUI

struct CountdownView: View {
    let dob: Date
    let lifeExpectancy: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            statsRow
            WeekGridView(dob: dob, lifeExpectancy: lifeExpectancy)
        }
        .padding(28)
    }

    private var statsRow: some View {
        HStack(spacing: 24) {
            statBlock(
                value: DateCalculator.remaining(dob: dob, lifeExpectancy: lifeExpectancy, unit: .days).formatted(),
                label: "days"
            )
            statBlock(
                value: DateCalculator.remaining(dob: dob, lifeExpectancy: lifeExpectancy, unit: .weeks).formatted(),
                label: "weeks"
            )
            statBlock(
                value: String(format: "%.1f", Double(DateCalculator.remaining(dob: dob, lifeExpectancy: lifeExpectancy, unit: .days)) / 365.25),
                label: "years"
            )
        }
    }

    private func statBlock(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(Theme.fontMono)
                .foregroundColor(Theme.ink)
            Text(label)
                .font(Theme.fontLabel)
                .foregroundColor(Theme.muted)
        }
    }
}

struct WeekGridView: View {
    let dob: Date
    let lifeExpectancy: Int

    private let weeksPerYear = 52
    private let columns = Array(repeating: GridItem(.fixed(6), spacing: 2), count: 52)

    var body: some View {
        let totalWeeks = lifeExpectancy * weeksPerYear
        let weeksLived = DateCalculator.weeksLived(from: dob)

        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(0..<totalWeeks, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1)
                    .fill(dotColor(index: i, weeksLived: weeksLived))
                    .frame(width: 6, height: 6)
            }
        }
    }

    private func dotColor(index: Int, weeksLived: Int) -> Color {
        if index < weeksLived { return Theme.muted.opacity(0.5) }
        if index == weeksLived { return Theme.accent }
        return Theme.surface
    }
}
