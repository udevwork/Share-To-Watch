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
    
    @FocusState
    var focus: Bool
    
    
    var onCreate : (Note)->()
    var onEdit : (Note)->()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit note")) {
                    TextEditor(text: $text).frame(minHeight: 200)
                        .focused($focus)
                }
            }
            .toolbar(content: {
                Toggle(isOn: $checkbox, label: { Text("Checkbox") })
                cancelButton
                saveButton
            })
            .onAppear {
                focus = true
                if let note = note {
                    text = note.text ?? ""
                    checkbox = note.noteType == .checkbox ? true : false
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
          
            if let note = note {
                note.text = text
                note.noteType = checkbox ? .checkbox : .plain
                onEdit(note)
            } else {
                let context = DataContainer.context
                let note = Note(id: UUID().uuidString)
                note.text = text
                note.noteType = checkbox ? .checkbox : .plain
                onCreate(note)
            }

            presentationMode.wrappedValue.dismiss()
        }
    }
}

