//
//  UserDefaultsExtensions.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/03/29.
//

import Foundation

// MARK: Rates
extension UserDefaults {
    func getRates() -> [String:Double]? {
        return self.dictionary(forKey: UDKeys.rates.rawValue) as? [String:Double]
    }
    
    func getUnwrapedRates() -> [String:Double] {
        return self.getRates() ?? Rates.fallback.rates
    }
}

// MARK: Currencies
extension UserDefaults {
    func getCurrencies() -> [Currency] {
        guard let value = self.array(forKey: UDKeys.savedCurrencies.rawValue) as? [String] else {
            return []
        }
        
        return value.map { Currency(code: $0) }
    }
    
    func getRawCurrencies() -> [String] {
        guard let value = self.value(forKey: UDKeys.savedCurrencies.rawValue) as? [String] else {
            return []
        }
        
        return value
    }
    
    func addCurrency(_ currency: Currency) {
        var value = self.array(forKey: UDKeys.savedCurrencies.rawValue) as? [String] ?? []
        
        guard !value.contains(currency.code) else {
            return
        }
        
        value.append(currency.code)
        
        self.set(value, forKey: UDKeys.savedCurrencies.rawValue)
    }
    
    func addCurrency(_ currencyCode: String) {
        guard Locale.customCommonISOCurrencyCodes.contains(currencyCode) else {
            return
        }
        
        var value = self.array(forKey: UDKeys.savedCurrencies.rawValue) as? [String] ?? []
        
        guard !value.contains(currencyCode) else {
            return
        }
        
        value.append(currencyCode)
        
        self.set(value, forKey: UDKeys.savedCurrencies.rawValue)
    }
    
    func deleteCurrency(_ currency: Currency) {
        guard var value = self.array(forKey: UDKeys.savedCurrencies.rawValue) as? [String] else {
            // TODO: Custom error
            return
        }
        
        value.removeAll { $0 == currency.code }
        
        if value.isEmpty, let code = Locale.current.currencyCode {
            value.append(code)
            UserDefaults.standard.set(code, forKey: UDKeys.defaultCurrency.rawValue)
            
            if let defaults = UserDefaults(suiteName: Vars.groupName) {
                defaults.set(code, forKey: "defaultCurrency")
            }
        }
        
        self.set(value, forKey: UDKeys.savedCurrencies.rawValue)
    }
    
    static func defaultCurrency() -> String {
        return self.standard.string(forKey: UDKeys.defaultCurrency.rawValue) ?? Locale.current.currencyCode ?? "USD"
    }
}
