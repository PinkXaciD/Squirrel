//
//  DateExtension.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/10.
//

import Foundation

extension Date {
    var lastWeek: Date {
        return Calendar.current.date(byAdding: .day, value: -7, to: self)!
    }
    
    var previousDay: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
    
    var nextDay: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }
    
    var pastHour: Date {
        return Calendar.current.date(byAdding: .hour, value: -1, to: self)!
    }
}
