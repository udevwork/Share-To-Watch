import Cocoa
import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Создайте объект StatusBarController
        NSApplication.shared.disableRelaunchOnLogin()
        FirebaseApp.configure()
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Insert code here to tear down your application
    }
}
