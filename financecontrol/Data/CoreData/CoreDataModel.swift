//
//  CoreDataModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/12/25.
//

import CoreData

final class CoreDataModel: ObservableObject {
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    let manager = DataManager.shared
    
    init() {
        self.container = manager.container
        self.context = manager.context
        fetchSpendings()
        fetchCategories()
        fetchCurrencies()
    }
    
    @Published
    var savedSpendings: [SpendingEntity] = []
    @Published
    var savedCategories: [CategoryEntity] = []
    @Published
    var shadowedCategories: [CategoryEntity] = []
    @Published
    var savedCurrencies: [CurrencyEntity] = []
    @Published
    var updateCharts: Bool = false
}

extension CoreDataModel {
    func exportJSON() throws -> URL? {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
            encoder.dateEncodingStrategy = .iso8601
            
            let data = try encoder.encode(savedCategories)
            
            if let jsonString = String(
                data: data,
                encoding: .utf8
            ), let tempURL = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first {
                var dateFormatter: DateFormatter {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm"
                    dateFormatter.timeZone = .autoupdatingCurrent
                    return dateFormatter
                }
                
                let pathURL = tempURL.appendingPathComponent("SquirrelExport_\(dateFormatter.string(from: Date()))", conformingTo: .json)
                try jsonString.write(to: pathURL, atomically: true, encoding: .utf8)
                
                return pathURL
            }
            
            return nil
        } catch {
            throw error
        }
    }
    
    func importJSON(_ url: URL) -> Int? {
        var importedCount = 0
        
        do {
            if url.startAccessingSecurityScopedResource() {
                let jsonData = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                decoder.userInfo[.moc] = context
                
                url.stopAccessingSecurityScopedResource()
                
                let tempData = try decoder.decode([CategoryEntity].self, from: jsonData)
                
                let existingCategoryIds = savedCategories.map { $0.id } + shadowedCategories.map { $0.id }
                let existingSpendingsIds = savedSpendings.map { $0.id }
                
                for category in tempData {
                    if let spendings = category.spendings?.allObjects as? [SpendingEntity], !spendings.isEmpty {
                        for spending in spendings {
                            if !existingSpendingsIds.contains(spending.id) {
                                if let id = spending.category?.id, let category = findCategory(id) {
                                    addToCategory(spending, category)
                                    importedCount += 1
                                }
                            }
                        }
                    }
                    
                    if existingCategoryIds.contains(category.id) {
                        context.delete(category)
                    }
                }

                manager.save()
                
                fetchCategories()
                fetchSpendings()
                
                updateCharts = true
                
                return importedCount
            } else {
                return nil
            }
        } catch {
            context.rollback()
            ErrorType(error: error).publish()
            return nil
        }
    }
}
