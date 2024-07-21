//
//  ContentView.swift
//  ShareToWatch
//
//  Created by Denis Kotelnikov on 16.07.2024.
//

import SwiftUI
import SwiftData

class ContentViewModel: NSObject, ObservableObject {
    
    let dataTransfer = DataTransfer()
    
    @Published var notes: [Note] = []
        
    override init() {
        super.init()
        DispatchQueue.main.async {
            self.fetchNotes()
        }
        
        dataTransfer.onRecive = { event, externalNote in
            if event == .add {
                print("index add")
                DispatchQueue.main.async {
                    let container = DataContainer.context.container
                    container.mainContext.insert(externalNote)
                    try! container.mainContext.save()
                    self.notes.append(externalNote)
                }
            }
            
            if event == .delete {
           
                if let index = self.notes.firstIndex(where: { $0.id == externalNote.id }) {
                    print("index: \(index) delete")
                    DispatchQueue.main.async {
                        let context = DataContainer.context
                        let note = self.notes[index]
                        context.delete(note)
                        try! context.save()
                        self.notes.remove(at: index)
                    }
                } else {
                    self.notes.forEach {
                        print($0.id, externalNote.id, $0.id == externalNote.id)
                    }
                }
            }
            
            if event == .edit {
                if let index = self.notes.firstIndex(where: { $0.id == externalNote.id }) {
                    print("index: \(index) edit")
                    DispatchQueue.main.async {
                        let context = DataContainer.context
                        self.notes[index].text = externalNote.text
                        self.notes[index].noteType = externalNote.noteType
                        self.notes[index].isCheked = externalNote.isCheked
                        try! context.save()
                    }
                }
            }
        }
    }
    
    @MainActor func fetchNotes() {
        let container = DataContainer.context.container
        self.notes = try! container.mainContext.fetch(SwiftData.FetchDescriptor<Note>())
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
       
        
        try! modelContext.save()
        fetchNotes()
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
    
}

struct ContentView: View {
    
    @Environment(\.scenePhase) 
    var scenePhase

    @StateObject
    var model = ContentViewModel()
    
    @State
    private var showingEditor = false
    
    @State
    private var selectedNote: Note? = nil
    
    var body: some View {
        
        List {
            Section {
                
                Button(action: {
                    model.clearDatabase()
                }, label: {
                    Text("clearDatabase()").foregroundStyle(Color.red)
                })
                
                
                Button(action: {
                    selectedNote = nil
                    showingEditor = true
                }, label: {
                    Text("Create new note")
                })
                

            } header: {
                Text("System")
            }
            
            Section {
                ForEach(model.notes) { note in
                    Button {
                        selectedNote = note
                        showingEditor = true
                    } label: {
                        
                        if note.noteType == "checkbox" {
                            CheckBoxView(note: note) { isChecked in
                                
                                try! DataContainer.context.save()
                                if let data = note.toDictionary() {
                                    model.dataTransfer.sendData(event: .edit, item: data)
                                }
                                
                            }
                        } else {
                            Text(note.text ?? "no text")
                        }
                        
                    }.foregroundStyle(Color.primary)
                }.onDelete(perform: model.delete)
            } header: {
                Text("Notes")
            }

        }.refreshable {
            model.fetchNotes()
        } 
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active, oldPhase == .background {
                model.fetchNotes()
            }
        }
        
        .sheet(isPresented: $showingEditor, onDismiss: {
            model.fetchNotes()
        }, content: {
            NoteEditorView(note: $selectedNote, onCreate: { note in
                if let data = note.toDictionary() {
                    model.dataTransfer.sendData(event: .add, item: data)
                }
            }, onEdit: { note in
                if let data = note.toDictionary() {
                    model.dataTransfer.sendData(event: .edit, item: data)
                }
            })
            
        })
        .navigationTitle("Notes")
    }
}

#Preview {
    ContentView()
}
