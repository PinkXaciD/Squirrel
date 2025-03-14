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
    lazy private(set) var backgroundContext: NSManagedObjectContext = container.newBackgroundContext()

    init() {
        let container =  NSPersistentCloudKitContainer(name: "DataContainer")
        
        if let storeDescription = container.persistentStoreDescriptions.first {
            if !NSUbiquitousKeyValueStore.default.bool(forKey: UDKey.iCloudSync.rawValue) {
                storeDescription.configuration = "Default"
                storeDescription.cloudKitContainerOptions = nil
            }
            
            storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        }
        
        container.loadPersistentStores { _, error in
            if let error = error {
                ErrorType(error: error).publish()
            }
        }
        
#if DEBUG
//        do {
//            try container.initializeCloudKitSchema()
//        } catch {
//            print(error)
//        }
#endif
        
        let context = container.viewContext
        context.name = "Main context"
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
        
        try? context.setQueryGenerationFrom(.current)
        self.container = container
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
    
    func deleteSpending(with objectID: NSManagedObjectID) {
        guard let object = try? backgroundContext.existingObject(with: objectID) else {
            print("Failed")
            return
        }
        
        backgroundContext.delete(object)
        do {
            try backgroundContext.save()
        } catch {
            ErrorType(error: error).publish()
            backgroundContext.rollback()
        }
    }
}
