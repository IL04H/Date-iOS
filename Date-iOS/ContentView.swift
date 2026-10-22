import SwiftUI

struct ContentView: View {
    private var calendar: Calendar { .current }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let date = context.date
            let year = calendar.component(.year, from: date)
            let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
            let daysInYear = calendar.range(of: .day, in: .year, for: date)?.count ?? 365
            let daysLeft = max(daysInYear - dayOfYear, 0)

            VStack(alignment: .leading, spacing: 22) {
                Text("TODAY")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .tracking(2)

                Text(date, format: .dateTime.weekday(.wide).month(.wide).day().year())
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.55)

                HStack(spacing: 14) {
                    Stat(title: "DAY", value: "\(dayOfYear)")
                    Stat(title: "LEFT", value: "\(daysLeft)")
                }

                Text("\(year) • \(Int(Double(dayOfYear) / Double(daysInYear) * 100))% complete")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .padding(28)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            .background(Color(.systemBackground))
        }
    }
}

private struct Stat: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .tracking(1.4)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
    }
}
