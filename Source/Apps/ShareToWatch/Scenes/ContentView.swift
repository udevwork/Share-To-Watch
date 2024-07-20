//
//  ContentView.swift
//  ShareToWatch
//
//  Created by Denis Kotelnikov on 16.07.2024.
//

import SwiftUI
import WatchConnectivity
import SwiftData


class ContentViewModel: NSObject, ObservableObject, WCSessionDelegate {
    
    @Published var notes: [Note] = []
    
    var session: WCSession? = nil
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) { 
        fetchNotes(session)
    }
    func sessionDidBecomeInactive(_ session: WCSession) { 
        
    }
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    // Попытка извлечь данные из последнего контекста приложения
    func fetchNotes(_ session: WCSession) {
        let receivedApplicationContext = session.receivedApplicationContext
        
        if let receivedNotes = receivedApplicationContext["notes"] as? [[String : Any]] {
            
        }
        
    
    }
    
    func synchronize() {

        if let session = session, session.isPaired && session.isWatchAppInstalled {
            do {
                let notesData = notes.toDictionaryArray()
                try session.updateApplicationContext(["notes": notesData ?? []])
            } catch {
                print("Ошибка при отправке данных на Apple Watch: \(error)")
            }
        }
    }
    
    @MainActor func fetchNotes() {
        let container = DataContainer.context.container
        self.notes = try! container.mainContext.fetch(SwiftData.FetchDescriptor<Note>())
    }
    
    @MainActor func createNewNote(text: String) {
        let note = Note(text: "fuck", noteType: "you")

        let container = DataContainer.context.container
        container.mainContext.insert(note)
        try! container.mainContext.save()
        self.notes.append(note)
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
                    selectedNote = nil
                    showingEditor = true
                }, label: {
                    Text("Create new note")
                })
                
                Button(action: {
                    model.createNewNote(text: "sdf")
                }, label: {
                    Text("Create test note")
                })
                
                Button(action: {
                    model.synchronize()
                }, label:{
                    Text("Synchronize notes")
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
                        CheckBoxView(text: note.text ?? "no text")
                        } else {
                            Text(note.text ?? "no text")
                        }
                        
                    }.foregroundStyle(Color.primary)
                }.onDelete(perform: delete)
            } header: {
                Text("Notes")
            }

        }.refreshable {
            model.fetchNotes()
        } 
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                model.fetchNotes()
            } else if newPhase == .inactive {
                print("Inactive")
            } else if newPhase == .background {
                print("Background")
            }
        }
        
        .sheet(isPresented: $showingEditor, onDismiss: {
            model.fetchNotes()
            model.synchronize()
        }, content: {
            NoteEditorView(note: $selectedNote)
               
        })
        .navigationTitle("Notes")
    }


    func delete(_ indexSet: IndexSet) {
        let modelContext = DataContainer.context
        
        for i in indexSet {
            let note = model.notes[i]
            modelContext.delete(note)
        }
        try! modelContext.save()
    }
    
}

#Preview {
    ContentView()
}
