//
//  ShareToWatchApp.swift
//  ShareToWatch
//
//  Created by Denis Kotelnikov on 16.07.2024.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FastAppLibrary
import RevenueCat

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      FirebaseApp.configure()
      
      let onboarding: [OnBoardingModel] = [
        .init(image: "1", title: "Widget on the Watch Face", subTitle: "Quick access to any note directly from \"Always On.\"."),
        .init(image: "2", title: "Notes and Planner", subTitle: "Data is stored locally and in your iCloud. You always have access."),
        .init(image: "3", title: "Synchronization", subTitle: "Connection with your watch does not depend on the internet. Even without your phone, you can still access data on your watch."),
        .init(image: "4", title: "MacOS", subTitle: "For the best experience, use the desktop version of the app. All notes are synchronized."),
        .init(image: "5", title: "Text Editor", subTitle: "A simple and easy way to create notes or to-do lists."),
        .init(image: "6", title: "Lock Screen Widget", subTitle: "Display the most important information on the screen so you don't forget anything!"),
        .init(image: "7", title: "Convenience", subTitle: "Manage the widget on the watch face directly from your watch."),
        .init(image: "8", title: "Widget on iPhone", subTitle: "A quick and easy reminder of the most important things!"),
        .init(image: "9", title: "Full Control", subTitle: "All data is synchronized automatically, but you can adjust the information manually."),
      ]
      
      let benefits: [PaywallBenefitItem] = [
        .init(systemIcon: "wand.and.stars.inverse",
              title: "Unlimited",
              subtitle: "Create notes without any limits."),
        .init(systemIcon: "icloud.and.arrow.up.fill",
              title: "Synchronization",
              subtitle: "Your notes are synced across all devices."),
        .init(systemIcon: "sparkles.rectangle.stack",
              title: "Quick Access",
              subtitle: "Widgets on watch faces, home screen, and lock screen.")
      ]
    
      let settings = FastAppSettings(
        appName: "Share to Watch",
        companyName: "01lab",
        companyEmail: "udevwork@email.com",
        revenueCatAPI: "appl_wudhAj...MlggW",
        paywallBenefits: benefits,
        onboardingItems: onboarding
      )
      
      // mock subscription
      FastApp.subscriptions._mockProducts = [
        PaywallProductItemModel(
              id: "product_1",
              numereticPrice: 0.99,
              product: StoreProduct(sk1Product: SK1Product()),
              title: "Weekly",
              subtitle: "",
              subscriptionPeriod: "1 Week",
              price: "$0.99",
              bestValue: false,
              introductoryPeriod: "3 days",
              offPersent: "10%"
          ),
          PaywallProductItemModel(
              id: "product_2",
              numereticPrice: 2.99,
              product: StoreProduct(sk1Product: SK1Product()),
              title: "Monthly",
              subtitle: "",
              subscriptionPeriod: "1 Month",
              price: "$2.99",
              bestValue: true,
              introductoryPeriod: nil,
              offPersent: "15%"
          ),
          PaywallProductItemModel(
              id: "product_3",
              numereticPrice: 7.99,
              product: StoreProduct(sk1Product: SK1Product()),
              title: "3 Month",
              subtitle: "",
              subscriptionPeriod: "3 Month",
              price: "$7.99",
              bestValue: false,
              introductoryPeriod: nil,
              offPersent: nil
          )
    ]
      
      FastApp.shared.setup(settings)
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
            }.fastAppDefaultWrapper()
            
        }
    }
}
