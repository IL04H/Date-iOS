import WidgetKit
import SwiftUI

struct DateWidgetEntry: TimelineEntry {
    let date: Date
}

struct DateWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> DateWidgetEntry { DateWidgetEntry(date: .now) }
    func getSnapshot(in context: Context, completion: @escaping (DateWidgetEntry) -> Void) { completion(DateWidgetEntry(date: .now)) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<DateWidgetEntry>) -> Void) {
        let now = Date()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 1, to: now) ?? now.addingTimeInterval(60)
        completion(Timeline(entries: [DateWidgetEntry(date: now)], policy: .after(nextUpdate)))
    }
}

private let cal = Calendar.current

private func dayStart(_ date: Date) -> Date { cal.startOfDay(for: date) }

private func daysUntil(_ date: Date, from now: Date) -> Int {
    max(cal.dateComponents([.day], from: dayStart(now), to: dayStart(date)).day ?? 0, 0)
}

private func nextDate(month: Int, day: Int, from now: Date) -> Date {
    let year = cal.component(.year, from: now)
    var comps = DateComponents(year: year, month: month, day: day)
    let candidate = cal.date(from: comps) ?? now
    if candidate >= dayStart(now) { return candidate }
    comps.year = year + 1
    return cal.date(from: comps) ?? candidate
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
            Text(entry.date, format: .dateTime.weekday(.wide))
                .font(.system(size: 13, weight: .medium, design: .rounded))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(.background, for: .widget)
    }
}

struct CountdownWidgetView: View {
    let entry: DateWidgetEntry
    let title: String
    let symbol: String
    let target: (Date) -> Date
    var body: some View {
        let event = target(entry.date)
        let days = daysUntil(event, from: entry.date)
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: symbol).font(.system(size: 18, weight: .semibold))
            Spacer(minLength: 2)
            Text("\(days)")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.6)
            Text(days == 1 ? "DAY" : "DAYS")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
            Text("until \(title)")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(.background, for: .widget)
    }
}

struct YearProgressWidgetView: View {
    let entry: DateWidgetEntry
    var body: some View {
        let year = cal.component(.year, from: entry.date)
        let day = cal.ordinality(of: .day, in: .year, for: entry.date) ?? 1
        let total = cal.range(of: .day, in: .year, for: entry.date)?.count ?? 365
        let progress = Double(day) / Double(total)
        let left = total - day
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("YEAR \(year)").font(.system(size: 12, weight: .bold, design: .rounded))
                Spacer()
                Text("\(Int(progress * 100))%").font(.system(size: 12, weight: .bold, design: .rounded))
            }
            Spacer(minLength: 2)
            Text("\(day)").font(.system(size: 42, weight: .bold, design: .rounded))
            Text("days gone  •  \(left) left")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
            ProgressView(value: progress)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(.background, for: .widget)
    }
}

struct DateWidget: Widget {
    let kind = "DateWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DateWidgetProvider()) { entry in DateWidgetView(entry: entry) }
            .configurationDisplayName("Today")
            .description("Current date, day and weekday.")
            .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct YearProgressWidget: Widget {
    let kind = "YearProgressWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DateWidgetProvider()) { entry in YearProgressWidgetView(entry: entry) }
            .configurationDisplayName("Year Progress")
            .description("See how much of the year is gone and left.")
            .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct NewYearWidget: Widget {
    let kind = "NewYearWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DateWidgetProvider()) { entry in
            CountdownWidgetView(entry: entry, title: "New Year", symbol: "sparkles") { now in
                let year = cal.component(.year, from: now)
                return cal.date(from: DateComponents(year: year + 1, month: 1, day: 1)) ?? now
            }
        }
        .configurationDisplayName("New Year Countdown")
        .description("Days until the next New Year.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct HalloweenWidget: Widget {
    let kind = "HalloweenWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DateWidgetProvider()) { entry in
            CountdownWidgetView(entry: entry, title: "Halloween", symbol: "moon.stars.fill") { now in
                nextDate(month: 10, day: 31, from: now)
            }
        }
        .configurationDisplayName("Halloween Countdown")
        .description("Days until Halloween.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct ChristmasWidget: Widget {
    let kind = "ChristmasWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DateWidgetProvider()) { entry in
            CountdownWidgetView(entry: entry, title: "Christmas", symbol: "gift.fill") { now in
                nextDate(month: 12, day: 25, from: now)
            }
        }
        .configurationDisplayName("Christmas Countdown")
        .description("Days until Christmas.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct DateWidgets: WidgetBundle {
    var body: some Widget {
        DateWidget()
        YearProgressWidget()
        NewYearWidget()
        HalloweenWidget()
        ChristmasWidget()
    }
}
