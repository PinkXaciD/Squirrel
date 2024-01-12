//
//  SpendingsModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/07.
//

import CoreData

extension CoreDataModel {
    func fetchSpendings() {
        let request = SpendingEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            savedSpendings = try context.fetch(request)
        } catch let error {
            print("Error fetching CoreData: \(error)")
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
        
        if Calendar.current.isDateInToday(date) {
            passSpendingsToSumWidget()
        }
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
    
    func operationsInMonth(_ date: Date) -> [CategoryEntityLocal] {
        var firstDate: Date = .now
        var secondDate: Date = .now
        
        var firstDateComponents = Calendar.current.dateComponents([.month, .year, .era], from: date)
        firstDateComponents.day = 1
        firstDateComponents.calendar = Calendar.current
        firstDate = firstDateComponents.date ?? .distantPast
        
        if let endDate = Calendar.current.date(byAdding: .month, value: 1, to: date) {
            var secondDateComponents = Calendar.current.dateComponents([.month, .year, .era], from: endDate)
            secondDateComponents.day = 1
            secondDateComponents.calendar = Calendar.current
            secondDate = secondDateComponents.date ?? .distantPast
        }
        
        let predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", firstDate as CVarArg, secondDate as CVarArg)
        var filteredSpendings: [SpendingEntity] = []
        
        do {
            filteredSpendings = try getSpendings(predicate: predicate)
        } catch {
            ErrorType(error: error).publish()
        }
        
        var categories: [CategoryEntityLocal] {
            var preResult: [UUID:CategoryEntityLocal] = [:]
            for spending in filteredSpendings {
                if let catId = spending.category?.id {
                    var localCategory = preResult[catId] ?? CategoryEntityLocal(
                        color: spending.category?.color ?? "",
                        id: catId,
                        name: spending.categoryName,
                        spendings: []
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
                    preResult.updateValue(localCategory, forKey: catId)
                }
            }
            var result: [CategoryEntityLocal] = []
            
            for category in preResult {
                result.append(category.value)
            }
            
            return result
        }
        
        return categories
    }
    
    // MARK: Operations for chart
    func getChartData(isMinimized: Bool = true) -> [ChartData] {
        let currentCalendar = Calendar.current
        
        var spendings: [SpendingEntity] = []
        var chartData: [ChartData] = []
        do {
            spendings = try getSpendings()
        } catch {
            ErrorType(error: error).publish()
        }
        
        let firstSpendingDate: Date = spendings.last?.date ?? .now
        
        let interval = Calendar.current.dateComponents([.month], from: firstSpendingDate, to: .now).month ?? 1
        
        for index in 0...interval {
            let date = currentCalendar.date(byAdding: .month, value: -index, to: .now) ?? .now
            chartData.append(ChartData(date: date, id: -index, withOther: isMinimized, cdm: self))
        }
        
        return chartData.reversed()
    }
    
    // MARK: Operations for list
    func operationsForList() -> StatsListData {
        var result: StatsListData = [:]
        
        func dateFormatForList(_ date: Date) -> String {
            if Calendar.current.isDateInToday(date) {
                return NSLocalizedString("Today", comment: "")
            } else if Calendar.current.isDate(date, inSameDayAs: .now.previousDay) {
                return NSLocalizedString("Yesterday", comment: "")
            } else {
                let dateFormatter: DateFormatter = .init()
                dateFormatter.dateStyle = .long
                dateFormatter.timeStyle = .none
                
                return dateFormatter.string(from: date)
            }
        }
        
        for spending in savedSpendings {
            let dateString = dateFormatForList(spending.wrappedDate)
            var existingData = result[dateString] ?? []
            existingData.append(spending)
            
            result.updateValue(existingData, forKey: dateString)
        }
        
        return result
    }
}

typealias StatsListData = [String:[SpendingEntity]]

struct ChartData: Identifiable {
    let id: Int
    let date: Date
    let categories: [CategoryEntityLocal]
    
    init(date: Date, id: Int, withOther: Bool, cdm: CoreDataModel) {
        let currentCalendar = Calendar.current
        var components = currentCalendar.dateComponents([.month, .year, .era], from: date)
        components.calendar = currentCalendar
        let firstDate = components.date ?? .distantPast
        let secondDate = currentCalendar.date(byAdding: .month, value: 1, to: firstDate) ?? .distantPast
        
        self.date = firstDate
        self.id = id
        
        var tempCategories: [UUID:CategoryEntityLocal] = [:]
        let predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", firstDate as CVarArg, secondDate as CVarArg)
        
        if let spendings = try? cdm.getSpendings(predicate: predicate) {
            for spending in spendings {
                guard
                    let category = spending.category,
                    let catId = category.id,
                    let categoryName = category.color,
                    let categoryColor = category.color
                else {
                    continue
                }
                        
                if let existing = tempCategories[catId] {
                    let localSpending = SpendingEntityLocal(
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
                    
                    var catSpendings: [SpendingEntityLocal] = existing.spendings
                    catSpendings.append(localSpending)
                    let updatedCategory = CategoryEntityLocal(
                        color: existing.color,
                        id: existing.id,
                        name: existing.name,
                        spendings: catSpendings
                    )
                    
                    tempCategories.updateValue(updatedCategory, forKey: catId)
                    
                } else {
                    let localSpending = SpendingEntityLocal(
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
                    
                    let updatedCategory = CategoryEntityLocal(
                        color: categoryColor,
                        id: catId,
                        name: categoryName,
                        spendings: [localSpending]
                    )
                    
                    tempCategories.updateValue(updatedCategory, forKey: catId)
                }
            }
        }
        
//        if withOther {
//            let arr = Array(tempCategories.values).sorted { category1, category2 in
//                let firstSum = category1.spendings.map { $0.amountUSD }.reduce(0, +)
//                let secondSum = category2.spendings.map { $0.amountUSD }.reduce(0, +)
//                
//                return firstSum > secondSum
//            }
//            
//            let id: UUID = .init()
//            var otherSum: Double = 0
//            var arr2: [CategoryEntityLocal] = []
//            
//            for index in 0..<arr.count {
//                if index < 4 {
//                    arr2.append(arr[index])
//                } else {
//                    otherSum += arr[index].spendings.map { $0.amountUSD }.reduce(0, +)
//                }
//            }
//            
//            if otherSum > 0 {
//                arr2.append(
//                    .init(
//                        color: "secondary",
//                        id: id,
//                        name: "Other",
//                        spendings: [.init(
//                            amount: otherSum,
//                            amountUSD: otherSum,
//                            currency: UserDefaults.standard.string(forKey: "defaultCurrency") ?? "USD",
//                            date: .now,
//                            place: "",
//                            categoryId: id,
//                            comment: ""
//                        )]
//                    )
//                )
//            }
//            
//            self.categories = arr2
//        } else {
            self.categories = Array(tempCategories.values)
//        }
    }
}
