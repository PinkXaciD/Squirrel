//
//  StringExtensions.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/23.
//

import Foundation

extension String {
    var currencyFormat: String {
        let currencyFormatter: NumberFormatter = {
            let currencyFormatter = NumberFormatter()
            currencyFormatter.maximumFractionDigits = 2
            currencyFormatter.minimumFractionDigits = 2
            return currencyFormatter
        } ()
        
        return currencyFormatter.string(from: (Double(self) ?? 0) as NSNumber) ?? "Error"
    }
}
