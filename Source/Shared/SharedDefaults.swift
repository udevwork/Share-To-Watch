//
//  SharedDefaults.swift
//  Watch App
//
//  Created by Denis Kotelnikov on 22.07.2024.
//

import Foundation

class SharedDefaults {
    
    static let UD = UserDefaults(suiteName: "group.01lab")
    
    static func saveDataToAppGroup(note: String) {
        UD?.set(note, forKey: "lastNote")
    }
    
    static func fetchLastNote() -> String {
        return UD?.string(forKey: "lastNote") ?? "Swipe note to attach it"
    }
}
