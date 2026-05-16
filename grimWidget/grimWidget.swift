import WidgetKit
import SwiftUI

struct LiveMoreProvider: TimelineProvider {
    private let defaults = UserDefaults(suiteName: "group.com.moretolife.app")!

    func placeholder(in context: Context) -> LiveMoreEntry {
        makeEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (LiveMoreEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LiveMoreEntry>) -> Void) {
        let entry = makeEntry()
        let midnight = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        )
        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
    }

    private func makeEntry() -> LiveMoreEntry {
        let dob: Date = defaults.object(forKey: "dob") as? Date ?? {
            var c = DateComponents()
            c.year = 1996; c.month = 7; c.day = 17
            return Calendar.current.date(from: c) ?? Date()
        }()
        let le = defaults.integer(forKey: "lifeExpectancy") > 0
            ? defaults.integer(forKey: "lifeExpectancy") : 100

        return LiveMoreEntry(
            date: Date(),
            daysRemaining: DateCalculator.daysRemaining(dob: dob, lifeExpectancy: le),
            weeksRemaining: DateCalculator.weeksRemaining(dob: dob, lifeExpectancy: le),
            yearsRemaining: DateCalculator.yearsRemaining(dob: dob, lifeExpectancy: le),
            percentLived: DateCalculator.percentLived(dob: dob, lifeExpectancy: le),
            weeksLived: DateCalculator.weeksLived(from: dob),
            lifeExpectancy: le,
            dob: dob,
            widgetDisplayUnit: defaults.string(forKey: "widgetDisplayUnit") ?? "days",
            contextBriefing: defaults.string(forKey: "contextBriefing"),
            currentStreak: max(0, defaults.integer(forKey: "currentStreak"))
        )
    }
}

@main
struct LiveMoreWidgetBundle: WidgetBundle {
    var body: some Widget {
        LiveMoreWidget()
        LiveMoreContextWidget()
        if #available(iOS 16.1, *) {
            LiveMoreLiveActivity()
        }
    }
}

struct LiveMoreWidget: Widget {
    let kind: String = "LiveMoreWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LiveMoreProvider()) { entry in
            LiveMoreWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("more to life")
        .description("how many days do you have left?")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

struct LiveMoreContextWidget: Widget {
    let kind: String = "LiveMoreContextWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LiveMoreProvider()) { entry in
            LiveMoreContextWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("right now")
        .description("today's suggestion from more to life.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

struct LiveMoreContextWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: LiveMoreEntry

    private var isLockScreen: Bool { family == .accessoryRectangular }

    var body: some View {
        if isLockScreen {
            if #available(iOS 17, *) {
                content.containerBackground(.clear, for: .widget)
            } else {
                content
            }
        } else {
            if #available(iOS 17, *) {
                content.containerBackground(Color(hex: "#0a0a0a"), for: .widget)
            } else {
                ZStack {
                    Color(hex: "#0a0a0a")
                    content
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .systemMedium:
            ContextMediumWidgetView(entry: entry)
        case .accessoryRectangular:
            ContextLockScreenRectangularView(entry: entry)
        default:
            ContextSmallWidgetView(entry: entry)
        }
    }
}

struct LiveMoreWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: LiveMoreEntry

    var body: some View {
        if #available(iOS 17, *) {
            content
                .containerBackground(Color(hex: "#0a0a0a"), for: .widget)
        } else {
            ZStack {
                Color(hex: "#0a0a0a")
                content
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        case .accessoryCircular:
            LockScreenCircularView(entry: entry)
        case .accessoryRectangular:
            LockScreenRectangularView(entry: entry)
        case .accessoryInline:
            Text("\(entry.daysRemaining) days")
        default:
            MediumWidgetView(entry: entry)
        }
    }
}
