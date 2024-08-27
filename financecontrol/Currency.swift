//
//  Currency.swift
//  Squirrel
//
//  Created by PinkXaciD on R 5/09/07.
//

import Foundation

struct Currency: Hashable, Comparable, Identifiable {
    static func < (lhs: Currency, rhs: Currency) -> Bool {
        return (lhs.name ?? lhs.code) < (rhs.name ?? rhs.code)
    }
    
    let code: String
    
    var id: String {
        self.code
    }
    
    var name: String? {
        Locale.current.localizedString(forCurrencyCode: code)
    }
    
    var fractionDigits: Int {
        Locale.current.currencyFractionDigits(currencyCode: self.code)
    }
    
    static func getAll() -> [Currency] {
        return Locale.customCommonISOCurrencyCodes.map { .init(code: $0) }
    }
    
    static var localeCurrency: Currency? {
        if let code = Locale.current.currencyCode {
            return Currency(code: code)
        }
        
        return nil
    }
}

extension Locale {
    func getCurrency() -> Squirrel.Currency? {
        let currencyCode = {
            if #available(iOS 16, *) {
                return self.currency?.identifier
            } else {
                return  self.currencyCode
            }
        }()
        
        if let currencyCode {
            return .init(code: currencyCode)
        }
        
        return nil
    }
}
