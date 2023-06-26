//
//  DataController.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/05.
//

import CoreData

final class DataManager {
    
    static let instance = DataManager()
    
    let container: NSPersistentContainer
    let context: NSManagedObjectContext

    init() {
        self.container = NSPersistentContainer(name: "DataContainer")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading persistance stores: \(error.localizedDescription)")
            }
        }
        self.context = container.viewContext
    }
    
    func save() {
        
        do {
            try context.save()
        } catch let error {
            print("Error saving context: \(error.localizedDescription)")
        }
    }
}

final class CoreDataViewModel: ObservableObject {
    
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    let manager = DataManager.instance
    
    init() {
        self.container = manager.container
        self.context = manager.context
        fetchSpendings()
        fetchCategories()
        fetchCurrencies()
    }
    
    @Published var savedSpendings: [SpendingEntity] = []
    @Published var savedCategories: [CategoryEntity] = []
    @Published var shadowedCategories: [CategoryEntity] = []
    @Published var savedCurrencies: [CurrencyEntity] = []
}
