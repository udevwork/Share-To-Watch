//
//  NoteEdit.swift
//  ShareToWatch
//
//  Created by Denis Kotelnikov on 20.07.2024.
//

import SwiftUI

import SwiftUI
import CoreData
import SwiftData

struct NoteEditorView: View {
    
    @State 
    private var text: String = ""
    
    @State
    private var content: String = ""
    
    @Environment(\.presentationMode) 
    var presentationMode
    
    @Binding 
    var note: Note?
        
    @State
    var checkbox: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextEditor(text: $text)
                    Toggle(isOn: $checkbox, label: {Text("checkbox")})
                }
            }
            .toolbar(content: {
                cancelButton
                saveButton
            })
            .onAppear {
                if let note = note {
                    text = note.text ?? ""
                }
            }
        }
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    @MainActor private var saveButton: some View {
        Button("Save") {
            let container = try! ModelContainer(for: Note.self, configurations: ModelConfiguration())
            if let note = note {
                note.text = text
                note.noteType =  self.checkbox ? "checkbox" : ""
            } else {
                let note = Note(text: text)
                note.noteType =  self.checkbox ? "checkbox" : ""
                container.mainContext.insert(note)
            }
            
            try! container.mainContext.save()
            presentationMode.wrappedValue.dismiss()
        }
    }
}

