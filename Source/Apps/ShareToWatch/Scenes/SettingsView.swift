//
//  SettingsView.swift
//  iOS App
//
//  Created by Denis Kotelnikov on 07.08.2024.
//

import SwiftUI
import FastAppLibrary
import Foil
import MarkdownUI
//import Combine

struct SettingsView: View {
    
    @StateObject
    var viewModel = FirebaseNotesController()
    
    @State var showTerms : Bool = false
    @State var showPrivacy : Bool = false
    @State var hideLogo : Bool = false
    
//    @FoilDefaultStorage(key: "hideLogo")
//    var hideLogoStorage = false
    
    @State var datas = FastApp.shared.settings?.onboardingItems ?? []
    
//    var store = Set<AnyCancellable>()
    
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
                .listRowInsets(.init(top: 0, leading: 0, bottom: 10, trailing: 0))
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
                .listRowInsets(.init(top: 0, leading: 0, bottom: 10, trailing: 0))
                .listRowSeparator(.hidden)
            }
            
            Section {
                Button(action: {
                    FastApp.onboarding.show()
                }, label: {
                    Label("How to use?", systemImage: "questionmark.circle.fill")
                       
                }).foregroundStyle(Color.primary)
            } header: {
                Label("Tutorial", systemImage: "person.crop.circle.fill.badge.questionmark")
            } footer: {
                Text("Show onboarding with list of main features")
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
            
            Section {
                Button(action: {
                    FastApp.subscriptions.showPaywallScreen()
                }, label: {
                    Label("Remove limits", systemImage: "crown.fill")
                }).foregroundStyle(Color.primary)
            } header: {
                Label("Premium", systemImage: "star.fill")
            } footer: {
                Text("Restore purchases")
            }

            Section {
                
                NavigationLink {
                    DocumentsView(text: Documents().get(documents: .terms))
                } label: {
                    Text("Terms of Use")
                }
      
                NavigationLink {
                    DocumentsView(text: Documents().get(documents: .privacy))
                } label: {
                    Text("Privacy Policy")
                }
            }
            
            Section {
                Link("Messenger", destination: URL(string: "https://t.me/imbalanceFighter")!)
                    .foregroundStyle(Color.primary)
            } header: {
                Label("Write to me if you have any questions or problems", systemImage: "envelope.badge.fill")
            } footer: {
                Text("I am waiting for your suggestions and comments")
            }
            
            Section {
                Button(action: {
                    viewModel.deleteAll()
                }, label: {
                    Label("Delete all", systemImage: "trash.fill").foregroundColor(Color.red)
                }).foregroundStyle(Color.primary)
            } header: {
                Label("Database", systemImage: "cylinder.split.1x2")
            } footer: {
                Text("Delete all notes from local database and iCloud from all devices.")
            }
//           
//            Section {
//                Toggle("Logo on the widget", isOn: $hideLogo)
//            } header: {
//                Label("Widget", systemImage: "square.topthird.inset.filled")
//            } footer: {
//                Text("A small logo on the widget. When disabled, it will add some space for the text.")
//            }
 
        }.navigationTitle("Settings")
         
    }
}

struct DocumentsView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var text : String
    
    var body: some View {
        ZStack {
            ScrollView {
                Markdown(text)
                    .markdownTextStyle(textStyle: {
                        ForegroundColor(.black)
                    })
                    .padding()
                
            }
            .background(.white)
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark.circle.fill").font(.system(size: 30))
                            .shadow(color: .black.opacity(0.5), radius: 15, x: 0, y: 10)
                            .foregroundStyle(Color.black)
                    })
                }.padding(.horizontal,30)
                Spacer()
            }
        }
        
    }
}

#Preview {
    SettingsView()
}
