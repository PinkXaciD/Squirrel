//
//  CategoriesModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/07.
//

import CoreData
#if DEBUG
import OSLog
#endif

extension CoreDataModel {
    
    func fetchCategories() {
        
        let request = CategoryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        request.predicate = NSPredicate(format: "isShadowed == false")
        
        let requestForShadowed = CategoryEntity.fetchRequest()
        requestForShadowed.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        requestForShadowed.predicate = NSPredicate(format: "isShadowed == true")
        
        do {
            savedCategories = try context.fetch(request)
            shadowedCategories = try context.fetch(requestForShadowed)
        } catch {
            ErrorType(error: error).publish()
        }
    }
    
    func findCategory(_ id: UUID, in context: NSManagedObjectContext = DataManager.shared.context) -> CategoryEntity? {
        context.performAndWait {
            let request = CategoryEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            do {
                return try context.fetch(request).first
            } catch {
                #if DEBUG
                let logger = Logger(subsystem: Vars.appIdentifier, category: "CoreDataModel")
                logger.error("Error finding category: \(error)")
                #endif
                return nil
            }
        }
    }
    
    func addCategory(name: String, color: String) -> UUID {
        
        if let description = NSEntityDescription.entity(forEntityName: "CategoryEntity", in: context) {
            
            let newCategory = CategoryEntity(entity: description, insertInto: context)
            
            let id = UUID()
            newCategory.id = id
            newCategory.name = name
            newCategory.color = color
            newCategory.isShadowed = false
            
            manager.save()
            fetchCategories()
            
            return id
        }
        
        return UUID()
    }
    
    func addToCategory(_ spending: SpendingEntity, _ category: CategoryEntity) {
        
        category.addToSpendings(spending)
    }
    
    func editCategory(_ category: CategoryEntity, name: String, color: String) {
        
        category.name = name
        category.color = color
        manager.save()
        fetchCategories()
        fetchSpendings()
    }
    
    func changeShadowStateOfCategory(_ category: CategoryEntity) {
        
        category.isShadowed.toggle()
        category.isFavorite = false
        manager.save()
        fetchCategories()
    }
    
    func changeFavoriteStateOfCategory(_ category: CategoryEntity) {
        
        category.isFavorite.toggle()
        manager.save()
        fetchCategories()
    }
    
    func deleteCategory(_ category: CategoryEntity) {
        
        context.delete(category)
        manager.save()
        fetchCategories()
        fetchSpendings()
    }
}
