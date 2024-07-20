//
//  ShareToWatchApp.swift
//  ShareToWatch
//
//  Created by Denis Kotelnikov on 16.07.2024.
//

import SwiftUI
import SwiftData

@main
struct ShareToWatchApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView().modelContainer(for: Note.self)
            }
        }
    }
}
