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
            #if DEBUG
            var places = [UUID:[String:Int]]()
            #endif
            
            do {
                spendings = try self.context.fetch(request)
                self.savedSpendings = spendings
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
            
            for number in 0..<7 {
                barChartData.updateValue(0, forKey: Calendar.current.date(byAdding: .day, value: -number, to: Calendar.current.startOfDay(for: Date())) ?? Date())
            }
            
            let defaultCurrency = UserDefaults.standard.string(forKey: UDKeys.defaultCurrency.rawValue) ?? Locale.current.currencyCode ?? "USD"
            let rate = UserDefaults.standard.getRates()?[defaultCurrency] ?? 1
            
            // MARK: Fetch for loop
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
                
                #if DEBUG
                // Places
                if let place = safeSpending.place, let categoryID = safeSpending.categoryID {
                    var value = places[categoryID] ?? [:]
                    value.updateValue((value[place] ?? 0) + 1, forKey: place)
                    places.updateValue(value, forKey: categoryID)
                }
                #endif
            } // End of for loop
            
            self.statsListData = statsListData
            self.barChartData = NewBarChartData(sum: barChartSum, bars: barChartData)
            self.usedCurrencies = currencies
            self.pieChartSpendings = pieChartData
            NotificationCenter.default.post(name: Notification.Name("UpdatePieChart"), object: nil)
            
            #if DEBUG
            print(spendings.count)
            #endif
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
        context.perform { [weak self] in
            let date = spending.date
            self?.context.delete(spending)
            self?.manager.save()
            self?.fetchSpendings()
            
            if let date, Calendar.current.isDateInToday(date) {
                self?.passSpendingsToSumWidget()
            }
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
//    func getChartData(categoryID: UUID? = nil) -> [ChartData] {
////        #if DEBUG
////        Logger(subsystem: Vars.appIdentifier, category: #fileID).info("\(#function) called.")
////        #endif
//        let currentCalendar = Calendar.current
//        
//        var chartData: [ChartData] = []
//        
//        let firstSpendingDate: Date = savedSpendings.last?.date?.getFirstDayOfMonth() ?? Date()
//        
//        let interval = 0...(Calendar.current.dateComponents([.month], from: firstSpendingDate, to: Date()).month ?? 1)
//        
//        for index in interval {
//            let date = currentCalendar.date(byAdding: .month, value: -index, to: .now) ?? .now
//            var spendings = self.pieChartSpendings[date.getFirstDayOfMonth()] ?? []
//            
//            if let categoryID {
//                spendings = spendings.filter { $0.categoryID == categoryID }
//            }
//            
//            chartData.append(ChartData(date: date, id: -index, spendings: spendings, places: categoryID != nil))
//        }
//        
//        return chartData
//    }
    
    func getNewChartData() -> [ChartData] {
        var chartData = [ChartData]()
        
        let firstSpendingDate: Date = savedSpendings.last?.date?.getFirstDayOfMonth() ?? Date()
        
        let interval = 0...(Calendar.current.dateComponents([.month], from: firstSpendingDate, to: Date()).month ?? 1)
        
        for index in interval {
            let date = Date().getFirstDayOfMonth(-index)
            chartData.append(.init(id: -index, date: date, spendings: self.pieChartSpendings[date] ?? []))
        }
        
        return chartData
    }
    
//    func getFilteredChartData(firstDate: Date, secondDate: Date, categories: [UUID] = [], withReturns: Bool? = nil, currencies: [String]) -> [ChartData] {
//        var chartData: [ChartData] = []
//        
//        let firstSpendingDate: Date = savedSpendings.last?.date?.getFirstDayOfMonth() ?? Date()
//        
//        let interval = 0...(Calendar.current.dateComponents([.month], from: firstSpendingDate, to: Date()).month ?? 1)
//        
//        for _ in interval {
//            chartData.append(ChartData.getEmpty())
//        }
//        
//        chartData[0] = ChartData(
//            firstDate: firstDate,
//            secondDate: secondDate,
//            spendings: self.savedSpendings,
//            categories: categories,
//            withReturns: withReturns,
//            currencies: currencies
//        )
//        return chartData
//    }
    
    func getNewFilteredChartData(
        firstDate: Date,
        secondDate: Date,
        categories: [UUID],
        withReturns: Bool?,
        currencies: [String]
    ) -> [ChartData] {
        var chartData = [ChartData]()
        
        func filterSpendings() -> [TSSpendingEntity] {
            var spendings = [TSSpendingEntity]()
            
            for spending in self.savedSpendings {
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
        
        let firstSpendingDate: Date = savedSpendings.last?.date?.getFirstDayOfMonth() ?? Date()
        
        let interval = 0...(Calendar.current.dateComponents([.month], from: firstSpendingDate, to: Date()).month ?? 1)
        
        for _ in interval {
//            let date = Date().getFirstDayOfMonth(-index)
            chartData.append(.getEmpty())
        }
        
        chartData[0] = ChartData(id: 0, date: Date(), spendings: filterSpendings())
        
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
