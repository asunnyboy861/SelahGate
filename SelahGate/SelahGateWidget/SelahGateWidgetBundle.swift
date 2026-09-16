import SwiftUI
import WidgetKit

struct DailyVerseEntry: TimelineEntry {
    let date: Date
    let ref: String
    let text: String
}

struct DailyVerseProvider: TimelineProvider {
    func placeholder(in context: Context) -> DailyVerseEntry {
        DailyVerseEntry(date: Date(), ref: "PSA 46:10", text: "Be still, and know that I am God.")
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyVerseEntry) -> Void) {
        completion(entry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyVerseEntry>) -> Void) {
        let nextMidnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400 * 2))
        completion(Timeline(entries: [entry()], policy: .after(nextMidnight)))
    }

    private func entry() -> DailyVerseEntry {
        let day = VerseLibrary.currentDayIndex
        if let cached = AppGroupStore.cachedVerseOfDay(dayIndex: day) {
            return DailyVerseEntry(date: Date(), ref: cached.ref, text: cached.text)
        }
        let fallback = VerseLibrary.randomToday()
        return DailyVerseEntry(date: Date(), ref: fallback.ref, text: fallback.text)
    }
}

struct SelahGateWidgetView: View {
    let entry: DailyVerseEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.text)
                .font(.system(.headline, design: .serif))
                .lineLimit(5)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 0)
            Text("— \(entry.ref)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .containerBackground(for: .widget) {
            Theme.dawn
        }
    }
}

@main
struct SelahGateWidgetBundle: WidgetBundle {
    var body: some Widget {
        SelahGateWidget()
    }
}

struct SelahGateWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "SelahGateDailyVerse", provider: DailyVerseProvider()) { entry in
            SelahGateWidgetView(entry: entry)
        }
        .configurationDisplayName("Daily Verse")
        .description("Today's Selah — one verse, refreshed every morning.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular])
    }
}
