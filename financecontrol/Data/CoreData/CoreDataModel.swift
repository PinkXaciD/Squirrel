//
//  CoreDataModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/12/25.
//

import CoreData

/// Main class for interacting with CoreData within the app
///
/// It contains data for all charts, lists and views and serves as source of truth for them
final class CoreDataModel: ObservableObject {
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    let manager = DataManager.shared
    
    init() {
        self.container = manager.container
        self.context = manager.context
        fetchSpendings(updateWidgets: false)
        fetchCategories()
        timerUpdate()
    }
    
    /// An array containing all spendings from CoreData
    @Published
    var savedSpendings: [SpendingEntity] = []
    
    /// Data for spendings list in `StatsView`
    @Published
    var statsListData: StatsListData = StatsListData()
    
    /// Data for bar chart in `HomeView`
    @Published
    var barChartData: NewBarChartData = NewBarChartData()
    
    /// Data for pie chart in `StatsView`
    @Published
    var pieChartSpendings: [Date:[TSSpendingEntity]] = .init()
    
    /// All currencies used by user
    @Published
    var usedCurrencies: Set<Currency> = .init()
    
    /// An array containing not shadowed categories from CoreData
    @Published
    var savedCategories: [CategoryEntity] = []
    
    /// An array containing shadowed categories from CoreData
    @Published
    var shadowedCategories: [CategoryEntity] = []
    
    @available(*, deprecated, renamed: "UserDefaults.standart.getCurrencies()", message: "")
    @Published
    var savedCurrencies: [CurrencyEntity] = []
    
    var waitingForRatesToBeAvailable: Bool = false
}

extension CoreDataModel {
    /// Exports all data in JSON file
    /// - Returns: URL to saved temporary file if save was successful
    /// - Important: This method is not thread-safe
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
                
                let pathURL = tempURL.appendingPathComponent("\(Bundle.main.displayName ?? "Squirrel")_Export_\(dateFormatter.string(from: Date()))", conformingTo: .json)
                try jsonString.write(to: pathURL, atomically: true, encoding: .utf8)
                
                return pathURL
            }
            
            return nil
        } catch {
            throw error
        }
    }
    
    /// Imports data from JSON file
    /// - Parameter url: Path to file
    /// - Returns: Count of imported spendings if succeeds, otherwise `nil`
    func importJSON(_ url: URL) -> Int? {
        var importedCount = 0
        
        do {
            if url.startAccessingSecurityScopedResource() {
                let jsonData = try Data(contentsOf: url)
                
                url.stopAccessingSecurityScopedResource()
                
                let privateContext = manager.container.newBackgroundContext()
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                decoder.userInfo[.moc] = privateContext
                
                try privateContext.performAndWait {
                    let tempData = try decoder.decode([CategoryEntity].self, from: jsonData)
                    
                    let existingCategoryIds = Set((savedCategories + shadowedCategories).map { $0.id })
                    let existingSpendingsIds = Set(savedSpendings.map { $0.id })
                    
                    for category in tempData {
                        if let spendings = category.spendings?.allObjects as? [SpendingEntity], !spendings.isEmpty {
                            for spending in spendings {
                                if !existingSpendingsIds.contains(spending.id) {
                                    if existingCategoryIds.contains(category.id) {
                                        importSpending(spending)
                                    }
                                    
                                    importedCount += 1
                                } else {
                                    privateContext.delete(spending)
                                }
                            }
                        }
                        
                        if existingCategoryIds.contains(category.id) {
                            privateContext.delete(category)
                        }
                    }
                    
                    try privateContext.save()
                    privateContext.reset()
                }
                
                manager.save()
                
                fetchCategories()
                fetchSpendings()
                
                return importedCount
            } else {
                return nil
            }
        } catch {
            url.stopAccessingSecurityScopedResource()
            context.rollback()
            ErrorType(error: error).publish()
            return nil
        }
    }
    
    /// Timer that will update all data in app when date changes
    func timerUpdate() {
        let fireTime = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())) ?? .distantFuture
        let timer = Timer(fire: fireTime, interval: 0, repeats: false) { [weak self] timer in
            self?.fetchSpendings()
        }
        
        RunLoop.main.add(timer, forMode: .default)
    }
}
