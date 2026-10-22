import SwiftUI

struct ContentView: View {
    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            VStack(alignment: .leading, spacing: 12) {
                Text("TODAY")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .tracking(2)

                Text(
                    context.date,
                    format: .dateTime
                        .weekday(.wide)
                        .month(.wide)
                        .day()
                        .year()
                )
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.6)
            }
            .padding(28)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            .background(Color(.systemBackground))
        }
    }
}
