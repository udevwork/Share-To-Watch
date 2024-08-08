import Foundation
import SwiftUI

struct NoteEditorMACView: View {
    
    let item: Note
    
    @State private var text: String
    
    init(item: Note) {
        self.item = item
        self.text = item.text ?? "гсл"
    }
    
    var body: some View {
        TextEditor(text: $text)
            .font(.system(size: 20))
            .background(.clear)
            .padding()
    }
}
