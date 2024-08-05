//
//  iOSWidgetLiveActivity.swift
//  iOSWidget
//
//  Created by Denis Kotelnikov on 23.07.2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct iOSWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct iOSWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: iOSWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension iOSWidgetAttributes {
    fileprivate static var preview: iOSWidgetAttributes {
        iOSWidgetAttributes(name: "World")
    }
}

extension iOSWidgetAttributes.ContentState {
    fileprivate static var smiley: iOSWidgetAttributes.ContentState {
        iOSWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: iOSWidgetAttributes.ContentState {
         iOSWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: iOSWidgetAttributes.preview) {
   iOSWidgetLiveActivity()
} contentStates: {
    iOSWidgetAttributes.ContentState.smiley
    iOSWidgetAttributes.ContentState.starEyes
}
