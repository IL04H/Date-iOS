import WidgetKit
import SwiftUI

struct DateWidgetEntry: TimelineEntry {
    let date: Date
}

struct DateWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> DateWidgetEntry {
        DateWidgetEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (DateWidgetEntry) -> Void) {
        completion(DateWidgetEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DateWidgetEntry>) -> Void) {
        let now = Date()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 1, to: now) ?? now.addingTimeInterval(60)
        completion(Timeline(entries: [DateWidgetEntry(date: now)], policy: .after(nextUpdate)))
    }
}

struct DateWidgetView: View {
    let entry: DateWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(entry.date, format: .dateTime.month(.wide).year())
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            Text(entry.date, format: .dateTime.day())
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.6)

            Text(entry.date, format: .dateTime.weekday(.wide))
                .font(.system(size: 13, weight: .medium, design: .rounded))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(.background, for: .widget)
    }
}

@main
struct DateWidget: Widget {
    let kind = "DateWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DateWidgetProvider()) { entry in
            DateWidgetView(entry: entry)
        }
        .configurationDisplayName("Date")
        .description("A clean calendar date for your Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
