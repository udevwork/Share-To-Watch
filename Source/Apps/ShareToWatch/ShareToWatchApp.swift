//
//  ShareToWatchApp.swift
//  ShareToWatch
//
//  Created by Denis Kotelnikov on 16.07.2024.
//

import SwiftUI

@main
struct ShareToWatchApp: App {
    @StateObject private var dataController = DataController()
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
                    .environment(\.managedObjectContext, dataController.container.viewContext)
            }
        }
    }
}
