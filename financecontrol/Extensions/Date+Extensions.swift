//
//  DateExtension.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/10.
//

import Foundation

extension Date {
    static let firstAvailableDate: Date = Date(timeIntervalSinceReferenceDate: 599_529_600) // 2020/01/01, 0:00 GMT
    
    var previousDay: Date {
        guard let date = Calendar.current.date(byAdding: .day, value: -1, to: self) else {
            return self
        }
        return date
    }
    
    func getFirstDayOfMonth(_ value: Int = 0) -> Date {
        guard let date = Calendar.current.date(byAdding: .month, value: value, to: self) else {
            return self
        }
        
        var components: DateComponents = Calendar.current.dateComponents([.month, .year, .era], from: date)
        components.calendar = Calendar.current
        
        guard let newDate = components.date else {
            return self
        }
        
        return newDate
    }
    
    static var weekAgo: Self {
        let date = Calendar.current.startOfDay(for: Date())
        return Calendar.current.date(byAdding: .day, value: -7, to: date) ?? Date()
    }
}
