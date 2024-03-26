//
//  DataManager.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/05.
//

import CoreData

final class DataManager {
    static let shared = DataManager()
    
    let container: NSPersistentContainer
    let context: NSManagedObjectContext

    init() {
        self.container = NSPersistentContainer(name: "DataContainer")
        
        container.loadPersistentStores { _, error in
            if let error = error {
                ErrorType(error: error).publish()
            }
        }
        
        let context = container.viewContext
        context.name = "Main context"
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self.context = context
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                ErrorType(error: error).publish(file: #fileID, function: #function)
            }
        }
    }
}
