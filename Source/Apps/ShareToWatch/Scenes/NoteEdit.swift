import SwiftUI
import SwiftData

struct NoteEditorView: View {
    
    @Environment(\.presentationMode)
    var presentationMode
    
    @State
    private var text: String = ""
    
    @Binding 
    var note: Note?
        
    @State
    var checkbox: Bool = false
  
    
    var onCreate : (Note)->()
    var onEdit : (Note)->()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextEditor(text: $text)
                    Toggle(isOn: $checkbox, label: { Text("checkbox") })
                }
            }
            .toolbar(content: {
                cancelButton
                saveButton
            })
            .onAppear {
                if let note = note {
                    text = note.text ?? ""
                    checkbox = note.noteType == "checkbox" ? true : false
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
            let container = DataContainer.context.container
            if let note = note {
                
                note.text = text
                note.noteType = checkbox ? "checkbox" : ""
                
                onEdit(note)
            } else {
                
                let note = Note(id: UUID().uuidString)
                note.text = text
                note.noteType = checkbox ? "checkbox" : ""
                
                container.mainContext.insert(note)
                onCreate(note)
            }
            
            try! container.mainContext.save()
            presentationMode.wrappedValue.dismiss()
        }
    }
}

