import WidgetKit
import SwiftUI

struct GrimProvider: TimelineProvider {
    private let defaults = UserDefaults(suiteName: "group.com.grim.app")!

    func placeholder(in context: Context) -> GrimEntry {
        makeEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (GrimEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GrimEntry>) -> Void) {
        let entry = makeEntry()
        let midnight = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        )
        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
    }

    private func makeEntry() -> GrimEntry {
        let dob: Date = defaults.object(forKey: "dob") as? Date ?? {
            var c = DateComponents()
            c.year = 1996; c.month = 7; c.day = 17
            return Calendar.current.date(from: c) ?? Date()
        }()
        let le = defaults.integer(forKey: "lifeExpectancy") > 0
            ? defaults.integer(forKey: "lifeExpectancy") : 100

        return GrimEntry(
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
struct GrimWidgetBundle: WidgetBundle {
    var body: some Widget {
        GrimWidget()
        GrimLiveActivity()
    }
}

struct GrimWidget: Widget {
    let kind: String = "GrimWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GrimProvider()) { entry in
            GrimWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("grim")
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

struct GrimWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: GrimEntry

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
