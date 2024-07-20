//
//  ContentView.swift
//  СtWWatchExt Watch App
//
//  Created by Denis Kotelnikov on 16.07.2024.
//

import SwiftUI
import WatchConnectivity
import CoreData

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
    
    // Попытка извлечь данные из последнего контекста приложения
    func fetchNotes(_ session: WCSession) {
        let receivedApplicationContext = session.receivedApplicationContext
        
        var _temp: [Note] = []
        if let receivedNotes = receivedApplicationContext["notes"] as? [[String : Any]] {
            _temp = [Note].fromDictionaryArray(receivedNotes) ?? []
        }
        
        DispatchQueue.main.async {
            self.notes = _temp
        }
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
    
    func synchronize() {

        if let session = session {
            do {
                let notesData = notes.toDictionaryArray()
                try session.updateApplicationContext(["notes": "иди в хуй"])
            } catch {
                print("Ошибка при отправке данных на Apple Watch: \(error)")
            }
        }
    }

}


struct ContentView: View {
    @StateObject var model = ContentViewModel()
    
    var body: some View {
        NavigationStack {
            List {
               
                Button {
                    model.synchronize()
                } label: {
                    Text("synchronize")
                }

                
                Section {
                    ForEach(model.notes, id: \.id) { note in
                        if note.noteType == "checkbox" {
                            CheckBoxView(text: note.text ?? "")
                        } else {
                            Text(note.text ?? "-")
                        }
                    }
                } header: {
                    Text("v0.14")
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
