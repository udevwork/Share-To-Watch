//
//  ContentView.swift
//  MacOSApp
//
//  Created by Denis Kotelnikov on 23.07.2024.
//

import SwiftUI
import SwiftData
import Combine
import CloudKit


struct ContentView: View {
  
    var body: some View {
        NavigationSplitView {
            List {
          
                NavigationLink {
                    FirebaseView()
                } label: {
                    Text("Firebase")
                }
                NavigationLink {
                    Text("Settings")
                } label: {
                    Text("Settings")
                }
                NavigationLink {
                    Text("About")
                } label: {
                    Text("About")
                }
   
            }
            .navigationSplitViewColumnWidth(min: 100, ideal: 130)
        } detail: {
            //FirebaseView()
        }
    }
}

#Preview {
    ContentView()
}
