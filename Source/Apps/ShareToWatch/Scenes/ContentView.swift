//
//  ContentView.swift
//  ShareToWatch
//
//  Created by Denis Kotelnikov on 16.07.2024.
//

import SwiftUI
import WatchConnectivity
import CoreData

class DataController: ObservableObject {
    static let shared = DataController()
    
    let container: NSPersistentContainer
    
    init() {
        
        container = NSPersistentContainer(name: "Notes")
        let storeURL = URL.storeURL(for: "group.01lab", databaseName: "Notes")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}

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
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) { }
    func sessionDidBecomeInactive(_ session: WCSession) { }
    func sessionDidDeactivate(_ session: WCSession) { }
    
    func synchronize() {
        if let session = session, session.isPaired && session.isWatchAppInstalled {
            do {
                let notesData = notes.toDictionaryArray()
                try session.updateApplicationContext(["notes": notesData])
            } catch {
                print("Ошибка при отправке данных на Apple Watch: \(error)")
            }
        }
    }
    
    func fetchNotes() {
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        notes = try! DataController.shared.container.viewContext.fetch(fetchRequest)
        synchronize()
    }
    
    func createNewNote(text: String) {
        let core = CoreData.shared
        let context = core.persistentContainer.viewContext
        let newNote = Note(context: context)
        newNote.text = text
        newNote.noteType = "test type"
        core.saveContext()
        fetchNotes()
        synchronize()
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
                        Text(note.text ?? "no text")
                    }.foregroundStyle(Color.primary)
                }.onDelete(perform: delete)
            } header: {
                Text("Notes")
            }

        } .refreshable {
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
                .environment(
                    \.managedObjectContext,
                     DataController.shared.container.viewContext
                )
        })
        .navigationTitle("Notes")
    }


    // Для использования с жестом swipe для удаления
    func delete(at offsets: IndexSet) {
        for index in offsets {
            let note = model.notes[index]
            DataController.shared.container.viewContext.delete(note)
        }
        try? DataController.shared.container.viewContext.save()
        model.fetchNotes()
    }
    
}

#Preview {
    ContentView()
}
