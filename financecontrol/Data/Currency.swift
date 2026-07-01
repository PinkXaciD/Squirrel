//
//  Currency.swift
//  Squirrel
//
//  Created by PinkXaciD on 2023/09/07.
//

import Foundation

struct Currency: Hashable {
    let code: String
    
    var name: String? {
        Locale.autoupdatingCurrent.localizedString(forCurrencyCode: code)?.capitalized(with: .autoupdatingCurrent)
    }
    
    var fractionDigits: Int {
        Locale.autoupdatingCurrent.currencyFractionDigits(currencyCode: self.code)
    }
    
    static func getAll() -> [Currency] {
        return Locale.customCommonISOCurrencyCodes.map { .init(code: $0) }
    }
    
    static var localeCurrency: Currency? {
        if let code = Locale.autoupdatingCurrent.currencyCode {
            return Currency(code: code)
        }
        
        return nil
    }
}

extension Currency: Identifiable {
    var id: String {
        self.code
    }
}

extension Currency: Comparable {
    static func < (lhs: Currency, rhs: Currency) -> Bool {
        return (lhs.name ?? lhs.code) < (rhs.name ?? rhs.code)
    }
}

extension Locale {
    func getCurrency() -> Squirrel.Currency? {
        let currencyCode = {
            if #available(iOS 16, *) {
                return self.currency?.identifier
            } else {
                return self.currencyCode
            }
        }()
        
        if let currencyCode {
            return .init(code: currencyCode)
        }
        
        return nil
    }
}
