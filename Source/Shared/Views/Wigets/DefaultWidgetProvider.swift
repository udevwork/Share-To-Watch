//
//  DefaultWidgetProvider.swift
//  ShareToWatch
//
//  Created by Denis Kotelnikov on 23.07.2024.
//

import Foundation
import WidgetKit
import SwiftUI

struct Entry: TimelineEntry {
    let date: Date
    let lastNote: String
}

struct DefaultWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), lastNote: "hello")
    }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
        let entry = Entry(date: Date(), lastNote: "hello")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [Entry] = []

        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let lastNote = SharedDefaults.fetchLastNote()
            let entry = Entry(date: entryDate, lastNote: lastNote)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
