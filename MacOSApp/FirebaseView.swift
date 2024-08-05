//
//  FirebaseView.swift
//  MacOSApp
//
//  Created by Denis Kotelnikov on 27.07.2024.
//

import SwiftUI

struct FirebaseView: View {
    @StateObject var model = FirebaseNotesController()
    
    var body: some View {
        if let id = model.remoteFirebaseCollectionID {
            List {
               
                HStack {
                    Button {
                        model.createNote()
                    } label: {
                        Text("CREATE NOTE")
                    }
                    
                    Button {
                        model.fetchNotes()
                    } label: {
                        Text("Fetch")
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
        } else {
            VStack(alignment:.center , spacing: 20) {
                HStack(spacing: 20) {
                    Text("Waiting for SyncID")
                    ProgressView().controlSize(.small)
                }.padding(20)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                Text("To get your SyncID, you need to download the app to your iPhone. At the first launch, you will be assigned an ID automatically and the application on macOS will sync automatically").frame(width: 300)
                    .font(.footnote)
                    .foregroundStyle(Color.gray)
                    .multilineTextAlignment(.center)
            }
        }

    }
}
