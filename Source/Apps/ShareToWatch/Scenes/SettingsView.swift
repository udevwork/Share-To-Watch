//
//  SettingsView.swift
//  iOS App
//
//  Created by Denis Kotelnikov on 07.08.2024.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject
    var viewModel = FirebaseNotesController()
    
//    @State var logo: Bool = true
    
    var body: some View {
        List {
            
            if viewModel.dataTransfer.session?.isPaired == false {
                AlertView(
                    image: "applewatch.slash",
                    title: "Watch is not paired",
                    subtitle: "The notes will not be synchronized",
                    сolor: .red
                )
                .foregroundStyle(Color.primary)
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
                .listRowSeparator(.hidden)
            } 
            
            if viewModel.dataTransfer.session?.isWatchAppInstalled == false {
                AlertView(
                    image: "applewatch.slash",
                    title: "Watch app is not installed",
                    subtitle: "The notes will not be synchronized",
                    сolor: .red
                )
                .foregroundStyle(Color.primary)
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
                .listRowSeparator(.hidden)
            }
            
        
            
            Section {
                Button(action: {
                    viewModel.deleteAll()
                }, label: {
                    Label("Delete all", systemImage: "trash.fill")
                       
                }).foregroundStyle(Color.primary)
            } header: {
                Label("Database", systemImage: "cylinder.split.1x2")
            } footer: {
                Text("Delete all notes from local database and iCloud from all devices.")
            }
            
            Section {
                Button(action: {
                    viewModel.sync()
                }, label: {
                    Label("Sync notes", systemImage: "arrow.down.applewatch")
                       
                }).foregroundStyle(Color.primary)
            } header: {
                Label("Apple Watch", systemImage: "applewatch")
            } footer: {
                Text("Send all notes on your device to Apple Watch.")
            }

//            Section {
//                Toggle("Logo on the widget", isOn: $logo)
//            } header: {
//                Label("Widget", systemImage: "square.topthird.inset.filled")
//            } footer: {
//                Text("A small logo on the widget. When disabled, it will add some space for the text.")
//            }
//            
            
            
            
        }.navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
}
