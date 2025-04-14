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
    var localHistoryToken: NSPersistentHistoryToken?
    
    init(isCloudSyncEnabled: Bool = true) {
        self.container = manager.container
        self.context = manager.context
        self.localHistoryToken = manager.container.persistentStoreCoordinator.currentPersistentHistoryToken(fromStores: container.persistentStoreCoordinator.persistentStores)
        
        fetchSpendings(updateWidgets: false)
        timerUpdate()
        
        if isCloudSyncEnabled {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(updateFromCloud),
                name: .NSPersistentStoreRemoteChange,
                object: context.persistentStoreCoordinator
            )
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contextDidSave),
            name: .NSManagedObjectContextDidSave,
            object: nil
        )
    }
    
    @objc
    private func updateFromCloud(_ notification: Notification) {
        let cloudHistoryToken = notification.userInfo?[NSPersistentHistoryTokenKey] as? NSPersistentHistoryToken
        
        if let cloudHistoryToken, cloudHistoryToken != localHistoryToken {
            self.fetchSpendings()
            self.localHistoryToken = cloudHistoryToken
        }
    }
    
    @objc
    private func contextDidSave(_ notification: Notification) {
//        print(#function)
        self.fetchSpendings()
    }
    
    /// An array containing all spendings from CoreData
    @available(*, deprecated, renamed: "FetchRequest", message: "")
    @Published
    var savedSpendings: [SpendingEntity] = []
    
    /// Data for spendings list in `StatsView`
//    @Published
//    var statsListData: StatsListData = StatsListData()
    
    /// Data for bar chart in `HomeView`
//    @Published
//    var barChartData: NewBarChartData = NewBarChartData()
    
    /// Data for pie chart in `StatsView`
    @Published
    var pieChartSpendings: [Date:[TSSpendingEntity]] = .init()
    
    /// All currencies used by user
    @Published
    var usedCurrencies: Set<Currency> = .init()
    
    /// An array containing not shadowed categories from CoreData
    @available(*, deprecated, renamed: "FetchRequest", message: "")
    @Published
    var savedCategories: [CategoryEntity] = []
    
    /// An array containing shadowed categories from CoreData
    @available(*, deprecated, renamed: "FetchRequest", message: "")
    @Published
    var shadowedCategories: [CategoryEntity] = []
    
    @Published
    var firstSpendingDate: Date?
    
    var lastFetchDate: Date? = nil
    
    var spendingsCount: Int = 0
    
    var waitingForRatesToBeAvailable: Bool = false
}

extension CoreDataModel {
    func exportCSV(
        items: [ExportCSVViewModel.Item],
        delimeter: ExportCSVViewModel.Delimeter,
        withReturns: Bool,
        timeZoneFormat: TimeZone.Format,
        predicate: NSPredicate? = nil
    ) throws -> URL? {
        try context.performAndWait {
            var result = "\(items.map({ $0.name }).reduce("", reduce))\n"
            
            func reduce(_ initialResult: String, _ nextPartialResult: String) -> String {
                if initialResult != "" {
                    return initialResult + "," + nextPartialResult
                }
                
                return nextPartialResult
            }
            
            func appendToResult(_ spending: SpendingEntity) {
                let quote = "\""
                let escapingQuote = "\"\""
                var spendingRow = String()
                
                for item in items {
                    switch item.id {
                    case "amount":
                        spendingRow += quote + (Locale.autoupdatingCurrent.currencyNarrowFormat(withReturns ? spending.amountWithReturns : spending.amount, currency: spending.wrappedCurrency) ?? spending.amount.formatted()) + quote
                    case "amountUSD":
                        spendingRow += quote + (Locale.autoupdatingCurrent.currencyNarrowFormat(withReturns ? spending.amountUSDWithReturns : spending.amountUSD, currency: "USD") ?? spending.amount.formatted()) + quote
                    case "currency":
                        spendingRow += spending.wrappedCurrency
                    case "date":
                        spendingRow += quote + spending.wrappedDate.formatted(date: .numeric, time: .shortened) + quote
                    case "timezone":
                        if let timeZoneIdentifier = spending.timeZoneIdentifier, let timeZone = TimeZone(identifier: timeZoneIdentifier) {
                            spendingRow += quote + timeZone.formatted(timeZoneFormat) + quote
                        } else {
                            spendingRow += ""
                        }
                    case "category":
                        spendingRow += quote + (spending.category?.name ?? "").replacingOccurrences(of: quote, with: escapingQuote) + quote
                    case "place":
                        spendingRow += quote + (spending.place?.replacingOccurrences(of: quote, with: escapingQuote) ?? "") + quote
                    case "comment":
                        spendingRow += quote + (spending.comment?.replacingOccurrences(of: "\n", with: "; ").replacingOccurrences(of: quote, with: escapingQuote) ?? "") + quote
                    default:
                        spendingRow += ""
                    }
                    
                    spendingRow += delimeter.rawValue
                }
                
                if !spendingRow.isEmpty {
                    spendingRow.removeLast()
                    result += spendingRow + "\n"
                }
            }
            
            // safeSpending.wrappedDate >= firstDate, safeSpending.wrappedDate < secondDate
            let fetchRequest = SpendingEntity.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \SpendingEntity.date, ascending: false)]
            if let predicate {
                fetchRequest.predicate = predicate
            }
            let fetchedSpendings = try? fetchRequest.execute()
            
            for spending in fetchedSpendings ?? [] {
                appendToResult(spending)
            }
            
            if let tempURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                var dateFormatter: DateFormatter {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm"
                    dateFormatter.timeZone = .autoupdatingCurrent
                    return dateFormatter
                }
                
                let pathURL = tempURL.appendingPathComponent("\(Bundle.main.displayName ?? "Squirrel")_Export_\(dateFormatter.string(from: Date())).csv")
                try result.write(to: pathURL, atomically: true, encoding: .utf8)
                HapticManager.shared.notification(.success)
                return pathURL
            }
            
            HapticManager.shared.notification(.error)
            return nil
        }
    }
    
    /// Exports all data in JSON file
    /// - Returns: URL to saved temporary file if save was successful
    /// - Important: This method is thread-safe
    func exportJSON() throws -> URL? {
        try context.performAndWait {
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
                encoder.dateEncodingStrategy = .iso8601
                
                let fetchRequest = CategoryEntity.fetchRequest()
                fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CategoryEntity.name, ascending: true)]
                
                let fetchedResults = try context.fetch(fetchRequest)
                
                let data = try encoder.encode(fetchedResults)
                
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
                    
                    let pathURL = tempURL.appendingPathComponent("\(Bundle.main.displayName ?? "Squirrel")_Backup_\(dateFormatter.string(from: Date()))", conformingTo: .json)
                    try jsonString.write(to: pathURL, atomically: true, encoding: .utf8)
                    HapticManager.shared.notification(.success)
                    return pathURL
                }
                HapticManager.shared.notification(.error)
                return nil
            } catch {
                throw error
            }
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
                    let spendings = try SpendingEntity.fetchRequest().execute()
                    let categories = try CategoryEntity.fetchRequest().execute()
                    var spendingIDs = Set<UUID>()
                    var categoryIDs = Set<UUID>()
                    
                    for spending in spendings {
                        if let id = spending.id {
                            spendingIDs.insert(id)
                        }
                    }
                    
                    for category in categories {
                        if let id = category.id {
                            categoryIDs.insert(id)
                        }
                    }
                    
                    let tempData = try decoder.decode([CategoryEntity].self, from: jsonData)
                    
//                    let existingCategoryIds = Set((savedCategories + shadowedCategories).map { $0.id })
//                    let existingSpendingsIds = Set(savedSpendings.map { $0.id })
                    
                    for category in tempData {
                        if let spendings = category.spendings?.allObjects as? [SpendingEntity], !spendings.isEmpty {
                            for spending in spendings {
                                if !spendingIDs.contains(spending.wrappedId) {
                                    if categoryIDs.contains(category.id ?? .init()) {
                                        importSpending(spending)
                                    }
                                    
                                    importedCount += 1
                                } else {
                                    privateContext.delete(spending)
                                }
                            }
                        }
                        
                        if categoryIDs.contains(category.id ?? UUID()) {
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
        
        let timer = Timer(fire: fireTime, interval: .day, repeats: true) { [weak self] timer in
            self?.fetchSpendings()
        }
        
        RunLoop.main.add(timer, forMode: .default)
    }
}
