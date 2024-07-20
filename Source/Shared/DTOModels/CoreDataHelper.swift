//
//  CoreDataHelper.swift
//  ShareToWatch
//
//  Created by Denis Kotelnikov on 18.07.2024.
//

import Foundation
import CoreData

class CoreData {
    static let shared = CoreData()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Notes")
        let storeURL = URL.storeURL(for: "group.01lab", databaseName: "Notes")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        return container
    }()
    
    func getStoredDataFromCoreData() {
        let managedContext = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        do {
            let result = try managedContext.fetch(fetchRequest)
            //Iterate between all the results saved into EntityName
            for _ in result {
                // Do something with the stored data
            }
        } catch let error as NSError {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

public extension URL {
    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }
        
        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}
