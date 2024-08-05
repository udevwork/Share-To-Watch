//
//  FirebaseNotesController.swift
//  ShareToWatch
//
//  Created by Denis Kotelnikov on 27.07.2024.
//

import Foundation
import FirebaseFirestore
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
    
    // Service
    @CloudStorage("FirebaseCollectionID")
    var remoteFirebaseCollectionID: String?
    
    private var listenerRegistration: ListenerRegistration?
    
    lazy var remoteDB: FirebaseFirestore.CollectionReference? = {
        guard let id = remoteFirebaseCollectionID else { return nil }
        let db = Firestore.firestore()
        return db.collection(id)
    }()
    
    var context: ModelContext = DataContainer.context
    
    private var initialFetchFinished: Bool = false
    
    var store = Set<AnyCancellable>()
    
#if os(iOS)
    let dataTransfer = WatchDataTransfer()
#endif
    
    init() {
        checkSyncID()
    }
    
    func checkSyncID() {
        self.remoteFirebaseCollectionID.publisher.sink { test in
            print("out \(test)")
            if self.remoteFirebaseCollectionID == nil {
                print("out remoteFirebaseCollectionID NEED TO CREATE NEW ")
                self.remoteFirebaseCollectionID = UUID().uuidString
            } else {
                self.initialSetup()
            }
        } receiveValue: { out in
            print("out \(out)")
        }.store(in: &store)
    }
    
    func initialSetup() {
        fetchNotes()
        subscribeRemoteNotesChanges()
        supbscribeICloudSyncIDChanges()
#if os(iOS)
        subscribeWatchConnectivityChanges()
#endif
    }
    
    func supbscribeICloudSyncIDChanges(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didChangeExternally(notification:)),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: nil)
    }
    
    @objc private func didChangeExternally(notification: Notification) {
        let reasonRaw = notification.userInfo?[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int ?? -1
        let keys = notification.userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] ?? []
        print("out \(reasonRaw), \(keys)")
    }
    
#if os(iOS)
    func subscribeWatchConnectivityChanges() {
        
        dataTransfer.emitter.subscribe { (event, externalNote) in
            if event == .add {
                print("index add")
                DispatchQueue.main.async {
                    let container = self.context.container
                    container.mainContext.insert(externalNote)
                    try? container.mainContext.save()
                    self.items.append(externalNote)
                    self.create(note: externalNote, targets: [.Local,.Remote])
                }
            }
            
            if event == .delete {
                if let index = self.items.firstIndex(where: { $0.id == externalNote.id }) {
                    print("index: \(index) delete")
                    DispatchQueue.main.async {
                        let context = self.context
                        let note = self.items[index]
                        context.delete(note)
                        try? context.save()
                        self.items.remove(at: index)
                        self.deleteItems(note: externalNote, targets: [.Local,.Remote])
                    }
                }
            }
            
            if event == .edit {
                if let index = self.items.firstIndex(where: { $0.id == externalNote.id }) {
                    print("index: \(index) edit")
                    DispatchQueue.main.async {
                        self.items[index].text = externalNote.text
                        self.items[index].noteType = externalNote.noteType
                        self.items[index].isCheked = externalNote.isCheked
                        try? self.context.save()
                        self.update(note: externalNote, targets: [.Local,.Remote])
                    }
                }
            }
        }.store(in: &store)
    }
#endif
    
    
    func fetchNotes() {
        
        // LOCAL
        do {
            self.items = try self.context.fetch(FetchDescriptor<Note>())
        } catch let err {
            print("ERROR:", err)
        }
        
        // REMOTE
        guard remoteFirebaseCollectionID != nil else {
            print("remoteFirebaseCollectionID is NIL!")
            return
        }
        
        remoteDB?.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            let _items : [Note] = querySnapshot?.documents.compactMap { doc in
                let data = try! doc.data(as : Note.self)
                
                return data
            } ?? []
            
            self.context.autosaveEnabled = false
            try? self.context.transaction {
                
                do {
                    try self.context.delete(model: Note.self)
                } catch {
                    print("Failed to clear all Country and City data.")
                }
                
                for obj in _items {
                    self.context.insert(obj)
                }
                do {
                    try self.context.save()
                } catch {
                    print("error to save context!")
                }
            }
            self.context.autosaveEnabled = true
            
            DispatchQueue.main.async {
                self.items = _items
            }
        }
    }
    
    // создание заметки на маке
    func createNote() {
        let id = UUID().uuidString
        let note = Note(id: id)
        context.insert(note)
        note.text = "New note"
        self.items.append(note)
        
        guard remoteFirebaseCollectionID != nil else {
            print("remoteFirebaseCollectionID is NIL!")
            return
        }
        
        if let note = note.toDictionary(),
           let remoteDB = remoteDB {
            let documentRef = remoteDB.document(id)
            documentRef.setData(note)
        }
    }
    
    
    func create(note: Note, targets: [DataBaseChangesTarget]) {
        
        if items.first(where: { $0.id == note.id }) != nil { return }
        
        guard let id = note.id else { return }
                
        targets.forEach { target in
            switch target {
                case .Remote:
                    if let note = note.toDictionary(),
                       let remoteDB = remoteDB {
                        let documentRef = remoteDB.document(id)
                        documentRef.setData(note)
                    }
                case .Local:
                    context.insert(note)
                    items.append(note)
                case .Watch:
#if os(iOS)
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
                    if let note = note.toDictionary(),
                       let remoteDB = remoteDB {
                        let documentRef = remoteDB.document(id)
                        documentRef.setData(note)
                    }
                case .Local:
                    if let exisedNoteIndex = items.firstIndex(where: { $0.id == note.id }) {
                        items[exisedNoteIndex] = note
                    }
                case .Watch:
#if os(iOS)
                    if let data = note.toDictionary() {
                        dataTransfer.sendData(event: .edit, item: data)
                    }
#endif
            }
        }
    }
    
    func subscribeRemoteNotesChanges() {
        listenerRegistration = remoteDB?.addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            if self.initialFetchFinished {
                if let diff = querySnapshot?.documentChanges {
                    let _changeitems : [Note] = diff.compactMap { doc in
                        let data = try! doc.document.data(as : Note.self)
                        switch doc.type {
                            case .added:
                                self.create(note: data, targets: [.Local,.Watch])
                            case .modified:
                                self.update(note: data, targets: [.Local,.Watch])
                            case .removed:
                                self.deleteItems(note: data, targets: [.Local,.Watch])
                        }
                        return data
                    }
                }
            }
            
            if self.initialFetchFinished == false {
                guard let allDocumetns = querySnapshot?.documents else {
                    return
                }
                let _items : [Note] = allDocumetns.compactMap { doc in
                    let data = try! doc.data(as : Note.self)
                    return data
                }
                
                self.context.autosaveEnabled = false
                try? self.context.transaction {
                    
                    do {
                        try self.context.delete(model: Note.self)
                    } catch {
                        print("Failed to clear all Country and City data.")
                    }
                    
                    for obj in _items {
                        self.context.insert(obj)
                    }
                    
                    do {
                        try self.context.save()
                    } catch {
                        // Handle error
                    }
                }
                self.context.autosaveEnabled = true
                
                DispatchQueue.main.async {
                    self.items = _items
                }
                self.initialFetchFinished = true
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
                    let documentRef = remoteDB?.document(id)
                    documentRef?.delete { error in
                        if let error = error {
                            print("Error removing document: \(error)")
                        } else {
                            print("Document successfully removed!")
                        }
                    }
                case .Local:
                    withAnimation {
                        self.context.delete(items[indexToDelete])
                        self.items.remove(at: indexToDelete)
                    }
                case .Watch:
#if os(iOS)
                    if let dic = note.toDictionary() {
                        dataTransfer.sendData(event: .delete, item: dic)
                    }
#endif
            }
        }
    }
    
    func delete(_ indexSet: IndexSet) {
        indexSet.forEach { i in
            self.deleteItems(note: items[i], targets: [.Local,.Remote,.Watch])
        }
    }
    
    deinit {
        listenerRegistration?.remove()
    }
}
