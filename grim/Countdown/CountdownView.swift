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

    @State private var tappedWeek: Int? = nil

    private let weeksPerYear = 52
    private let columns = Array(repeating: GridItem(.fixed(6), spacing: 1.5), count: 52)

    var body: some View {
        let totalWeeks = lifeExpectancy * weeksPerYear
        let weeksLived = DateCalculator.weeksLived(from: dob)
        let weeksRemaining = max(0, totalWeeks - weeksLived - 1)
        let livedYears = String(format: "%.1f", Double(weeksLived) / 52.0)

        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("your life · in weeks")
                    .font(Theme.fontLabel)
                    .foregroundColor(Theme.muted)
                Spacer()
                Text("\(livedYears)/\(lifeExpectancy)")
                    .font(Theme.fontLabel)
                    .foregroundColor(Theme.muted)
            }

            // Grid
            LazyVGrid(columns: columns, spacing: 1.5) {
                ForEach(0..<totalWeeks, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(dotColor(index: i, weeksLived: weeksLived))
                        .frame(width: 6, height: 6)
                        .onTapGesture { tappedWeek = tappedWeek == i ? nil : i }
                }
            }

            // Footer
            VStack(alignment: .leading, spacing: 6) {
                if let w = tappedWeek {
                    let age = String(format: "%.1f", Double(w) / 52.0)
                    Text("week \(w + 1) · age \(age)")
                        .font(Theme.fontLabel)
                        .foregroundColor(Theme.muted)
                }

                Text("\(weeksRemaining.formatted()) weeks left")
                    .font(Theme.fontLabel)
                    .foregroundColor(Theme.muted)

                HStack(spacing: 16) {
                    legendItem(color: Theme.muted.opacity(0.5), label: "lived")
                    legendItem(color: Theme.accent, label: "this week")
                    legendItem(color: Theme.surface, label: "ahead")
                }
                .padding(.top, 4)
            }
        }
    }

    private func dotColor(index: Int, weeksLived: Int) -> Color {
        if index < weeksLived { return Theme.muted.opacity(0.5) }
        if index == weeksLived { return Theme.accent }
        return Theme.surface
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 1)
                .fill(color)
                .frame(width: 6, height: 6)
            Text(label)
                .font(Theme.fontLabel)
                .foregroundColor(Theme.muted.opacity(0.6))
        }
    }
}
