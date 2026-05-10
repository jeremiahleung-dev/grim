import SwiftUI

struct WeekStripView: View {
    @ObservedObject var userData: UserData
    var onSelectDay: (Date) -> Void

    private let calendar = Calendar.current

    private var weekDays: [Date] {
        let today = Date()
        let weekday = calendar.component(.weekday, from: today) // 1 = Sun
        let sunday = calendar.date(byAdding: .day, value: -(weekday - 1), to: today)!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: sunday) }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekDays, id: \.self) { day in
                Button { onSelectDay(day) } label: {
                    dayCell(day)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 28)
    }

    @ViewBuilder
    private func dayCell(_ date: Date) -> some View {
        let isToday = calendar.isDateInToday(date)
        let isPast = !isToday && date < calendar.startOfDay(for: Date())
        let hasTasks = !userData.tasksForDate(date).isEmpty
        let color: Color = isToday ? Theme.accent : (isPast ? Theme.muted.opacity(0.3) : Theme.muted)

        VStack(spacing: 6) {
            Text(date.formatted(.dateTime.weekday(.narrow)))
                .font(Theme.fontLabel)
                .foregroundColor(color)

            Circle()
                .fill(hasTasks ? color : Color.clear)
                .frame(width: 3, height: 3)
        }
        .padding(.vertical, 8)
    }
}
