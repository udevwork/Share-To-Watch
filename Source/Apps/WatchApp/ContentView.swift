//
//  ContentView.swift
//  СtWWatchExt Watch App
//
//  Created by Denis Kotelnikov on 16.07.2024.
//

import SwiftUI
import WatchConnectivity
import SwiftData

class ContentViewModel: NSObject, ObservableObject {
    var dataTransfer = DataTransfer()
    @Published var notes: [Note] = []
    var session: WCSession? = nil
    override init() {
        super.init()
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
    
    // Попытка извлечь данные из последнего контекста приложения
    func fetchNotes(_ session: WCSession) {
//        let receivedApplicationContext = session.receivedApplicationContext
//        
//        var _temp: [Note] = []
//        if let receivedNotes = receivedApplicationContext["notes"] as? [[String : Any]] {
//            _temp = [Note].fromDictionaryArray(receivedNotes) ?? []
//        }
//        
//        DispatchQueue.main.async {
//            self.notes = _temp
//        }
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
        fetchNotes(session)
        
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        fetchNotes(session)
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
    
    // TEST
    @MainActor func createNewNote(text: String) {
        let note = Note(id: UUID().uuidString, text: "fuck", noteType: "you")
        let container = DataContainer.context.container
        container.mainContext.insert(note)
        try! container.mainContext.save()
        self.notes.append(note)
    }

}


struct ContentView: View {
    
    @StateObject var model = ContentViewModel()
    
    @State var counter = 0
    
    var body: some View {
        NavigationStack {
            List {
               
                Button {
                    model.dataTransfer.send(text: "TEST")
                } label: {
                    Text("send test msg")
                }
                               
                Button {
                    model.dataTransfer.test()
                } label: {
                    Text("print userinfo outstand")
                }
                
                Button {
                    model.clearDatabase()
                } label: {
                    Text("clearDatabase")
                }

                Button {
                    model.fetchNotes()
                } label: {
                    Text("fetchNotes")
                }   
                
                Button {
                    model.createNewNote(text: "test")
                } label: {
                    Text("createNewNote")
                }   
                
                Button {
                    let _d = model.notes.first!.toDictionary()!
                    model.dataTransfer.sendData(event: .add, item: _d)
                    counter += 1
                } label: {
                    Text("sand user info \(counter)")
                }

                Section {
                    ForEach(model.notes, id: \.id) { note in
                        if note.noteType == "checkbox" {
                            CheckBoxView(note: note) { isChecked in
                                
                                try! DataContainer.context.save()
                                if let data = note.toDictionary() {
                                    model.dataTransfer.sendData(event: .edit, item: data)
                                }
                                
                            }
                        } else {
                            Text(note.text ?? "-")
                        }
                    }
                } header: {
                    Text("v0.15")
                } footer: {
                    Text("Edit notes in ios app")
                }
                
     
            }.navigationTitle("Notes")
                .onAppear {
                    model.fetchNotes()
                }
            
        }
    }
}

#Preview {
    ContentView()
}
