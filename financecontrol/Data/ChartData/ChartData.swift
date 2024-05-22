//
//  ChartData.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/02/08.
//

import Foundation

struct ChartData: Identifiable, Equatable {
    let id: Int
    let date: Date
    var categories: [TSCategoryEntity]
    
    init(date: Date, id: Int, showOther: Bool, cdm: CoreDataModel, categoryName: String? = nil) {
        let firstDate = date.getFirstDayOfMonth()
        let secondDate = date.getFirstDayOfMonth(1)
        
        var categories: [TSCategoryEntity] = []
        
        let spendings = cdm.savedSpendings.filter { spending in
            spending.wrappedDate >= firstDate && spending.wrappedDate < secondDate && (categoryName != nil ? spending.categoryName == categoryName : true)
        }
        .map { $0.safeObject() }
        
        if categoryName != nil {
            let unknown = NSLocalizedString("unknown-place-localized", comment: "Unknown place")
            
            let dict: [String:[TSSpendingEntity]] = Dictionary(grouping: spendings) { spending in
                guard let place = spending.place, !place.isEmpty else {
                    return unknown
                }
                
                return place
            }
            
            let colors: [String] = Array(CustomColor.nordAurora.keys).sorted(by: <)
            var colorIndex: Int = 0
            
            categories = dict.map { (key, value) in
                var category = TSCategoryEntity(color: key == unknown ? "secondary" : colors[colorIndex], id: .init(), isShadowed: false, isFavorite: false, name: key)
                category.spendings = Set(value) as NSSet
                
                if key != unknown {
                    if colorIndex < colors.count - 1 {
                        colorIndex += 1
                    } else {
                        colorIndex = 0
                    }
                }
                
                return category
            }
        } else {
            let unknownID = UUID()
            
            let dict = Dictionary(grouping: spendings) { spending in
                guard let catId = spending.categoryID else {
                    return unknownID
                }
                
                return catId
            }
            
            categories = dict.map { (key, value) in
                guard var category = cdm.findCategory(key)?.safeObject() else { return nil }
                category.spendings = Set(value) as NSSet
                return category
            }
            .compactMap { $0 }
        }
        
        if showOther {
            let sortedCategories = categories.sorted(by: >)
            let localCategories = sortedCategories
            categories = Array(sortedCategories.prefix(5))
            if localCategories.count > 5 {
                guard let set = localCategories[5...].map({ $0.spendings?.allObjects }).compactMap({ $0 }).flatMap({ $0 }) as? [TSSpendingEntity] else {
                    self.categories = categories
                    self.date = firstDate
                    self.id = id
                    return
                }
                let spendings = Set(set) as NSSet
                let otherName = NSLocalizedString("category-name-other", comment: "\"Other\" category")
                let otherCategory = TSCategoryEntity(color: "secondary", id: .init(), isShadowed: false, isFavorite: false, name: otherName, spendings: spendings)
                categories.append(otherCategory)
            }
        } else {
            categories.sort(by: >)
        }
        
        self.categories = categories
        self.date = firstDate
        self.id = id
        
//        let firstDate = date.getFirstDayOfMonth()
//        let secondDate = date.getFirstDayOfMonth(1)
//        
//        self.date = firstDate
//        self.id = id
//        
//        var tempCategories: [String:CategoryEntityLocal] = [:]
//        let dateRange = firstDate..<secondDate
//        
//        let spendings = cdm.savedSpendings.filter {
//            if let categoryName = categoryName {
//                return dateRange.contains($0.wrappedDate) && $0.categoryName == categoryName
//            } else {
//                return dateRange.contains($0.wrappedDate)
//            }
//        }
//        
//        if categoryName != nil {
//            let colors: [String] = Array(CustomColor.nordAurora.keys).sorted(by: <)
//            var colorIndex: Int = 0
//            
//            for spending in spendings {
//                var place: String {
//                    guard let place = spending.place, !place.isEmpty else {
//                        return NSLocalizedString("Unknown", comment: "")
//                    }
//                    
//                    return place
//                }
//                
//                var amountWithReturns: Double {
//                    let defaultCurrency: String = UserDefaults.standard.string(forKey: "defaultCurrency") ?? Locale.current.currencyCode ?? "USD"
//                    if spending.currency == defaultCurrency {
//                        return spending.amount
//                    } else {
//                        guard
//                            let fetchedRates = UserDefaults.standard.dictionary(forKey: "rates") as? [String:Double],
//                            let defaultCurrencyRate = fetchedRates[defaultCurrency]
//                        else {
//                            return 0
//                        }
//                        
//                        return spending.amountUSDWithReturns * defaultCurrencyRate
//                    }
//                }
//                
//                let localSpending = SpendingEntityLocal(
//                    amountUSD: spending.amountUSD,
//                    amount: spending.amount,
//                    amountWithReturns: spending.amountWithReturns,
//                    amountUSDWithReturns: spending.amountUSDWithReturns,
//                    comment: spending.comment ?? "",
//                    currency: spending.wrappedCurrency,
//                    date: spending.wrappedDate,
//                    place: spending.place ?? "",
//                    categoryId: spending.wrappedId
//                )
//                
//                if let existing = tempCategories[place] {
//                    var catSpendings: [SpendingEntityLocal] = existing.spendings
//                    catSpendings.append(localSpending)
//                    
//                    let updatedCategory = CategoryEntityLocal(
//                        color: existing.color,
//                        id: existing.id,
//                        name: existing.name,
//                        spendings: catSpendings, 
//                        sumUSDWithReturns: existing.sumUSDWithReturns + localSpending.amountUSDWithReturns, 
//                        sumWithReturns: existing.sumWithReturns + amountWithReturns
//                    )
//                    
//                    tempCategories.updateValue(updatedCategory, forKey: place)
//                } else {
//                    let updatedCategory = CategoryEntityLocal(
//                        color: place == NSLocalizedString("Unknown", comment: "") ? "secondary" : colors[colorIndex],
//                        id: spending.wrappedId,
//                        name: place,
//                        spendings: [localSpending], 
//                        sumUSDWithReturns: localSpending.amountUSDWithReturns,
//                        sumWithReturns: amountWithReturns
//                    )
//                    
//                    if colorIndex < colors.count - 1 {
//                        colorIndex += 1
//                    } else {
//                        colorIndex = 0
//                    }
//                    
//                    tempCategories.updateValue(updatedCategory, forKey: place)
//                }
//            }
//        } else {
//            for spending in spendings {
//                guard
//                    let category = spending.category,
//                    let catId = category.id,
//                    let categoryName = category.name,
//                    let categoryColor = category.color
//                else {
//                    continue
//                }
//                
//                var amountWithReturns: Double {
//                    let defaultCurrency: String = UserDefaults.standard.string(forKey: "defaultCurrency") ?? Locale.current.currencyCode ?? "USD"
//                    if spending.currency == defaultCurrency {
//                        return spending.amount
//                    } else {
//                        guard
//                            let fetchedRates = UserDefaults.standard.dictionary(forKey: "rates") as? [String:Double],
//                            let defaultCurrencyRate = fetchedRates[defaultCurrency]
//                        else {
//                            return 0
//                        }
//                        
//                        return spending.amountUSDWithReturns * defaultCurrencyRate
//                    }
//                }
//                
//                let localSpending = SpendingEntityLocal(
//                    amountUSD: spending.amountUSD,
//                    amount: spending.amount,
//                    amountWithReturns: spending.amountWithReturns,
//                    amountUSDWithReturns: spending.amountUSDWithReturns,
//                    comment: spending.comment ?? "",
//                    currency: spending.wrappedCurrency,
//                    date: spending.wrappedDate,
//                    place: spending.place ?? "",
//                    categoryId: catId
//                )
//                        
//                if let existing = tempCategories[catId.uuidString] {
//                    var catSpendings: [SpendingEntityLocal] = existing.spendings
//                    catSpendings.append(localSpending)
//                    let updatedCategory = CategoryEntityLocal(
//                        color: existing.color,
//                        id: existing.id,
//                        name: existing.name,
//                        spendings: catSpendings, 
//                        sumUSDWithReturns: existing.sumUSDWithReturns + localSpending.amountUSDWithReturns, 
//                        sumWithReturns: existing.sumWithReturns + amountWithReturns
//                    )
//                    
//                    tempCategories.updateValue(updatedCategory, forKey: catId.uuidString)
//                } else {
//                    let updatedCategory = CategoryEntityLocal(
//                        color: categoryColor,
//                        id: catId,
//                        name: categoryName,
//                        spendings: [localSpending], 
//                        sumUSDWithReturns: localSpending.amountUSDWithReturns,
//                        sumWithReturns: amountWithReturns
//                    )
//                    
//                    tempCategories.updateValue(updatedCategory, forKey: catId.uuidString)
//                }
//            }
//        }
//        self.categories = Array(tempCategories.values)
    }
    
    init(firstDate: Date, secondDate: Date, cdm: CoreDataModel, categories filterCategories: [UUID]) {
        var categories: [TSCategoryEntity] = []
        
        let spendings = cdm.savedSpendings.filter { spending in
            guard spending.wrappedDate >= firstDate && spending.wrappedDate < secondDate else {
                return false
            }
            
            if filterCategories.isEmpty {
                return true
            }
            
            guard let catId = spending.category?.id else {
                return false
            }
            
            return filterCategories.contains(catId)
        }
        .map { $0.safeObject() }
        
//        if false {
//            let unknown = NSLocalizedString("Unknown", comment: "Unknown place")
//            var dict: [String:[TSSpendingEntity]] {
//                var result = [String:[TSSpendingEntity]]()
//                
//                for spending in spendings {
//                    guard let place = spending.place else { continue }
//                    let placeName = place.isEmpty ? unknown : place
//                    var values = result[placeName] ?? []
//                    values.append(spending)
//                    result.updateValue(values, forKey: placeName)
//                }
//                
//                return result
//            }
//            
//            let colors: [String] = Array(CustomColor.nordAurora.keys).sorted(by: <)
//            var colorIndex: Int = 0
//            
//            for key in dict.keys {
//                var category = TSCategoryEntity(color: key == unknown ? "secondary" : colors[colorIndex], id: .init(), isShadowed: false, isFavorite: false, name: key)
//                category.spendings = Set(dict[key] ?? []) as NSSet
//                categories.append(category)
//                
//                if key != unknown {
//                    if colorIndex < colors.count - 1 {
//                        colorIndex += 1
//                    } else {
//                        colorIndex = 0
//                    }
//                }
//            }
//        } else {
//            var dict: [UUID:[TSSpendingEntity]] {
//                var result = [UUID:[TSSpendingEntity]]()
//                
//                for spending in spendings {
//                    guard let categoryID = spending.categoryID else { continue }
//                    var values = (result[categoryID] ?? [])
//                    values.append(spending)
//                    result.updateValue(values, forKey: categoryID)
//                }
//                
//                return result
//            }
//            
//            for key in dict.keys {
//                guard var category = cdm.findCategory(key)?.safeObject() else { continue }
//                category.spendings = Set(dict[key] ?? []) as NSSet
//                categories.append(category)
//            }
//        }
        
        var dict: [UUID:[TSSpendingEntity]] {
            var result = [UUID:[TSSpendingEntity]]()
            
            for spending in spendings {
                guard let categoryID = spending.categoryID else { continue }
                var values = (result[categoryID] ?? [])
                values.append(spending)
                result.updateValue(values, forKey: categoryID)
            }
            
            return result
        }
        
        for key in dict.keys {
            guard var category = cdm.findCategory(key)?.safeObject() else { continue }
            category.spendings = Set(dict[key] ?? []) as NSSet
            categories.append(category)
        }
        
        self.categories = categories.sorted(by: >)
        self.date = firstDate
        self.id = 0
    }
    
    init(id: Int, date: Date, categories: [TSCategoryEntity]) {
        self.id = id
        self.date = date
        self.categories = categories
    }
    
    private init() {
        self.id = 0
        self.date = Date()
        self.categories = []
    }
    
    static func getEmpty() -> ChartData {
        return ChartData()
    }
}

struct NewPieChartData: Identifiable, Equatable {
    let id: Int
    let sectors: [NewPieChartSectorData]
    
    lazy var sum: Double = {
        sectors.reduce(0, { $1.sum })
    }()
}

//[Int:[UUID:[NewPieChartSectorData]]]

struct NewPieChartSectorData: Identifiable, Equatable {
    let id: UUID
    let name: String
    let color: String
    let sum: Double
    
    func addExpense(_ sum: Double) -> NewPieChartSectorData {
        return NewPieChartSectorData(id: self.id, name: self.name, color: self.color, sum: self.sum + sum)
    }
}
