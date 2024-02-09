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
    var categories: [CategoryEntityLocal]
    
    init(date: Date, id: Int, withOther: Bool, cdm: CoreDataModel, categoryName: String? = nil) {
        let firstDate = date.getFirstDayOfMonth()
        let secondDate = date.getFirstDayOfMonth(1)
        
        self.date = firstDate
        self.id = id
        
        var tempCategories: [String:CategoryEntityLocal] = [:]
        let dateRange = firstDate..<secondDate
        
        let spendings = cdm.savedSpendings.filter {
            if let categoryName = categoryName {
                return dateRange.contains($0.wrappedDate) && $0.categoryName == categoryName
            } else {
                return dateRange.contains($0.wrappedDate)
            }
        }
        
        if categoryName != nil {
            let colors: [String] = Array(CustomColor.nordAurora.keys).sorted(by: <)
            var colorIndex: Int = 0
            
            for spending in spendings {
                var place: String {
                    guard let place = spending.place, !place.isEmpty else {
                        return NSLocalizedString("Unknown", comment: "")
                    }
                    
                    return place
                }
                
                if let existing = tempCategories[place] {
                    let localSpending = SpendingEntityLocal(
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
                    
                    var catSpendings: [SpendingEntityLocal] = existing.spendings
                    catSpendings.append(localSpending)
                    
                    let updatedCategory = CategoryEntityLocal(
                        color: existing.color,
                        id: existing.id,
                        name: existing.name,
                        spendings: catSpendings
                    )
                    
                    tempCategories.updateValue(updatedCategory, forKey: place)
                    
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
                        categoryId: spending.wrappedId
                    )
                    
                    let updatedCategory = CategoryEntityLocal(
                        color: place == NSLocalizedString("Unknown", comment: "") ? "secondary" : colors[colorIndex],
                        id: spending.wrappedId,
                        name: place,
                        spendings: [localSpending]
                    )
                    
                    if colorIndex < colors.count - 1 {
                        colorIndex += 1
                    } else {
                        colorIndex = 0
                    }
                    
                    tempCategories.updateValue(updatedCategory, forKey: place)
                }
            }
        } else {
            for spending in spendings {
                guard
                    let category = spending.category,
                    let catId = category.id,
                    let categoryName = category.name,
                    let categoryColor = category.color
                else {
                    continue
                }
                        
                if let existing = tempCategories[catId.uuidString] {
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
                    
                    tempCategories.updateValue(updatedCategory, forKey: catId.uuidString)
                    
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
                    
                    tempCategories.updateValue(updatedCategory, forKey: catId.uuidString)
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
