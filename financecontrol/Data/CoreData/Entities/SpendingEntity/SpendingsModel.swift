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
        let request = SpendingEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            savedSpendings = try context.fetch(request)
            updateCharts = true
        } catch let error {
            ErrorType(error: error).publish()
        }
    }
    
    func getSpendings(predicate: NSPredicate? = nil) throws -> [SpendingEntity] {
        let request = SpendingEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        if let predicate = predicate {
            request.predicate = predicate
        }
        
        do {
            return try context.fetch(request)
        } catch {
            throw error
        }
    }
    
    func passSpendingsToSumWidget() {
        let firstDate = Calendar.current.startOfDay(for: .now)
        let secondDate = Calendar.current.date(byAdding: .day, value: 1, to: firstDate)!
        let predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", firstDate as CVarArg, secondDate as CVarArg)
        
        guard 
            let spendings = try? getSpendings(predicate: predicate),
            let rates = UserDefaults.standard.value(forKey: "rates") as? [String: Double],
            let defaultCurrency = UserDefaults.standard.string(forKey: "defaultCurrency")
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
    
    func addSpending(spending: SpendingEntityLocal) {
        if let description = NSEntityDescription.entity(forEntityName: "SpendingEntity", in: context),
           let category = findCategory(spending.categoryId) {
            let newSpending = SpendingEntity(entity: description, insertInto: context)
            
            newSpending.id = UUID()
            newSpending.amount = spending.amount
            newSpending.amountUSD = spending.amountUSD
            newSpending.currency = spending.currency
            newSpending.date = spending.date
            newSpending.place = spending.place
            newSpending.comment = spending.comment
            
            addToCategory(newSpending, category)
            
            manager.save()
            fetchSpendings()
            
            if Calendar.current.isDateInToday(spending.date) {
                passSpendingsToSumWidget()
            }
        }
    }
    
    func editSpending(spending: SpendingEntity, newSpending: SpendingEntityLocal) {
        spending.amount = newSpending.amount
        spending.amountUSD = newSpending.amountUSD
        spending.currency = newSpending.currency
        spending.place = newSpending.place
        spending.date = newSpending.date
        spending.comment = newSpending.comment
        
        if let category = findCategory(newSpending.categoryId) {
            spending.category = category
        }
        
        manager.save()
        fetchSpendings()
        
        if Calendar.current.isDateInToday(newSpending.date) {
            passSpendingsToSumWidget()
        }
    }
    
    func deleteSpending(_ spending: SpendingEntity) {
        let date = spending.date ?? .distantPast
        context.delete(spending)
        manager.save()
        fetchSpendings()
        
        updateCharts = true
        
        if Calendar.current.isDateInToday(date) {
            passSpendingsToSumWidget()
        }
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
        do {
            let spendings = try getSpendings()
            return spendings.compactMap { $0.amountUSD }.reduce(0, +)
        } catch {
            return 0
        }
    }
    
    func operationsSumWeek(_ usdRate: Double = 1) -> Double {
        let currentCalendar = Calendar.current
        let defaultCurrency = UserDefaults.standard.string(forKey: "defaultCurrency")
        let currentDateComponents = currentCalendar.dateComponents([.day, .month, .year, .era], from: .now)
        let currentDate = currentCalendar.date(from: currentDateComponents) ?? .distantFuture
        let startDate = currentCalendar.date(byAdding: .day, value: -6, to: currentDate) ?? .distantFuture
        let predicate = NSPredicate(format: "date > %@", startDate as CVarArg)
        
        var spendings: [SpendingEntity] = []
        do {
            spendings = try getSpendings(predicate: predicate)
        } catch {
            ErrorType(error: error).publish()
        }
        
        return spendings.map { spending in
            if spending.currency == defaultCurrency {
                spending.amountWithReturns
            } else {
                spending.amountUSDWithReturns * usdRate
            }
        }
        .reduce(0, +)
    }
    
    // MARK: Operations for legend
    func operationsInMonth(startDate: Date, endDate: Date, categoryName: String?) -> [CategoryEntityLocal] {
        let range = startDate ..< endDate
        
        var filteredSpendings: [SpendingEntity] = savedSpendings.filter { range.contains($0.wrappedDate) }
        
        
        if let categoryName = categoryName {
            filteredSpendings = filteredSpendings.filter({ $0.categoryName == categoryName })
        }
        
        var categories: [CategoryEntityLocal] {
            var preResult: [String:CategoryEntityLocal] = [:]
            let colors: [String] = Array(CustomColor.nordAurora.keys).sorted(by: <)
            var colorIndex: Int = 0
            
            for spending in filteredSpendings {
                if categoryName != nil {
                    var place: String {
                        guard let place = spending.place, !place.isEmpty else {
                            return NSLocalizedString("Unknown", comment: "")
                        }
                        
                        return place
                    }
                    
                    var localCategory: CategoryEntityLocal = preResult[place] ?? CategoryEntityLocal(
                        color: place == NSLocalizedString("Unknown", comment: "") ? "secondary" : colors[colorIndex],
                        id: spending.wrappedId,
                        name: place,
                        spendings: [], 
                        sumUSDWithReturns: 0, 
                        sumWithReturns: 0
                    )
                    
                    if preResult[place] == nil {
                        if colorIndex < colors.count - 1 {
                            colorIndex += 1
                        } else {
                            colorIndex = 0
                        }
                    }
                    
                    localCategory.spendings.append(
                        SpendingEntityLocal(
                            amountUSD: spending.amountUSD,
                            amount: spending.amount,
                            amountWithReturns: spending.amountWithReturns,
                            amountUSDWithReturns: spending.amountUSDWithReturns,
                            comment: spending.comment ?? "",
                            currency: spending.wrappedCurrency,
                            date: spending.wrappedDate,
                            place: spending.place ?? "",
                            categoryId: spending.wrappedId
                        )
                    )
                    
                    localCategory.sumUSDWithReturns += spending.amountUSDWithReturns
                    
                    let defaultCurrency = UserDefaults.standard.string(forKey: "defaultCurrency") ?? Locale.current.currencyCode ?? "USD"
                    
                    if spending.currency == defaultCurrency {
                        localCategory.sumWithReturns += spending.amountWithReturns
                    } else {
                        if let fetchedRates = UserDefaults.standard.dictionary(forKey: "rates") as? [String:Double],
                           let defaultCurrencyRate = fetchedRates[defaultCurrency] {
                            localCategory.sumWithReturns += (spending.amountUSDWithReturns * defaultCurrencyRate)
                        }
                    }
                    
                    preResult.updateValue(localCategory, forKey: place)
                } else {
                    if let catId = spending.category?.id {
                        var localCategory = preResult[catId.uuidString] ?? CategoryEntityLocal(
                            color: spending.category?.color ?? "",
                            id: catId,
                            name: spending.categoryName,
                            spendings: [], 
                            sumUSDWithReturns: 0, 
                            sumWithReturns: 0
                        )
                        
                        localCategory.spendings.append(
                            SpendingEntityLocal(
                                amountUSD: spending.amountUSD,
                                amount: spending.amount,
                                amountWithReturns: spending.amountWithReturns,
                                amountUSDWithReturns: spending.amountUSDWithReturns,
                                comment: spending.comment ?? "",
                                currency: spending.wrappedCurrency,
                                date: spending.wrappedDate,
                                place: spending.place ?? "",
                                categoryId: catId
                            )
                        )
                        
                        localCategory.sumUSDWithReturns += spending.amountUSDWithReturns
                        
                        let defaultCurrency = UserDefaults.standard.string(forKey: "defaultCurrency") ?? Locale.current.currencyCode ?? "USD"
                        
                        if spending.currency == defaultCurrency {
                            localCategory.sumWithReturns += spending.amountWithReturns
                        } else {
                            if let fetchedRates = UserDefaults.standard.dictionary(forKey: "rates") as? [String:Double],
                               let defaultCurrencyRate = fetchedRates[defaultCurrency] {
                                localCategory.sumWithReturns += (spending.amountUSDWithReturns * defaultCurrencyRate)
                            }
                        }
                        
                        preResult.updateValue(localCategory, forKey: catId.uuidString)
                    }
                }
            }
            
            return Array(preResult.values)
        }
        
        return categories.sorted(by: >)
    }
    
    // MARK: Operations for chart
    func getChartData(isMinimized: Bool = true, categoryName: String? = nil) -> [ChartData] {
        let currentCalendar = Calendar.current
        
        var chartData: [ChartData] = []
        
        let firstSpendingDate: Date = savedSpendings.last?.date?.getFirstDayOfMonth() ?? .now
        
        let interval = 0...(Calendar.current.dateComponents([.month], from: firstSpendingDate, to: .now).month ?? 1)
        
        for index in interval {
            let date = currentCalendar.date(byAdding: .month, value: -index, to: .now) ?? .now
            chartData.append(ChartData(date: date, id: -index, withOther: isMinimized, cdm: self, categoryName: categoryName))
        }
        
        return chartData
    }
    
    // MARK: Operations for list
    func operationsForList() -> StatsListData {
        var result: StatsListData = [:]
        
        for spending in savedSpendings {
            let day = Calendar.current.startOfDay(for: spending.wrappedDate)
            var existingData = result[day] ?? []
            existingData.append(spending)
            
            result.updateValue(existingData, forKey: day)
        }
        
        return result
    }
}

typealias StatsListData = [Date:[SpendingEntity]]
