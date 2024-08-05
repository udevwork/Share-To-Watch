//
//  MacOSAppApp.swift
//  MacOSApp
//
//  Created by Denis Kotelnikov on 23.07.2024.
//

import SwiftUI
import SwiftData

@main
struct MacOSAppApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
