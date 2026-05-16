import SwiftUI

struct WeekMark: View {
    var size: CGFloat = 100

    private var todayIndex: Int {
        Calendar.current.component(.weekday, from: Date()) - 1
    }

    var body: some View {
        let r: CGFloat = size * 0.062
        let dotSize: CGFloat = r * 2
        let gap: CGFloat = dotSize * 1.4

        HStack(spacing: gap) {
            ForEach(0..<7, id: \.self) { i in
                dotView(index: i, r: r)
            }
        }
    }

    @ViewBuilder
    private func dotView(index: Int, r: CGFloat) -> some View {
        let d = r * 2
        if index < todayIndex {
            Circle()
                .fill(Theme.ink.opacity(0.55))
                .frame(width: d, height: d)
        } else if index == todayIndex {
            Circle()
                .fill(Theme.accent)
                .frame(width: d, height: d)
        } else {
            Circle()
                .strokeBorder(Theme.ink.opacity(0.55), lineWidth: r * 0.4)
                .frame(width: d, height: d)
        }
    }
}
