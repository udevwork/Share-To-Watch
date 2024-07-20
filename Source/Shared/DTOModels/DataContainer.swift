//
//  DataContainer.swift
//  Watch App
//
//  Created by Denis Kotelnikov on 20.07.2024.
//

import Foundation
import SwiftData

@MainActor
class DataContainer {
    static var context = try! ModelContainer(for: Note.self, configurations: ModelConfiguration(groupContainer: .identifier("group.01lab"))).mainContext
}
