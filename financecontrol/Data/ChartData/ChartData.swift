//
//  ChartData.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/02/08.
//

import Foundation

struct ChartData: Equatable {
    let sum: Double
    let id: Int
    let date: Date
    
    let categories: [ChartCategory]
    let otherCategory: ChartCategory?
    let otherCategories: [ChartCategory]
    let categoriesDict: [UUID:ChartCategory]
    
    // MARK: Main init
    init(id: Int, date: Date, spendings: [TSSpendingEntity]) {
        var categoriesDict = [UUID:ChartCategory]()
        var sum: Double = 0
        let defaultCurrency = UserDefaults.defaultCurrency()
        let defaultRate = UserDefaults.standard.getUnwrapedRates()[defaultCurrency] ?? 1
        let colors: [String] = Array(CustomColor.nordAurora.keys).sorted(by: <)
        var colorIndex: Int = 0
        
        for spending in spendings {
            guard
                let categoryID = spending.categoryID,
                let categoryColor = spending.categoryColor
            else {
                continue
            }
            
            let amount = {
                if spending.wrappedCurrency == defaultCurrency {
                    return spending.amountWithReturns
                }
                
                return spending.amountUSDWithReturns * defaultRate
            }()
            
            sum += amount
            var category = categoriesDict[categoryID] ?? .init(name: spending.categoryName, color: categoryColor, id: categoryID)
            let spendingPlace = {
                if let place = spending.place, !place.isEmpty {
                    return place
                }
                
                return "unknown-place-localized"
            }()
            category.addExpense(amount: amount, place: spendingPlace)
            categoriesDict.updateValue(category, forKey: categoryID)
            
            if spending.place != nil {
                if colorIndex < colors.count - 1 {
                    colorIndex += 1
                } else {
                    colorIndex = 0
                }
            }
        }
        
        self.sum = sum
        self.id = id
        self.date = date
        
        let sortedCategories: [ChartCategory] = categoriesDict.values.sorted(by: >)
        
        if sortedCategories.count > 5 {
            let prefix = Array(sortedCategories.prefix(5))
            let otherCategories = Array(sortedCategories[5...])
            let otherCategory: ChartCategory = {
                var sum: Double = 0
                for category in otherCategories {
                    sum += category.sum
                }
                return .init(
                    name: NSLocalizedString("category-name-other", comment: "\"Other\" category"),
                    color: "secondary",
                    id: .init(),
                    sum: sum,
                    isOther: true
                )
            }()
            self.categories = prefix
            self.otherCategory = otherCategory
            self.otherCategories = otherCategories
            self.categoriesDict = categoriesDict
            return
        }
        
        self.categories = sortedCategories
        self.otherCategory = nil
        self.otherCategories = []
        self.categoriesDict = categoriesDict
    }
    
    // MARK: Empty init
    private init(id: Int = 0) {
        self.id = id
        self.date = Date()
        self.sum = 0
        self.categories = []
        self.otherCategory = nil
        self.otherCategories = []
        self.categoriesDict = [:]
    }
    
    static func getEmpty(id: Int = 0) -> Self {
        return ChartData(id: id)
    }
}

// MARK: ChartCategory
struct ChartCategory: Identifiable, SuitableForChart {
    var sum: Double
    let name: String
    let color: String
    let id: UUID
    let isPlace: Bool = false
    let isOther: Bool
    
    private var placesDict: [String:ChartPlace]
    
    var places: [ChartPlace] {
        return Array(placesDict.values).sorted(by: >)
    }
    
    init(name: String, color: String, id: UUID, sum: Double = 0, isOther: Bool = false) {
        self.sum = sum
        self.name = name
        self.color = color
        self.id = id
        self.placesDict = .init()
        self.isOther = isOther
    }
    
    mutating private func increaseSum(_ number: Double) {
        self.sum += number
    }
    
    mutating func addExpense(amount: Double, place placeName: String) {
        let colors: [String] = Array(CustomColor.nordAurora.keys).sorted(by: <)
        
        func getColorIndex() -> Int {
            var colorIndex: Int = placesDict.count
            while colorIndex >= colors.count {
                colorIndex -= colors.count
            }
            return colorIndex
        }
        
        let color = placeName == "unknown-place-localized" ? "secondary" : colors[getColorIndex()]
        
        var place = placesDict[placeName] ?? .init(name: placeName == "unknown-place-localized" ? NSLocalizedString(placeName, comment: "Unknown place") : placeName, color: color)
        self.increaseSum(amount)
        place.increaseSum(amount)
        placesDict.updateValue(place, forKey: placeName)
    }
}

extension ChartCategory: Comparable {
    static func < (lhs: ChartCategory, rhs: ChartCategory) -> Bool {
        if lhs.sum == rhs.sum {
            return lhs.name < rhs.name
        }
        
        return lhs.sum < rhs.sum
    }
}

// MARK: ChartPlace
struct ChartPlace: Identifiable, SuitableForChart {
    init(name: String, sum: Double = 0, color: String = "", isOther: Bool = false) {
        self.sum = sum
        self.name = name
        self.color = color
        self.id = .init()
        self.isOther = isOther
    }
    
    var sum: Double
    let name: String
    let color: String
    let id: UUID
    let isPlace: Bool = true
    let isOther: Bool
    
    mutating func increaseSum(_ number: Double) {
        self.sum += number
    }
}

extension ChartPlace: Comparable {
    static func < (lhs: ChartPlace, rhs: ChartPlace) -> Bool {
        if lhs.sum == rhs.sum {
            return lhs.name < rhs.name
        }
        
        return lhs.sum < rhs.sum
    }
}

protocol SuitableForChart: Identifiable {
    var sum: Double { get }
    var name: String { get }
    var color: String { get }
    var id: UUID { get }
    var isPlace: Bool { get }
    var isOther: Bool { get }
}
