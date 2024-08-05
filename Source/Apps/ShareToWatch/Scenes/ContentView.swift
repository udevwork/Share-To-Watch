//
//  ContentView.swift
//  ShareToWatch
//
//  Created by Denis Kotelnikov on 16.07.2024.
//

import SwiftUI
import SwiftData
import Combine

struct ContentView: View {
    
    @Environment(\.scenePhase) 
    var scenePhase

    @StateObject
    var firbase = FirebaseNotesController()
    
    @State
    private var showingEditor = false
    
    @State
    private var selectedNote: Note? = nil
    
    @State
    private var containerID: String = "no"
    
    var body: some View {
        
        List {
            Section {
                if let txt = firbase.remoteFirebaseCollectionID {
                    Text(txt)
                } else {
                    Text("no id")
                }
                
                Button {
                    firbase.remoteFirebaseCollectionID = nil
                } label: {
                    Text("clear fireID")
                }

                Button {
                    firbase.remoteFirebaseCollectionID = UUID().uuidString
                } label: {
                    Text("new fireID")
                }

                
                ForEach(firbase.items) { note in
                    
                    Button {
                        selectedNote = note
                        showingEditor = true
                    } label: {
                        
                        if note.noteType == .checkbox {
                            CheckBoxView(note: note) { isChecked in
                                firbase.update(note: note, targets: [.Local,.Remote, .Watch])
                            }
                        } else {
                            Text(note.text ?? "no text")
                        }
                        
                    }.foregroundStyle(Color.primary)
                }
                    .onDelete { set in
                        firbase.delete(set)
                    }
            } header: {
                Text("Notes")
            }

        }.refreshable {
//            model.fetchNotes()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active, oldPhase == .background {
//                model.fetchNotes()
            }
        }
        .sheet(isPresented: $showingEditor, onDismiss: {
//            model.fetchNotes()
        }, content: {
            NoteEditorView(note: $selectedNote, onCreate: { note in
                
                firbase.create(note: note, targets: [.Local,.Remote, .Watch])
            }, onEdit: { note in
                
                firbase.update(note: note, targets: [.Local,.Remote, .Watch])
            })
            
        })
        .navigationTitle("Notes")
        .toolbar {
            Button(action: {
           
                selectedNote = nil
                showingEditor = true
            }, label: {
                Image(systemName: "plus.circle.fill")  .foregroundStyle(Color.green)
            })
            
        }
    }
}

#Preview {
    ContentView()
}
