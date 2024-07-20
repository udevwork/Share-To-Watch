//
//  CheckboxView.swift
//  Watch App
//
//  Created by Denis Kotelnikov on 20.07.2024.
//

import Foundation
import SwiftUI

struct CheckBoxView: View {
    @State var isChecked: Bool = false
    var text: String

    var body: some View {
        HStack {
            Button(action: {
                isChecked.toggle()
            }) {
                Image(systemName: isChecked ? "checkmark.square" : "square")
                    .foregroundColor(isChecked ? .blue : .primary)
            }
     
            
            Text(text)
                .strikethrough(isChecked, color: .gray)
                .foregroundColor(isChecked ? .gray : .primary)
        }
       
    }
}
