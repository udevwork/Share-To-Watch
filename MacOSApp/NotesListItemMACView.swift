//
//  NotesListItemView.swift
//  MacOSApp
//
//  Created by Denis Kotelnikov on 27.07.2024.
//

import SwiftUI
import SwiftData
import Combine

struct NotesListItemMACView: View {
    
    @State var hover: Bool = false
    @State var text: String
    @FocusState var isFocused: Bool
    @Binding var note: Note
    
    var onDelete: ()->()
    var onEdit: ()->()
    
    init(
        note: Binding<Note>,
        onDelete: @escaping ()->(),
        onEdit: @escaping ()->()
    ) {
        self._note = note
        self.text = note.wrappedValue.text ?? ""
        
        self.onDelete = onDelete
        self.onEdit = onEdit
    }
    
    var body: some View {
        HStack() {
            
            if note.noteType == .checkbox {
                Button(action: {
                    note.isCheked.toggle()
                    onEdit()
                }) {
                    Image(systemName: note.isCheked ? "checkmark.square.fill" : "square")
                        .imageScale(.large)
                        .multilineTextAlignment(.center)
                }.buttonStyle(PlainButtonStyle())
            }
            
            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .scrollDisabled(true)
                .font(.system(size: 16))
                .focused($isFocused)
                .onChange(of: text) {
                    note.text = text
                }
                .onChange(of: isFocused) { oldValue, newValue in
                    if newValue == false {
                        onEdit()
                    }
                }
             
            
            Spacer()
            
            Menu("Menu") {
                Button {
                    if note.noteType == .checkbox {
                        note.noteType = .plain
                    }
                    if note.noteType != .checkbox {
                        note.noteType = .checkbox
                    }
                    onEdit()
                } label: {
                    if note.noteType == .checkbox {
                        Label("Unmark as checkbox", systemImage: "checkmark.square.fill")
                            .foregroundStyle(.white)
                    }
                    if note.noteType != .checkbox {
                        Label("Mark as checkbox", systemImage: "checkmark.square.fill")
                            .foregroundStyle(.white)
                    }
                  
                }
                Button {
                    
                } label: {
                    Label("Attach to widget", systemImage: "paperclip.circle.fill")
                        .foregroundStyle(.white)
                }
                Button {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash.circle.fill")
                        .foregroundStyle(.red)
                }
            }
            .menuStyle(BorderlessButtonMenuStyle())
            .fixedSize()
            .opacity(hover ? 1 : 0)
        }
        .multilineTextAlignment(.leading)
        .padding()
        .background(content: {
            if hover {
                Color.white.opacity(0.05)
            } else {
                Color.white.opacity(0.02)
            }
        })
        .clipShape(RoundedRectangle(cornerRadius: 10.0) )
        .onHover { hover in
            withAnimation(.easeInOut(duration: 0.2)) {
                self.hover = hover
            }
        }
    }
}

