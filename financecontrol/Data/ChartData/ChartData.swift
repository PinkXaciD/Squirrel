//
//  ChartData.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/02/08.
//

import Foundation

struct ChartData: Identifiable {
    let id: Int
    let date: Date
    var categories: [TSCategoryEntity]
    
    init(date: Date, id: Int, withOther: Bool, cdm: CoreDataModel, categoryName: String? = nil) {
        let firstDate = date.getFirstDayOfMonth()
        let secondDate = date.getFirstDayOfMonth(1)
        
        var categories: [TSCategoryEntity] = []
        
        let spendings = cdm.savedSpendings.filter { spending in
            spending.wrappedDate >= firstDate && spending.wrappedDate < secondDate && (categoryName != nil ? spending.categoryName == categoryName : true)
        }
        .map { $0.safeObject() }
        
        if categoryName != nil {
            let unknown = NSLocalizedString("Unknown", comment: "Unknown place")
            var dict: [String:[TSSpendingEntity]] {
                var result = [String:[TSSpendingEntity]]()
                
                for spending in spendings {
                    guard let place = spending.place else { continue }
                    let placeName = place.isEmpty ? unknown : place
                    var values = result[placeName] ?? []
                    values.append(spending)
                    result.updateValue(values, forKey: placeName)
                }
                
                return result
            }
            
            let colors: [String] = Array(CustomColor.nordAurora.keys).sorted(by: <)
            var colorIndex: Int = 0
            
            for key in dict.keys {
                var category = TSCategoryEntity(color: key == unknown ? "secondary" : colors[colorIndex], id: .init(), isShadowed: false, isFavorite: false, name: key)
                category.spendings = Set(dict[key] ?? []) as NSSet
                categories.append(category)
                
                if key != unknown {
                    if colorIndex < colors.count - 1 {
                        colorIndex += 1
                    } else {
                        colorIndex = 0
                    }
                }
            }
        } else {
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
        
        self.categories = categories
        self.date = firstDate
        self.id = 0
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
