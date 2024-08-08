//
//  ShareToWatchApp.swift
//  ShareToWatch
//
//  Created by Denis Kotelnikov on 16.07.2024.
//

import SwiftUI
import SwiftData
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}


@main
struct ShareToWatchApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State var mode: EditMode = .inactive
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack {
                    ContentView()
                        .environment(\.editMode, self.$mode)
                }.tabItem {
                    Label("Notes", systemImage: "note.text")
                }
                NavigationStack {
                    SettingsView()
                }.tabItem {
                    Label("Settings", systemImage: "gear")
                }
            }
            
        }
    }
}
