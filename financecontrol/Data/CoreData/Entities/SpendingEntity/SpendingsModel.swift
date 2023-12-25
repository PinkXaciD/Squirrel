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
    }
    
    func deleteSpending(_ spending: SpendingEntity) {
        context.delete(spending)
        manager.save()
        fetchSpendings()
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
    
    func getChartData() -> [ChartData] {
        let currentCalendar = Calendar.current
        
        var spendings: [SpendingEntity] = []
        var dates: [Date] = []
        var chartData: [ChartData] = []
        do {
            spendings = try getSpendings()
        } catch {
            ErrorType(error: error).publish()
        }
        
        let firstSpendingDate: Date = spendings.last?.wrappedDate ?? .now
        
        for spending in spendings {
            var components = currentCalendar.dateComponents([.month, .year, .era], from: spending.wrappedDate)
            components.calendar = currentCalendar
            if let date = components.date {
                if !dates.contains(date) {
                    dates.append(date)
                }
            }
        }
        
        let interval = Calendar.current.dateComponents([.month], from: firstSpendingDate, to: .now).month ?? 1
        
        for index in 0...interval {
            let date = currentCalendar.date(byAdding: .month, value: -index, to: .now) ?? .now
            chartData.append(ChartData(date: date, id: -index, cdm: self))
        }
        
        return chartData.reversed()
    }
    
    func operationsForList() -> [String:[SpendingEntity]]{
        var listData: [SpendingListData] = []
        var result: [String:[SpendingEntity]] = [:]
        
        do {
            listData = try getSpendings()
                .sorted { $0.wrappedDate > $1.wrappedDate }
                .map { SpendingListData(entity: $0) }
        } catch {
            ErrorType(error: error).publish()
        }
        
        for spending in listData {
            if let existingData = result[spending.date] {
                result.updateValue(existingData + [spending.entity], forKey: spending.date)
            } else {
                result.updateValue([spending.entity], forKey: spending.date)
            }
        }
        
        return result
    }
}

struct ChartData: Identifiable {
    let id: Int
    let date: Date
    let categories: [CategoryEntityLocal]
    
    init(date: Date, id: Int, cdm: CoreDataModel) {
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
                if let catId = spending.category?.id,
                   let existing = tempCategories[catId] {
                    
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
                } else if let category = spending.category,
                          let catId = category.id {
                    
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
                        color: category.color ?? "",
                        id: catId,
                        name: category.name ?? "Error",
                        spendings: [localSpending]
                    )
                    
                    tempCategories.updateValue(updatedCategory, forKey: catId)
                }
            }
        }
        
        self.categories = tempCategories.map { $0.value }
    }
}

struct SpendingListData {
    let entity: SpendingEntity
    let date: String
    
    init(entity: SpendingEntity) {
        var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            return formatter
        }
        
        self.entity = entity
        self.date = dateFormatter.string(from: entity.wrappedDate)
    }
}
