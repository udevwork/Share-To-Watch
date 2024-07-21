//
//  CheckboxView.swift
//  Watch App
//
//  Created by Denis Kotelnikov on 20.07.2024.
//

import Foundation
import SwiftUI

struct CheckBoxView: View {
        
    var note: Note
    
    var onChecked: (Bool)->()
    
    var body: some View {
        HStack {
            Button(action: {
                note.isCheked.toggle()
                onChecked(note.isCheked)
            }) {
                Image(systemName: note.isCheked ? "checkmark.square" : "square")
                    .foregroundColor(note.isCheked ? .blue : .primary)
            }
     
            
            Text(note.text ?? "-")
                .strikethrough(note.isCheked, color: .gray)
                .foregroundColor(note.isCheked ? .gray : .primary)
        }
       
    }
}
