//
//  ContentView.swift
//  ShareToWatch
//
//  Created by Denis Kotelnikov on 16.07.2024.
//

import SwiftUI
import SwiftData
import Combine
import WidgetKit

struct ContentView: View {
    
    @Environment(\.scenePhase) 
    var scenePhase

    @StateObject
    var viewModel = FirebaseNotesController()
    
    @State
    private var showingEditor = false
    
    @State
    private var selectedNote: Note? = nil

    @Environment(\.editMode)
    private var editMode
    
    var body: some View {
        
        List() {
//            Text("An application that allows you to conveniently send any note to your watch and show it on the dial").listRowBackground(Color.clear)
                    
            Section {
            
                ForEach(
                    (editMode?.wrappedValue ?? .inactive) == .active ? viewModel.items :
                    viewModel.items.sorted(by: { $0.sortingIndex > $1.sortingIndex }),
                    id: \.viewID
                ) { note in
                    
                    Button {
                        selectedNote = note
                        showingEditor = true
                    } label: {
                        
                        if note.noteType == .checkbox {
                            CheckBoxView(note: note) { isChecked in
                                viewModel.update(note: note, targets: .all)
                            }
                        } else {
                            Text(note.text ?? "no text")
                        }
                        
                    }
                    .foregroundStyle(Color.primary)
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
                    .contextMenu {
                        Section("Watch sync") {
                            Button("Update") {
                                if let data = note.toDictionary() {
                                    viewModel.dataTransfer.sendData(event: .edit, item: data)
                                }
                            }
                            Button("Add") {
                                if let data = note.toDictionary() {
                                    viewModel.dataTransfer.sendData(event: .add, item: data)
                                }
                            }
                        }
                    } preview: {
                        HStack {
                            Text(note.text ?? "no text")
                                .lineLimit(3)
                                .padding()
                        }
                    }
                    .swipeActions {
                        Button {
                            SharedDefaults.saveDataToAppGroup(note: note.text ?? "-")
                            WidgetCenter.shared.reloadAllTimelines()
                        } label: {
                            Label("show on widget", systemImage: "rectangle.portrait.tophalf.inset.filled")
                        }
                        .tint(.green)
                        
                        Button {
                            viewModel.deleteItems(note: note, targets: .all)
                        } label: {
                            Image(systemName: "trash.fill")
                        }.tint(.red)
                    }
                    
                }

                .onMove(perform: move)
               
            }
        }
        .refreshable {
            viewModel.fetchNotes()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active, oldPhase == .background {
                viewModel.fetchNotes()
            }
        }
        .sheet(isPresented: $showingEditor, onDismiss: {
            viewModel.fetchNotes()
        }, content: {
            NoteEditorView(note: $selectedNote, onCreate: { note in
                viewModel.create(note: note, targets: .all)
            }, onEdit: { note in
                viewModel.update(note: note, targets: .all)
            })
        })
        .navigationTitle("Notes")
        .animation(nil, value: editMode?.wrappedValue)
        .toolbar {
            EditButton()
            Button(action: {
                selectedNote = nil
                showingEditor = true
            }, label: {
                Image(systemName: "plus.circle.fill")
            })
           
        }
        .onAppear {
            viewModel.updateSortingIndexes()
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        viewModel.items.move(fromOffsets: source, toOffset: destination)
        viewModel.updateSortingIndexes()
    }
}

#Preview {
    ContentView()
}
