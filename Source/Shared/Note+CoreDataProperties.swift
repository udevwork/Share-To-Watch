//
//  Note+CoreDataProperties.swift
//  iOS App
//
//  Created by Denis Kotelnikov on 20.07.2024.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var noteType: String?
    @NSManaged public var text: String?
    @NSManaged public var creationDate: Date?
    @NSManaged public var color: String?
    @NSManaged public var noteID: String?

}

extension Note : Identifiable {

}
