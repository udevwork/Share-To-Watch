//
//  FirebaseNotesController.swift
//  ShareToWatch
//
//  Created by Denis Kotelnikov on 27.07.2024.
//

import Foundation
import SwiftData
import SwiftUI
import Combine
import CloudStorage

class FirebaseNotesController: ObservableObject {
    
    enum DataBaseChangesTarget {
        case Remote
        case Local
        case Watch
    }
        
    // Notes
    @Published
    var items: [Note] = []
        
    var store = Set<AnyCancellable>()
    
#if os(iOS) || os(watchOS)
    let dataTransfer = WatchDataTransfer()
#endif
    
    init() {
        initialSetup()
    }
    
    func initialSetup() {
        DispatchQueue.main.async {
            self.fetchNotes()
#if os(iOS) || os(watchOS)
            self.subscribeWatchConnectivityChanges()
#endif
        }
    }

#if os(iOS) || os(watchOS)
    func subscribeWatchConnectivityChanges() {
        
        dataTransfer.emitter.sink { (event, externalNote) in
            DispatchQueue.main.async {
                guard let note = Note.fromDictionary(externalNote) else {
                    return
                }
                
                if event == .add {
                    print("index add")
                    
                    let container = DataContainer.context.container
                    container.mainContext.insert(note)
                    try? container.mainContext.save()
                    self.items.append(note)
                    self.create(note: note, targets: [.Local,.Remote])
                    
                }
                
                if event == .delete {
                    if let index = self.items.firstIndex(where: { $0.id == note.id }) {
                        print("index: \(index) delete")
                        
                        let context = DataContainer.context
                        let note = self.items[index]
                        context.delete(note)
                        try? context.save()
                        self.items.remove(at: index)
                        self.deleteItems(note: note, targets: [.Local,.Remote])
                        
                    }
                }
                
                if event == .edit {
                    if let index = self.items.firstIndex(where: { $0.id == note.id }) {
                        print("index: \(index) edit")
                        
                        self.items[index].text = note.text
                        self.items[index].noteType = note.noteType
                        self.items[index].isCheked = note.isCheked
                        try? DataContainer.context.save()
                        self.update(note: note, targets: [.Local,.Remote])
                        
                    }
                }
            }
        }.store(in: &store)
    }
#endif
    
    @MainActor
    func fetchNotes() {
        // LOCAL
        do {
            let _items = try DataContainer.context.fetch(FetchDescriptor<Note>())
            self.items = _items.sorted(by: {
                $0.viewID = UUID().uuidString
                return $0.sortingIndex > $1.sortingIndex
            })
        } catch let err {
            print("ERROR:", err)
        }
        
    }
    
    // создание заметки на маке
    func createNote() {
        let id = UUID().uuidString
        let note = Note(id: id)
        DispatchQueue.main.async {
            DataContainer.context.insert(note)
            note.text = "New note"
            self.items.append(note)
        }
    }
    
    
    func create(note: Note, targets: [DataBaseChangesTarget]) {
        
        if items.first(where: { $0.id == note.id }) != nil { return }
        
        guard let id = note.id else { return }
                
        targets.forEach { target in
            switch target {
                case .Remote:
                    break
                case .Local:
                    DispatchQueue.main.async {
                        DataContainer.context.insert(note)
                        self.items.append(note)
                    }
                case .Watch:
#if os(iOS) || os(watchOS)
                    if let data = note.toDictionary() {
                        dataTransfer.sendData(event: .add, item: data)
                    }
#endif
                    break
            }
        }
    }
    
    func update(note: Note, targets: [DataBaseChangesTarget]) {
        
        guard let id = note.id else { return }
        
        targets.forEach { target in
            switch target {
                case .Remote:
                    break
                case .Local:
                    if let exisedNoteIndex = items.firstIndex(where: { $0.id == note.id }) {
                        items[exisedNoteIndex] = note
                    }
                case .Watch:
#if os(iOS) || os(watchOS)
                    if let data = note.toDictionary() {
                        dataTransfer.sendData(event: .edit, item: data)
                    }
#endif
            }
        }
    }
 
    
    func deleteItems(note: Note, targets: [DataBaseChangesTarget]) {
        guard let id = note.id else { return }
        
        guard let indexToDelete = self.items.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        targets.forEach { target in
            switch target {
                case .Remote:
                    break
                case .Local:
                    withAnimation {
                        DispatchQueue.main.async {
                            DataContainer.context.delete(self.items[indexToDelete])
                            self.items.remove(at: indexToDelete)
                        }
                    }
                case .Watch:
#if os(iOS) || os(watchOS)
                    if let dic = note.toDictionary() {
                        dataTransfer.sendData(event: .delete, item: dic)
                    }
#endif
            }
        }
    }
    
    func delete(_ indexSet: IndexSet) {
        indexSet.forEach { i in
            self.deleteItems(note: items[i], targets: .all)
        }
    }
    
    func updateSortingIndexes(){
        for (index, element) in items.reversed().enumerated() {
            element.sortingIndex = index
        }
    }
    
    
    func deleteAll() {
        DispatchQueue.main.async {
            do {
                try DataContainer.context.delete(model: Note.self)
            } catch {
                print("Failed to clear all data.")
            }
        }
    }
    
    
    func sync() {
        items.forEach { note in
#if os(iOS) || os(watchOS)
            if let data = note.toDictionary() {
                dataTransfer.sendData(event: .add, item: data)
            }
#endif
        }
      
    }
    
    
}

extension [FirebaseNotesController.DataBaseChangesTarget] {
    static var all : [FirebaseNotesController.DataBaseChangesTarget] = {
        [.Local,.Remote,.Watch]
    }()
}
