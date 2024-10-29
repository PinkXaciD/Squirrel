//
//  BarChartData.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/26.
//

import SwiftUI

struct BarChartData {
    @AppStorage(UDKey.defaultCurrency.rawValue)
    var defaultCurrency: String = Locale.current.currencyCode ?? "USD"
    
    var data: [SpendingEntity]
    var usdRates: [String:Double]
    
    /// Getting spendings for last 7 days
    /// - Returns: Array of SpendingEntity for last 7 days
    func getData() -> [Date:Double] {
        var array: [SpendingEntity] = []
        var result: [Date:Double] = [:]
        
        var dateNow: Date {
            let components: DateComponents = Calendar.current.dateComponents([.day, .month, .year, .era], from: .now)
            return Calendar.current.date(from: components) ?? .now
        }
        
        for entity in data {
            if entity.wrappedDate > (Calendar.current.date(byAdding: .day, value: -6, to: dateNow) ?? .distantFuture) {
                array.append(entity)
            } else {
                break
            }
        }
        
        var index: Int = 0
        
        while index < 7 {
            let date: Date = Calendar.current.date(byAdding: .day, value: -index, to: dateNow) ?? .distantPast
            
            let valueArr: [Double] = array.filter { entity in
                Calendar.current.isDate(entity.wrappedDate, equalTo: date, toGranularity: .day)
            }
            .map { entity in
                if entity.wrappedCurrency == defaultCurrency {
                    return entity.amountWithReturns
                } else {
                    return entity.amountUSDWithReturns * (usdRates[defaultCurrency] ?? 1)
                }
            }
            
            let value: Double = valueArr.reduce(0, +)
            
            result.updateValue(value, forKey: date)
            index += 1
        }
        
        return result
    }
    
    func sortData(_ readyForChart: Bool) -> [Dictionary<Date, Double>.Element] {
        let screenHeight = UIScreen.main.bounds.height
        
        let data = getData()
        var sortedData: [Date:Double] = [:]
        
        let components = Calendar.current.dateComponents([.era, .year, .month, .day], from: .now)
        var previousDay = Calendar.current.date(from: components) ?? .distantPast
        
        var index = 0
        
        let biggest: Double = data.values.max() ?? 1
        
        while index < 7 {
            sortedData.updateValue(data[previousDay] ?? 0, forKey: previousDay)
            previousDay = previousDay.previousDay
            index += 1
        }
        
        if !readyForChart {
            return sortedData.sorted(by: { $0.key > $1.key })
        }
        
        for element in sortedData {
            sortedData.updateValue(element.value*(screenHeight/5)/biggest, forKey: element.key)
        }
        
        return sortedData.sorted(by: { $0.key > $1.key })
    }
}

struct NewBarChartData: Equatable {
    let sum: Double
    let bars: [Date:Double]
    
    init(sum: Double, bars: [Date:Double]) {
        self.sum = sum
        self.bars = bars
    }
    
    init() {
        self.sum = 0
        
        var bars: [Date:Double] = [:]
        for number in 0..<7 {
            bars.updateValue(0, forKey: Calendar.current.date(byAdding: .day, value: -number, to: Calendar.current.startOfDay(for: Date())) ?? Date())
        }
        
        self.bars = bars
    }
    
    var max: Double {
        return bars.values.max() ?? 0
    }
}
