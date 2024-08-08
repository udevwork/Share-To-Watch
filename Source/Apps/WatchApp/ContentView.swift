//
//  ContentView.swift
//  СtWWatchExt Watch App
//
//  Created by Denis Kotelnikov on 16.07.2024.
//

import SwiftUI
import WatchConnectivity
import SwiftData
import WidgetKit
import Combine

class ContentViewModel: NSObject, ObservableObject {
    var dataTransfer = WatchDataTransfer()
    @Published var notes: [Note] = []
    var store = Set<AnyCancellable>()

    
    override init() {
        super.init()
        
        DispatchQueue.main.async {
            self.fetchNotes()
        }
        
        dataTransfer.emitter.sink { (event, externalNote) in
            DispatchQueue.main.async {
                
                guard let note = Note.fromDictionary(externalNote) else {
                    return
                }
                
                if event == .add {
                    print("index add")
                    
                    let container = DataContainer.context.container
                    container.mainContext.insert(note)
                    try! container.mainContext.save()
                    self.notes.append(note)
                    
                }
                
                if event == .delete {
                    if let index = self.notes.firstIndex(where: { $0.id == note.id }) {
                        print("index: \(index) delete")
                        
                        let context = DataContainer.context
                        let note = self.notes[index]
                        context.delete(note)
                        try! context.save()
                        self.notes.remove(at: index)
                        
                    }
                }
                
                if event == .edit {
                    if let index = self.notes.firstIndex(where: { $0.id == note.id }) {
                        print("index: \(index) edit")
                        
                        let context = DataContainer.context
                        self.notes[index].text = note.text
                        self.notes[index].noteType = note.noteType
                        self.notes[index].isCheked = note.isCheked
                        try! context.save()
                        
                    }
                }
            }
        }.store(in: &store)
    }
    
    @MainActor func fetchNotes() {
        let container = DataContainer.context.container
        self.notes = try! container.mainContext.fetch(FetchDescriptor<Note>())
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WC Session activation failed with error: \(error.localizedDescription)")
            return
        }

    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {

    }
    
    func clearDatabase() {
        DispatchQueue.main.async {
            let context = DataContainer.context
            do {
                try context.delete(model: Note.self)
                self.fetchNotes()
            } catch {
                print("Failed to clear all Country and City data.")
            }
        }
    }
    
    
    @MainActor func delete(_ indexSet: IndexSet) {
        let modelContext = DataContainer.context
        
        indexSet.forEach { i in
            print("PERFORM DELETE index: \(i), count: \(notes.count)")
            let note = notes[i]
            modelContext.delete(note)
            if let data = note.toDictionary() {
                dataTransfer.sendData(event: .delete, item: data)
            }
        }
    }
    
    
    @MainActor func delete(note: Note) {
        let modelContext = DataContainer.context
        if let data = note.toDictionary() {
            modelContext.delete(note)
            dataTransfer.sendData(event: .delete, item: data)
            self.fetchNotes()
        }
    }
}


struct ContentView: View {
    
    @StateObject var model = ContentViewModel()
    
    @State var counter = 0
    
    var body: some View {
        NavigationStack {
            List {
               
                if model.dataTransfer.session?.isCompanionAppInstalled == false {
                    WatchAlertView(
                        image: "iphone.slash",
                        title: "iPhone app is not installed",
                        subtitle: "The notes will not be synchronized",
                        сolor: .red
                    )
                    .foregroundStyle(Color.primary)
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
                }
                
                Section {
                    ForEach(
                        model.notes.sorted(by: { $0.sortingIndex > $1.sortingIndex }),
                        id: \.id
                    ) { note in
                        if note.noteType == .checkbox {
                            CheckBoxView(note: note) { isChecked in
                                
                                try! DataContainer.context.save()
                                if let data = note.toDictionary() {
                                    model.dataTransfer.sendData(event: .edit, item: data)
                                }
                                
                            }
                        } else {
                            Text(note.text ?? "-")
                                .swipeActions {
                                    Button {
                                        SharedDefaults.saveDataToAppGroup(note: note.text ?? "-")
                                        WidgetCenter.shared.reloadAllTimelines()
                                    } label: {
                                        Label("show on widget", systemImage: "rectangle.portrait.tophalf.inset.filled")
                                    }
                                    .tint(.green)
                                    
                                    Button {
                                        model.delete(note: note)
                                    } label: {
                                        Image(systemName: "trash.fill")
                                    }.tint(.red)
                                }
                        }
                    }.onDelete(perform: model.delete)
                        
                } header: {
                    Text("v0.106")
                } footer: {
                    Text("Edit notes in ios app")
                }
                
     
            }.navigationTitle("Notes")
        }
    }
}

#Preview {
    ContentView()
}
