import WidgetKit
import SwiftUI

struct iOSWidget: Widget {
    let kind: String = "iOSWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DefaultWidgetProvider()) { entry in
            if #available(iOS 17.0, *) {
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
        .supportedFamilies(
            [
                .systemSmall,
                .systemMedium,
                .systemLarge,
                .systemExtraLarge,
                .accessoryInline,
                .accessoryCircular,
                .accessoryRectangular
            ])
    }
}

#Preview(as: .systemSmall) {
    iOSWidget()
} timeline: {
    DefaultWidgetProvider.Entry(date: .now, lastNote: "test")
}
