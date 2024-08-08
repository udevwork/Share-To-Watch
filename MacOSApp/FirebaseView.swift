import SwiftUI

struct FirebaseView: View {
    @StateObject var model = FirebaseNotesController()
    
    var body: some View {
        List {
            
            HStack {
                Button {
                    model.createNote()
                } label: {
                    Text("Create")
                }
                
                Button {
                    model.fetchNotes()
                } label: {
                    Text("Update")
                }
            }
            
            ForEach($model.items, id: \.viewID) { item in
                NotesListItemMACView(
                    note: item,
                    onDelete: { model.deleteItems(note: item.wrappedValue, targets: [.Local,.Remote, .Watch]) },
                    onEdit: {
                        model.update(note: item.wrappedValue, targets: [.Local,.Remote, .Watch])
                    }
                )
                .listRowSeparator(.hidden)
            }
        }
    }
}
