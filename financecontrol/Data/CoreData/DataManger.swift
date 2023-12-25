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
        self.context = container.viewContext
    }
    
    func save() {
        do {
            try context.save()
        } catch {
            ErrorType(error: error).publish()
        }
    }
}
