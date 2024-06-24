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
    func fetchSpendings() {
        context.perform { [weak self] in
            guard let self else { return }
            
            let request = SpendingEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
            var spendings = [SpendingEntity]()
            var statsListData = StatsListData()
            var barChartData = [Date:Double]()
            var barChartSum: Double = 0
            let weekAgo = {
                let date = Calendar.current.startOfDay(for: Date())
                return Calendar.current.date(byAdding: .day, value: -7, to: date) ?? Date()
            }()
            var currencies = Set<Currency>()
            
            do {
                spendings = try self.context.fetch(request)
                self.savedSpendings = spendings
                self.updateCharts = true
            } catch {
                ErrorType(error: error).publish(file: #file, function: #function)
            }
            
//            var pieChartData: [Date:NewPieChartData] = {
//                var result: [Date:NewPieChartData] = .init()
//                let lastDate = spendings.last?.wrappedDate.getFirstDayOfMonth() ?? Date().getFirstDayOfMonth()
//                let interval = Calendar.current.dateComponents([.month], from: lastDate, to: Date()).month ?? 1
////                print("LAST DATE: \(lastDate)")
////                print("INTERVAL: \(interval)")
////                print("SPENDINGS: \(spendings.count)")
//                
//                for index in 0...interval {
//                    result.updateValue(NewPieChartData(id: -index, sectors: .init(), sum: 0), forKey: Date().getFirstDayOfMonth(-index))
//                }
//                
//                return result
//            }()
            
            var pieChartData: [Date:[TSSpendingEntity]] = {
                var result: [Date:[TSSpendingEntity]] = .init()
                let lastDate = spendings.last?.wrappedDate.getFirstDayOfMonth() ?? Date().getFirstDayOfMonth()
                let interval = Calendar.current.dateComponents([.month], from: lastDate, to: Date()).month ?? 1
//                print("LAST DATE: \(lastDate)")
//                print("INTERVAL: \(interval)")
//                print("SPENDINGS: \(spendings.count)")
                
                for index in 0...interval {
                    result.updateValue([], forKey: Date().getFirstDayOfMonth(-index))
                }
                
                return result
            }()
            
            for number in 0..<7 {
                barChartData.updateValue(0, forKey: Calendar.current.date(byAdding: .day, value: -number, to: Calendar.current.startOfDay(for: Date())) ?? Date())
            }
            
            let defaultCurrency = UserDefaults.standard.string(forKey: UDKeys.defaultCurrency.rawValue) ?? Locale.current.currencyCode ?? "USD"
            let rate = UserDefaults.standard.getRates()?[defaultCurrency] ?? 1
            
            for spending in spendings {
                let safeSpending = spending.safeObject()
                let startOfDay = Calendar.current.startOfDay(for: safeSpending.wrappedDate)
                
                currencies.insert(Currency(code: safeSpending.wrappedCurrency))
                
                // Stats list data
                if statsListData[startOfDay] != nil {
                    statsListData[startOfDay]?.append(safeSpending)
                } else {
                    statsListData.updateValue([safeSpending], forKey: startOfDay)
                }
                
                // Bar chart data
                if startOfDay > weekAgo {
                    let sum = defaultCurrency == safeSpending.wrappedCurrency ? safeSpending.amountWithReturns : (safeSpending.amountUSDWithReturns * rate)
                    
                    barChartData.updateValue((barChartData[startOfDay] ?? 0) + sum, forKey: startOfDay)
                    
                    barChartSum += sum
                }
                
                // Pie chart data
                pieChartData[startOfDay.getFirstDayOfMonth()]?.append(safeSpending)
                
            } // End of for loop
            
            self.statsListData = statsListData
            self.barChartData = NewBarChartData(sum: barChartSum, bars: barChartData)
            self.usedCurrencies = currencies
            self.pieChartSpendings = pieChartData
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
        #if DEBUG
        Logger(subsystem: Vars.appIdentifier, category: "\(#fileID)").debug("\(#function) called in \(#fileID)")
        #endif
        let firstDate = Calendar.current.startOfDay(for: .now)
        let secondDate = Calendar.current.date(byAdding: .day, value: 1, to: firstDate)!
        let predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", firstDate as CVarArg, secondDate as CVarArg)
        
        guard 
            let spendings = try? getSpendings(predicate: predicate),
            let rates = UserDefaults.standard.getRates(),
            let defaultCurrency = UserDefaults.standard.string(forKey: UDKeys.defaultCurrency.rawValue)
        else {
            return
        }
        
        let sum = spendings.map { spending in
            if spending.wrappedCurrency == defaultCurrency {
                return spending.amountWithReturns
            } else {
                return spending.amountUSDWithReturns * (rates[defaultCurrency] ?? 1)
            }
        }
        
        WidgetsManager.shared.passAmountToSumWidgets(sum.reduce(0, +))
    }
    
    func addSpending(spending: SpendingEntityLocal, playHaptic: Bool = true) {
        let backgroundContext = container.newBackgroundContext()
        backgroundContext.name = "\(#fileID) background context"
        
        backgroundContext.performAndWait {
            guard let description = NSEntityDescription.entity(forEntityName: "SpendingEntity", in: backgroundContext) else {
                ErrorType(CoreDataError.failedToGetEntityDescription).publish()
                return
            }
            
            guard let category = findCategory(spending.categoryId, in: backgroundContext) else {
                ErrorType(CoreDataError.failedToFindCategory).publish()
                return
            }
            
            let newSpending = SpendingEntity(entity: description, insertInto: backgroundContext)
            
            newSpending.id = UUID()
            newSpending.amount = spending.amount
            newSpending.amountUSD = spending.amountUSD
            newSpending.currency = spending.currency
            newSpending.date = spending.date
            newSpending.place = spending.place
            newSpending.comment = spending.comment
            
            addToCategory(newSpending, category)
            try? backgroundContext.save()
            fetchSpendings()
            
            if Calendar.current.isDateInToday(spending.date) {
                DispatchQueue.main.async { [weak self] in
                    self?.passSpendingsToSumWidget()
                }
            }
            
            if playHaptic {
                HapticManager.shared.notification(.success)
            }
            
            backgroundContext.reset()
        }
    }
    
    func editSpending(spending: SpendingEntity, newSpending: SpendingEntityLocal) {
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
            
            self?.manager.save()
            #if DEBUG
            Logger(subsystem: Vars.appIdentifier, category: "\(#fileID)").log("\(self?.context.name ?? "") saved")
            #endif
            
            self?.fetchSpendings()
            
            if Calendar.current.isDateInToday(newSpending.date) {
                self?.passSpendingsToSumWidget()
            }
            
            HapticManager.shared.notification(.success)
        }
    }
    
    func deleteSpending(_ spending: SpendingEntity) {
        let date = spending.date
        context.delete(spending)
        manager.save()
        fetchSpendings()
        
        if let date, Calendar.current.isDateInToday(date) {
            passSpendingsToSumWidget()
        }
    }
    
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
        
        for returnEntity in spending.returnsArr {
            importReturn(to: newSpending, returnEntity: returnEntity)
        }
        
        let privateContext = spending.managedObjectContext
        privateContext?.delete(spending)
        
        addToCategory(newSpending, category)
    }
    
    func validateReturns(rvm: RatesViewModel) {
        var count: Int = 0
        #if DEBUG
        let logger = Logger(subsystem: Vars.appIdentifier, category: "CoreDataModel")
        #endif
        
        for spending in self.savedSpendings {
            if !spending.returnsArr.isEmpty {
                for entity in spending.returnsArr {
                    editRerturnFromSpending(
                        spending: spending,
                        oldReturn: entity,
                        amount: entity.amount,
                        amountUSD: entity.amount / (rvm.rates[entity.currency ?? "USD"] ?? 1),
                        currency: entity.currency ?? "USD",
                        date: entity.date ?? Date(),
                        name: entity.name ?? ""
                    )
                    
                    count += 1
                }
            }
        }
        
        HapticManager.shared.notification(.success)
        
        #if DEBUG
        logger.log("Validated \(count) returns")
        #endif
    }
    
    func operationsSum() -> Double {
        return savedSpendings.compactMap { $0.amountUSD }.reduce(0, +)
    }
    
    // MARK: Operations for chart
    func getChartData(isMinimized: Bool = true, categoryName: String? = nil) -> [ChartData] {
        let currentCalendar = Calendar.current
        
        var chartData: [ChartData] = []
        
        let firstSpendingDate: Date = savedSpendings.last?.date?.getFirstDayOfMonth() ?? Date()
        
        let interval = 0...(Calendar.current.dateComponents([.month], from: firstSpendingDate, to: Date()).month ?? 1)
        
        for index in interval {
            let date = currentCalendar.date(byAdding: .month, value: -index, to: .now) ?? .now
            var spendings = self.pieChartSpendings[date.getFirstDayOfMonth()] ?? []
            
            if let categoryName {
                spendings = spendings.filter { $0.categoryName == categoryName }
            }
            
            chartData.append(ChartData(date: date, id: -index, showOther: !isMinimized, spendings: spendings, categoryName: categoryName))
        }
        
        return chartData
    }
    
    func getFilteredChartData(firstDate: Date, secondDate: Date, categories: [UUID] = [], withReturns: Bool? = nil, currencies: [String]) -> [ChartData] {
        var chartData: [ChartData] = []
        
        let firstSpendingDate: Date = savedSpendings.last?.date?.getFirstDayOfMonth() ?? Date()
        
        let interval = 0...(Calendar.current.dateComponents([.month], from: firstSpendingDate, to: Date()).month ?? 1)
        
        for _ in interval {
            chartData.append(ChartData.getEmpty())
        }
        
        chartData[0] = ChartData(firstDate: firstDate, secondDate: secondDate, spendings: self.savedSpendings, categories: categories, withReturns: withReturns, currencies: currencies)
        return chartData
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
    
    func updateBarChart() {
        context.perform {
            var barChartData = [Date:Double]()
            var barChartSum: Double = 0
            let weekAgo = {
                let date = Calendar.current.startOfDay(for: Date())
                return Calendar.current.date(byAdding: .day, value: -7, to: date) ?? Date()
            }()
            
            for number in 0..<7 {
                barChartData.updateValue(0, forKey: Calendar.current.date(byAdding: .day, value: -number, to: Calendar.current.startOfDay(for: Date())) ?? Date())
            }
            
            let defaultCurrency = UserDefaults.standard.string(forKey: UDKeys.defaultCurrency.rawValue) ?? Locale.current.currencyCode ?? "USD"
            let rate = UserDefaults.standard.getRates()?[defaultCurrency] ?? 1
            
            for spending in self.savedSpendings {
                let safeSpending = spending.safeObject()
                let startOfDay = Calendar.current.startOfDay(for: safeSpending.wrappedDate)
                
                if startOfDay > weekAgo {
                    let sum = defaultCurrency == safeSpending.wrappedCurrency ? safeSpending.amountWithReturns : (safeSpending.amountUSDWithReturns * rate)
                    
                    barChartData.updateValue((barChartData[startOfDay] ?? 0) + sum, forKey: startOfDay)
                    
                    barChartSum += sum
                } else {
                    break
                }
            }
            
            self.barChartData = NewBarChartData(sum: barChartSum, bars: barChartData)
        }
    }
}

typealias StatsListData = [Date:[TSSpendingEntity]]

// MARK: Template data
extension CoreDataModel {
    func addTemplateData() {
        context.perform { [weak self] in
            guard let self else { return }
            
            let restaurantsID = addCategory(name: "Restaurants", color: "nord1")
            let groceriesID = addCategory(name: "Groceries", color: "nord4")
            let subscriptionsID = addCategory(name: "Subscriptions", color: "nord6")
            let transportID = addCategory(name: "Transport", color: "nord94")
            let travelID = addCategory(name: "Travel", color: "nord7")
            
            let components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            
            func getDate(days: Int) -> Date {
                var localComponents = components
                localComponents.calendar = .current
                localComponents.day = (localComponents.day ?? 1) - days
                localComponents.hour = (8...23).randomElement() ?? 6
                localComponents.minute = (0..<60).randomElement() ?? 24
                return localComponents.date ?? Date()
            }
            
            let restaurantsSpendings: [SpendingEntityLocal] = [
                .init(amount: 15, amountUSD: 15, currency: "USD", date: getDate(days: 5), place: "McDonald's", categoryId: restaurantsID, comment: ""),
                .init(amount: 10, amountUSD: 10, currency: "USD", date: getDate(days: 7), place: "KFC", categoryId: restaurantsID, comment: ""),
                .init(amount: 12, amountUSD: 12, currency: "USD", date: getDate(days: 12), place: "Some Restaurant", categoryId: restaurantsID, comment: ""),
                .init(amount: 9, amountUSD: 9, currency: "USD", date: getDate(days: 13), place: "McDonald's", categoryId: restaurantsID, comment: ""),
                .init(amount: 22, amountUSD: 22, currency: "USD", date: getDate(days: 28), place: "Some Restaurant", categoryId: restaurantsID, comment: ""),
                .init(amount: 15, amountUSD: 15, currency: "USD", date: getDate(days: 37), place: "Dominos", categoryId: restaurantsID, comment: "")
            ]
            
            let groceriesSpendings: [SpendingEntityLocal] = [
                .init(amount: 1500, amountUSD: 10, currency: "JPY", date: Date(), place: "7 Eleven", categoryId: groceriesID, comment: ""),
                .init(amount: 3.90, amountUSD: 3.90, currency: "USD", date: getDate(days: 5), place: "7 Eleven", categoryId: groceriesID, comment: ""),
                .init(amount: 25, amountUSD: 25, currency: "USD", date: getDate(days: 12), place: "Costco", categoryId: groceriesID, comment: ""),
                .init(amount: 2.50, amountUSD: 2.50, currency: "USD", date: getDate(days: 20), place: "Walmart", categoryId: groceriesID, comment: ""),
                .init(amount: 18, amountUSD: 18, currency: "USD", date: getDate(days: 23), place: "Walmart", categoryId: groceriesID, comment: ""),
                .init(amount: 1.99, amountUSD: 1.99, currency: "USD", date: getDate(days: 28), place: "7 Eleven", categoryId: groceriesID, comment: ""),
                .init(amount: 16, amountUSD: 16, currency: "USD", date: getDate(days: 35), place: "", categoryId: groceriesID, comment: ""),
                .init(amount: 35, amountUSD: 35, currency: "USD", date: getDate(days: 44), place: "Target", categoryId: groceriesID, comment: ""),
                .init(amount: 12, amountUSD: 12, currency: "USD", date: getDate(days: 51), place: "", categoryId: groceriesID, comment: ""),
                .init(amount: 7.70, amountUSD: 7.70, currency: "USD", date: getDate(days: 60), place: "7 Eleven", categoryId: groceriesID, comment: ""),
            ]
            
            let subscriptionsSpendings: [SpendingEntityLocal] = [
                .init(amount: 9.99, amountUSD: 9.99, currency: "USD", date: getDate(days: 1), place: "Apple Music", categoryId: subscriptionsID, comment: ""),
                .init(amount: 2.99, amountUSD: 2.99, currency: "USD", date: getDate(days: 11), place: "iCloud Plus", categoryId: subscriptionsID, comment: ""),
                .init(amount: 20, amountUSD: 20, currency: "USD", date: getDate(days: 2), place: "Mobile network", categoryId: subscriptionsID, comment: ""),
                .init(amount: 9.99, amountUSD: 9.99, currency: "USD", date: getDate(days: 31), place: "Apple Music", categoryId: subscriptionsID, comment: ""),
                .init(amount: 2.99, amountUSD: 2.99, currency: "USD", date: getDate(days: 42), place: "iCloud Plus", categoryId: subscriptionsID, comment: ""),
                .init(amount: 20, amountUSD: 20, currency: "USD", date: getDate(days: 33), place: "Mobile network", categoryId: subscriptionsID, comment: ""),
                .init(amount: 9.99, amountUSD: 9.99, currency: "USD", date: getDate(days: 62), place: "Apple Music", categoryId: subscriptionsID, comment: ""),
                .init(amount: 2.99, amountUSD: 2.99, currency: "USD", date: getDate(days: 72), place: "iCloud Plus", categoryId: subscriptionsID, comment: ""),
                .init(amount: 20, amountUSD: 20, currency: "USD", date: getDate(days: 64), place: "Mobile network", categoryId: subscriptionsID, comment: ""),
            ]
            
            let transportSpendings: [SpendingEntityLocal] = [
                .init(amount: 1000, amountUSD: 6.30, currency: "JPY", date: getDate(days: 1), place: "Taxi", categoryId: transportID, comment: ""),
                .init(amount: 2.90, amountUSD: 2.90, currency: "USD", date: getDate(days: 4), place: "Subway", categoryId: transportID, comment: ""),
                .init(amount: 1.90, amountUSD: 1.90, currency: "USD", date: getDate(days: 10), place: "Bus", categoryId: transportID, comment: ""),
                .init(amount: 2.90, amountUSD: 2.90, currency: "USD", date: getDate(days: 20), place: "Subway", categoryId: transportID, comment: ""),
                .init(amount: 1.90, amountUSD: 1.90, currency: "USD", date: getDate(days: 25), place: "Bus", categoryId: transportID, comment: ""),
                .init(amount: 1.90, amountUSD: 1.90, currency: "USD", date: getDate(days: 32), place: "Bus", categoryId: transportID, comment: ""),
                .init(amount: 2.90, amountUSD: 2.90, currency: "USD", date: getDate(days: 41), place: "Subway", categoryId: transportID, comment: ""),
                .init(amount: 2.90, amountUSD: 2.90, currency: "USD", date: getDate(days: 50), place: "Subway", categoryId: transportID, comment: ""),
            ]
            
            let travelSpendings: [SpendingEntityLocal] = [
                .init(amount: 39500, amountUSD: 150, currency: "JPY", date: getDate(days: 9), place: "Plane tickets", categoryId: travelID, comment: ""),
                .init(amount: 130, amountUSD: 130, currency: "USD", date: getDate(days: 78), place: "Train tickets", categoryId: travelID, comment: "")
            ]
            
            for spending in restaurantsSpendings {
                addSpending(spending: spending, playHaptic: false)
            }
            
            for spending in groceriesSpendings {
                addSpending(spending: spending, playHaptic: false)
            }
            
            for spending in subscriptionsSpendings {
                addSpending(spending: spending, playHaptic: false)
            }
            
            for spending in transportSpendings {
                addSpending(spending: spending, playHaptic: false)
            }
            
            for spending in travelSpendings {
                addSpending(spending: spending, playHaptic: false)
            }
        }
        
        HapticManager.shared.notification(.success)
    }
}
