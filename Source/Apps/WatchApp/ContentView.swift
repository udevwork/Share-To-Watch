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
    
    @Published var notes: [SimpleNote] = []
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // Попытка извлечь данные из последнего контекста приложения
    func fetchNotes(_ session: WCSession) {
        let receivedApplicationContext = session.receivedApplicationContext
        
        var _temp: [SimpleNote] = []
        if let receivedNotes = receivedApplicationContext["notes"] as? [[String : Any]] {
            _temp = Array.from(dictionaryArray: receivedNotes)
            
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
    

}


struct ContentView: View {
    @StateObject var model = ContentViewModel()
    
    var body: some View {
        NavigationStack {
            List {
           
                Section {
                    ForEach(model.notes, id: \.id) { note in
                        VStack {
                            Text(note.text ?? "-")
                            HStack {
                                Text("type: ")
                                Text(note.noteType ?? "-")
                            }.font(.footnote)
                        }
                    }
                } header: {
                    Text("v0.11")
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
