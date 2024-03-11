//
//  DateExtension.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/10.
//

import Foundation

extension Date {
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
}
