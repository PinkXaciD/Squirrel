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
    }
    
    init(date: Date, id: Int, showOther: Bool, spendings: [TSSpendingEntity], categoryName: String? = nil) {
        let firstDate = date.getFirstDayOfMonth()
//        let secondDate = date.getFirstDayOfMonth(1)
        
        var categories: [TSCategoryEntity] = []
        
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
                func getCategory() -> CategoryEntity? {
                    let request = CategoryEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %@", key as CVarArg)
                    
                    do {
                        return try DataManager.shared.context.fetch(request).first
                    } catch {
                        return nil
                    }
                }
                
                guard var category = getCategory()?.safeObject() else { return nil }
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
    }
    
    init(firstDate: Date, secondDate: Date, cdm: CoreDataModel, categories filterCategories: [UUID], withReturns: Bool? = nil, currencies: [String]) {
        var categories: [TSCategoryEntity] = []
        
        let spendings = cdm.savedSpendings.filter { spending in
            guard spending.wrappedDate >= firstDate && spending.wrappedDate < secondDate else {
                return false
            }
            
            var result = true
            
            if let catId = spending.category?.id, !filterCategories.isEmpty {
                result = filterCategories.contains(catId)
            }
            
            if let withReturns, result {
                result = withReturns == !spending.returnsArr.isEmpty
            }
            
            if !currencies.isEmpty, result {
                result = currencies.contains(spending.wrappedCurrency)
            }
            
            return result
        }
        .map { $0.safeObject() }
        
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
    
    init(firstDate: Date, secondDate: Date, spendings: [SpendingEntity], categories filterCategories: [UUID], withReturns: Bool? = nil, currencies: [String]) {
        var categories: [TSCategoryEntity] = []
        
        let spendings = spendings.filter { spending in
            guard spending.wrappedDate >= firstDate && spending.wrappedDate < secondDate else {
                return false
            }
            
            var result = true
            
            if let catId = spending.category?.id, !filterCategories.isEmpty {
                result = filterCategories.contains(catId)
            }
            
            if let withReturns, result {
                result = withReturns == !spending.returnsArr.isEmpty
            }
            
            if !currencies.isEmpty, result {
                result = currencies.contains(spending.wrappedCurrency)
            }
            
            return result
        }
        .map { $0.safeObject() }
        
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
            func getCategory() -> CategoryEntity? {
                let request = CategoryEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", key as CVarArg)
                
                do {
                    return try DataManager.shared.context.fetch(request).first
                } catch {
                    return nil
                }
            }
            
            guard var category = getCategory()?.safeObject() else { continue }
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
