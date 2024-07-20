//
//  NoteEdit.swift
//  ShareToWatch
//
//  Created by Denis Kotelnikov on 20.07.2024.
//

import SwiftUI

import SwiftUI
import CoreData

struct NoteEditorView: View {
    
    @Environment(\.managedObjectContext)
    private var viewContext
    
    @State 
    private var text: String = ""
    
    @State
    private var content: String = ""
    
    @Environment(\.presentationMode) 
    var presentationMode
    
    @Binding 
    var note: Note?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextEditor(text: $text)
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
    
    private var saveButton: some View {
        Button("Save") {
            if let note = note {
                note.text = text
            } else {
                let newNote = Note(context: viewContext)
                newNote.text = text
            }
            do {
                try viewContext.save()
            } catch {
                // Handle the Core Data error
                print("Failed to save note: \(error.localizedDescription)")
            }
            presentationMode.wrappedValue.dismiss()
        }
    }
}

