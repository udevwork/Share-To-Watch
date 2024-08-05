import SwiftUI
import WidgetKit

@main
struct WatchWidget: Widget {
    let kind: String = "WatchWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DefaultWidgetProvider()) { entry in
            if #available(watchOS 10.0, *) {
                WidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .accessoryRectangular) {
    WatchWidget()
} timeline: {
    DefaultWidgetProvider.Entry(date: .now, lastNote: "hello")
}
