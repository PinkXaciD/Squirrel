//
//  SpendingsModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/07.
//

import CoreData
#if DEBUG
import OSLog
#endif

extension CoreDataModel {
    /// Fetches all spendings from CoreData and updates all related values
    ///
    /// This method is thread-safe and works on main thread asynchronously
    func fetchSpendings(updateWidgets: Bool = true) {        
//        print("\(#function) called")
        context.perform { [weak self] in
            guard let self else { return }
            
            let request = SpendingEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
            var spendings = [SpendingEntity]()
            var currencies = Set<Currency>()
            let ratesFetchQueueSet = Set(UserDefaults.standard.getFetchQueue())
            var ratesFetchSpendings = [SpendingEntity]()
            
            do {
                spendings = try self.context.fetch(request)
                self.firstSpendingDate = spendings.last?.date ?? Date()
            } catch {
                ErrorType(error: error).publish(file: #file, function: #function)
            }
            
            var pieChartData: [Date:[TSSpendingEntity]] = {
                var result: [Date:[TSSpendingEntity]] = .init()
                let lastDate = spendings.last?.wrappedDate.getFirstDayOfMonth() ?? Date().getFirstDayOfMonth()
                let interval = Calendar.current.dateComponents([.month], from: lastDate, to: Date()).month ?? 1
                
                for index in 0...interval {
                    result.updateValue([], forKey: Date().getFirstDayOfMonth(-index))
                }
                
                return result
            }()
            
            let formatWithoutTimezones = UserDefaults.standard.bool(forKey: UDKey.formatWithoutTimeZones.rawValue)
            
            // MARK: Fetch for loop
            for spending in spendings {
                let safeSpending = spending.safeObject()
                let startOfDay = formatWithoutTimezones ? Calendar.current.startOfDay(for: safeSpending.wrappedDate) : Calendar.current.startOfDay(for: safeSpending.dateAdjustedToTimeZone)
                
                if !currencies.contains(Currency(code: safeSpending.wrappedCurrency)) {
                    currencies.insert(Currency(code: safeSpending.wrappedCurrency))
                }
                
                // Pie chart data
                pieChartData[startOfDay.getFirstDayOfMonth()]?.append(safeSpending)
                
                // Rates refetch
                if ratesFetchQueueSet.contains(safeSpending.wrappedId) {
                    ratesFetchSpendings.append(spending)
                }
            } // End of for loop
            
            self.usedCurrencies = currencies
            self.pieChartSpendings = pieChartData
            self.spendingsCount = spendings.count
            NotificationCenter.default.post(name: .UpdatePieChart, object: nil)
            lastFetchDate = Date()
            
            if !ratesFetchSpendings.isEmpty {
                updateRatesFromQueue(ratesFetchSpendings)
            }
            
            if updateWidgets {
                passSpendingsToSumWidget()
            }
        }
    }
    
    func getSpendings(predicate: NSPredicate? = nil, in context: NSManagedObjectContext? = nil) throws -> [SpendingEntity] {
        let request = SpendingEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        let localContext = context ?? self.context
        if let predicate = predicate {
            request.predicate = predicate
        }
        
        do {
            return try localContext.performAndWait {
                try localContext.fetch(request)
            }
        } catch {
            throw error
        }
    }
    
    func passSpendingsToSumWidget() {
        context.perform {
            #if DEBUG
            Logger(subsystem: Vars.appIdentifier, category: "\(#fileID)").debug("\(#function) called in \(#fileID)")
            #endif
            
            var todaySum: Double = 0
            var result = [String:Double]()
            
            let defaultCurrency = UserDefaults.defaultCurrency()
            let defaultRate = UserDefaults.standard.getUnwrapedRates()[defaultCurrency] ?? 1
            let weekAgo = Date().weekAgoUnwrapped
            let startOfToday = Calendar.autoupdatingCurrent.startOfDay(for: Date())
            
            for offset in 0..<7 {
                guard let key = Calendar.autoupdatingCurrent.date(byAdding: .day, value: -offset, to: startOfToday)?.formatted(.iso8601) else {
                    continue
                }
                
                result[key] = 0
            }
            
            let fetchRequest = SpendingEntity.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \SpendingEntity.date, ascending: false)]
            fetchRequest.predicate = NSPredicate(format: "date > %@", weekAgo as CVarArg)
            
            let fetchedSpendings = {
                do {
                    return try fetchRequest.execute()
                } catch {
                    return []
                }
            }()
            
            for spending in fetchedSpendings {
                let spendingAmount: Double = {
                    if spending.wrappedCurrency == defaultCurrency {
                        return spending.amountWithReturns
                    } else {
                        return spending.amountUSDWithReturns * defaultRate
                    }
                }()
                
                let spendingStartOfDayFormatted = spending.startOfDay.formatted(.iso8601)
                
                if spending.startOfDay == startOfToday {
                    todaySum += spendingAmount
                }
                
                let existingValue = result[spendingStartOfDayFormatted] ?? 0
                result.updateValue(existingValue + spendingAmount, forKey: spendingStartOfDayFormatted)
            }
            
            WidgetsManager.shared.updateSpendingsWidgets(data: result, amount: todaySum)
        }
    }
    
    /// Adds a new spending and updates all related data
    /// - Parameters:
    ///   - spending: Object with values to be inserted into new spending
    ///   - playHaptic: Indicates whether to play haptic on success
    ///
    /// This method is thread-safe
    func addSpending(spending: SpendingEntityLocal, playHaptic: Bool = true, addToFetchQueue: Bool = false) {
        context.performAndWait {
            guard let description = NSEntityDescription.entity(forEntityName: "SpendingEntity", in: context) else {
                ErrorType(CoreDataError.failedToGetEntityDescription).publish()
                return
            }
            
            guard let category = findCategory(spending.categoryId, in: context) else {
                ErrorType(CoreDataError.failedToFindCategory).publish()
                return
            }
            
            let newSpending = SpendingEntity(entity: description, insertInto: context)
            
            let spendingID = UUID()
            newSpending.id = spendingID
            newSpending.amount = spending.amount
            newSpending.amountUSD = spending.amountUSD
            newSpending.currency = spending.currency
            newSpending.date = spending.date
            newSpending.timeZoneIdentifier = TimeZone.autoupdatingCurrent.identifier
            newSpending.place = spending.place
            newSpending.comment = spending.comment
            
            addToCategory(newSpending, category)
            try? context.save()
            fetchSpendings()
            
            if addToFetchQueue {
                UserDefaults.standard.addToFetchQueue(spendingID)
                waitForRatesToBecomeAvailable()
            }
            
            if playHaptic {
                HapticManager.shared.notification(.success)
            }
        }
    }
    
#if DEBUG
    func addTestSpending() {
        context.perform { [weak context] in
            let fetchRequest = CategoryEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "isShadowed == false")
            let result = try? context?.fetch(fetchRequest)
            
            guard let result, let randomCategory = result.randomElement()?.id else {
                return
            }
            
            self.addSpending(
                spending: .init(
                    amountUSD: 1,
                    amount: 1,
                    amountWithReturns: 1,
                    amountUSDWithReturns: 1,
                    comment: "Test comment",
                    currency: "USD",
                    date: Date(),
                    place: "Test place",
                    categoryId: randomCategory
                )
            )
        }
    }
#endif
    
    /// Edits spending and updates all related data
    /// - Parameters:
    ///   - spending: Spending to be edited
    ///   - newSpending: Object with values to be inserted into spending
    ///
    /// This method is thread-safe and works on main thread asynchronously
    func editSpending(spending: SpendingEntity, newSpending: SpendingEntityLocal, addToFetchQueue: Bool = false, exchangeRate: Double = 1) {
        context.perform { [weak self] in
            var check: Bool {
                spending.amount != newSpending.amount ||
                spending.currency != newSpending.currency ||
                spending.place != newSpending.place ||
                spending.date != newSpending.date ||
                spending.comment != newSpending.comment ||
                spending.category?.id != newSpending.categoryId
            }
            
            guard check else {
                return
            }
            
            spending.amount = newSpending.amount
            spending.amountUSD = newSpending.amountUSD
            spending.currency = newSpending.currency
            spending.place = newSpending.place
            spending.date = newSpending.date
            spending.comment = newSpending.comment
            
            if let category = self?.findCategory(newSpending.categoryId, in: DataManager.shared.context) {
                spending.category = category
            }
            
            for returnEntity in spending.returnsArr {
                if returnEntity.currency == newSpending.currency {
                    continue
                }
                
                self?.editRerturnFromSpending(
                    spending: spending,
                    oldReturn: returnEntity,
                    amount: returnEntity.amount,
                    amountUSD: returnEntity.amount / exchangeRate,
                    currency: spending.wrappedCurrency,
                    date: returnEntity.date ?? spending.wrappedDate,
                    name: returnEntity.name ??  "",
                    performSave: false
                )
            }
            
            
            self?.manager.save()
            #if DEBUG
            Logger(subsystem: Vars.appIdentifier, category: "\(#fileID)").log("\(self?.context.name ?? "") saved")
            #endif
            
            self?.fetchSpendings()
            
            if addToFetchQueue {
                UserDefaults.standard.addToFetchQueue(spending.wrappedId)
                self?.waitForRatesToBecomeAvailable()
            }
            
            HapticManager.shared.notification(.success)
        }
    }
    
    /// Deletes spending and updates all related data
    /// - Parameter spending: Spending to be deleted
    ///
    /// This method is thread-safe and works on main thread asynchronously
    func deleteSpending(_ spending: SpendingEntity) {
        context.perform { [weak self] in
            let spendingID = spending.wrappedId
            self?.context.delete(spending)
            self?.manager.save()
            self?.fetchSpendings()
            UserDefaults.standard.removeFromFetchQueue(spendingID)
        }
    }
    
    
    /// Imports spending in main app context
    /// - Parameter spending: Spending to be imported
    ///
    /// - Important: this method is not thread-safe
    func importSpending(_ spending: SpendingEntity) {
        guard let description = NSEntityDescription.entity(forEntityName: "SpendingEntity", in: context) else {
            ErrorType(CoreDataError.failedToGetEntityDescription).publish(file: #file, function: #function)
            return
        }
        
        guard let catId = spending.category?.id else {
            ErrorType(CoreDataError.failedToFindCategory).publish(file: #fileID, function: #function)
            return
        }
        
        guard let category = findCategory(catId) else {
            return
        }
                
        let newSpending = SpendingEntity(entity: description, insertInto: context)
        newSpending.id = spending.id
        newSpending.amount = spending.amount
        newSpending.amountUSD = spending.amountUSD
        newSpending.currency = spending.wrappedCurrency
        newSpending.date = spending.wrappedDate
        newSpending.place = spending.place ?? ""
        newSpending.comment = spending.comment ?? ""
        newSpending.timeZoneIdentifier = spending.timeZoneIdentifier
        
        for returnEntity in spending.returnsArr {
            importReturn(to: newSpending, returnEntity: returnEntity)
        }
        
        let privateContext = spending.managedObjectContext
        privateContext?.delete(spending)
        
        addToCategory(newSpending, category)
    }
    
    // MARK: Operations for chart
    func getNewChartData() -> [ChartData] {
        var chartData = [ChartData]()
        
        let firstSpendingDate: Date = firstSpendingDate?.getFirstDayOfMonth() ?? Date()
        
        let interval = 0...(Calendar.current.dateComponents([.month], from: firstSpendingDate, to: Date()).month ?? 1)
        
        for index in interval {
            let date = Date().getFirstDayOfMonth(-index)
            chartData.append(.init(id: -index, date: date, spendings: self.pieChartSpendings[date] ?? []))
        }
        
        return chartData
    }
    
    func getNewFilteredChartData(
        firstDate: Date,
        secondDate: Date,
        categories: [UUID],
        withReturns: Bool?,
        currencies: [String]
    ) -> [ChartData] {
        context.performAndWait {
            var chartData = [ChartData]()
            
            func filterSpendings() -> [TSSpendingEntity] {
                let fetchRequest = SpendingEntity.fetchRequest()
                fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \SpendingEntity.date, ascending: false)]
                
                guard let fetchedSpendings = try? fetchRequest.execute() else {
                    return []
                }
                
                var spendings = [TSSpendingEntity]()
                
                for spending in fetchedSpendings {
                    let safeSpending = spending.safeObject()
                    
                    guard safeSpending.wrappedDate >= firstDate, safeSpending.wrappedDate < secondDate else {
                        continue
                    }
                    
                    var result = true
                    
                    if let withReturns {
                        result = withReturns == !safeSpending.returns.isEmpty
                    }
                    
                    if let categoryID = safeSpending.categoryID, !categories.isEmpty, result {
                        result = categories.contains(categoryID)
                    }
                    
                    if !currencies.isEmpty, result {
                        result = currencies.contains(safeSpending.wrappedCurrency)
                    }
                    
                    if result {
                        spendings.append(safeSpending)
                    }
                }
                
                return spendings
            }
            
            let firstSpendingDate: Date = firstSpendingDate?.getFirstDayOfMonth() ?? Date()
            
            let interval = 0...(Calendar.current.dateComponents([.month], from: firstSpendingDate, to: Date()).month ?? 1)
            
            for number in interval {
                chartData.append(.getEmpty(id: -number))
            }
            
            chartData[0] = ChartData(id: 0, date: Date(), spendings: filterSpendings())
            
            return chartData
        }
    }
    
    // MARK: Operations for list
    @available(*, deprecated, renamed: "CoreDataModel.statsListData", message: "Deprecated, use CoreDataModel's property instead")
    func operationsForList() -> StatsListData {
        context.performAndWait {
            var result: StatsListData = [:]
            
            for spending in savedSpendings {
                let day = Calendar.current.startOfDay(for: spending.wrappedDate)
                var existingData = result[day] ?? []
                existingData.append(spending.safeObject())
                
                result.updateValue(existingData, forKey: day)
            }
            
            return result
        }
    }
    
    func waitForRatesToBecomeAvailable() {
        if !waitingForRatesToBeAvailable {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(refetchRatesFromNotification),
                name: Notification.Name("ConnectionEstablished"),
                object: NetworkMonitor.shared
            )
            
            waitingForRatesToBeAvailable = true
        }
    }
    
    @objc
    private func refetchRatesFromNotification() {
        self.fetchSpendings()
    }
    
    func updateRatesFromQueue(_ spendings: [SpendingEntity]) {
        context.perform {
            for spending in spendings {
                let safeSpending = spending.safeObject()
                
                // Goes away from safe thread
                Task { [weak self, spending, safeSpending] in
                    do {
                        let ckManager = CloudKitManager.shared
                        let formattedDate = DateFormatter.forRatesTimestamp.string(from: safeSpending.wrappedDate)
                        let rate = try await ckManager.fetchRates(timestamp: formattedDate).rates.rates[safeSpending.wrappedCurrency] ?? 1
                        
                        let localSpending = SpendingEntityLocal(
                            amount: safeSpending.amount,
                            amountUSD: safeSpending.amount / rate,
                            currency: safeSpending.currency ?? "",
                            date: safeSpending.wrappedDate,
                            place: safeSpending.place ?? "",
                            categoryId: safeSpending.categoryID ?? UUID(),
                            comment: safeSpending.comment ?? ""
                        )
                        
                        self?.editSpending(spending: spending, newSpending: localSpending, exchangeRate: rate)
                        
                        #if DEBUG
                        DispatchQueue.main.async {
                            HapticManager.shared.impact(.rigid)
                        }
                        #endif
                        
                        UserDefaults.standard.removeFromFetchQueue(safeSpending.wrappedId)
                    } catch CloudKitManager.CloudKitError.networkUnavailable {
                        self?.waitForRatesToBecomeAvailable()
                    } catch {
                        ErrorType(error: error).publish(file: #fileID, function: #function)
                    }
                }
            }
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ConnectionEstablished"), object: NetworkMonitor.shared)
        }
        
        self.waitingForRatesToBeAvailable = false
    }
}

typealias StatsListData = [Date:[TSSpendingEntity]]
