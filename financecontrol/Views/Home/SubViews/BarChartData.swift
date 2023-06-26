//
//  BarChartData.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/26.
//

import SwiftUI

struct BarChartData {
    enum BarChartDataError: Error {
    case noDateProvided
    }
    
    var data: [SpendingEntity]
    
    /// Getting spendings for last 7 days
    /// - Returns: Array of SpendingEntity for last 7 days
    func getData() -> [Date:Double] {
        var array: [SpendingEntity] = []
        var result: [Date:Double] = [:]
        
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "M, y"
        dateFormatter.locale = Locale(identifier: "en") // Change to actual supported language locale
        
        for entity in data {
            if entity.wrappedDate > Date.now.lastWeek {
                array.append(entity)
            } else {
                break
            }
        }
        
        for entity in array {
            let formattedDate = dateFormatForBar(entity.wrappedDate)
            let previousValue = result[formattedDate] ?? 0
            result.updateValue(previousValue + entity.amountUSD, forKey: formattedDate)
        }
        return result
    }
    
    func sortData(_ readyForChart: Bool) -> [Dictionary<Date, Double>.Element] {
        let screenHeight = UIScreen.main.bounds.height
        
        let data = getData()
        var sortedData: [Date:Double] = [:]
        
        var previousDay = dateFormatForBar(Date.now)
        
        var index = 0
        
        let biggest = data.sorted(by: { $0.value > $1.value }).first?.value ?? 0.0
        
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
    
    func dataCount(_ data: [Double]) {
        var result: [(key: Int, value: Double)] = []
        let dataEnum = data.enumerated()
        var resultSum: Double = 0
        
        let biggest = dataEnum.sorted(by: { $0.element > $1.element }).first
        
        for number in dataEnum {
            let value = number.element*100/biggest!.element
            let key = number.offset
            result.append((key: key, value: value))
            resultSum += value
        }
        
        print(result, resultSum, biggest ?? "Error")
    }
}
