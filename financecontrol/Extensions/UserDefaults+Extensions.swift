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
        return self.dictionary(forKey: UDKey.rates.rawValue) as? [String:Double]
    }
    
    func getUnwrapedRates() -> [String:Double] {
        return self.getRates() ?? Rates.fallback.rates
    }
    
    func getRatesUpdateTimestamp() -> Date? {
        guard let timestampString = self.string(forKey: UDKey.updateTime.rawValue) else {
            return nil
        }
        
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let newDateFormatter: DateFormatter = .forRatesTimestamp
        
        guard let result = (isoDateFormatter.date(from: timestampString) ?? newDateFormatter.date(from: timestampString)) else {
            return nil
        }
        
        return result
    }
}

// MARK: Currencies
extension UserDefaults {
    func getCurrencies() -> [Currency] {
        guard let value = self.array(forKey: UDKey.savedCurrencies.rawValue) as? [String] else {
            return []
        }
        
        return value.map { Currency(code: $0) }
    }
    
    func getRawCurrencies() -> [String] {
        guard let value = self.value(forKey: UDKey.savedCurrencies.rawValue) as? [String] else {
            return []
        }
        
        return value
    }
    
    func addCurrency(_ currency: Currency) {
        var value = self.array(forKey: UDKey.savedCurrencies.rawValue) as? [String] ?? []
        
        guard !value.contains(currency.code) else {
            return
        }
        
        value.append(currency.code)
        
        self.set(value, forKey: UDKey.savedCurrencies.rawValue)
    }
    
    func addCurrency(_ currencyCode: String) {
        guard Locale.customCommonISOCurrencyCodes.contains(currencyCode) else {
            return
        }
        
        var value = self.array(forKey: UDKey.savedCurrencies.rawValue) as? [String] ?? []
        
        guard !value.contains(currencyCode) else {
            return
        }
        
        value.append(currencyCode)
        
        self.set(value, forKey: UDKey.savedCurrencies.rawValue)
    }
    
    func deleteCurrency(_ currency: Currency) {
        guard var value = self.array(forKey: UDKey.savedCurrencies.rawValue) as? [String] else {
            // TODO: Custom error
            return
        }
        
        value.removeAll { $0 == currency.code }
        
        if value.isEmpty, let code = Locale.current.currencyCode {
            value.append(code)
            UserDefaults.standard.set(code, forKey: UDKey.defaultCurrency.rawValue)
            UserDefaults.standard.set(code, forKey: UDKey.defaultSelectedCurrency.rawValue)
            
            if let defaults = UserDefaults(suiteName: Vars.groupName) {
                defaults.set(code, forKey: "defaultCurrency")
            }
        }
        
        self.set(value, forKey: UDKey.savedCurrencies.rawValue)
    }
    
    static func defaultCurrency() -> String {
        return self.standard.string(forKey: UDKey.defaultCurrency.rawValue) ?? Locale.current.currencyCode ?? "USD"
    }
}

extension UserDefaults {
    func addToFetchQueue(_ spendingID: UUID) {
        var existingData = self.array(forKey: UDKey.ratesFetchQueue.rawValue) as? [String] ?? []
        
        if !existingData.contains(spendingID.uuidString) {
            existingData.append(spendingID.uuidString)
        }
        
        self.set(existingData, forKey: UDKey.ratesFetchQueue.rawValue)
    }
    
    func addToFetchQueue(_ spendingIDs: [UUID]) {
        var set = Set(self.array(forKey: UDKey.ratesFetchQueue.rawValue) as? [String] ?? [])
        set.formUnion(spendingIDs.map({ $0.uuidString }))
        self.set(Array(set), forKey: UDKey.ratesFetchQueue.rawValue)
    }
    
    func getFetchQueue() -> [UUID] {
        var result = [UUID]()
        let existingData = self.array(forKey: UDKey.ratesFetchQueue.rawValue) as? [String] ?? []
        result.reserveCapacity(existingData.count)
        
        for element in existingData {
            if let converted = UUID(uuidString: element) {
                result.append(converted)
            }
        }
        
        return result
    }
    
    func removeFromFetchQueue(_ spendingID: UUID) {
        let spendingIDString = spendingID.uuidString
        var result = self.array(forKey: UDKey.ratesFetchQueue.rawValue) as? [String] ?? []
        
        result.removeAll { id in
            id == spendingIDString
        }
        
        self.set(result, forKey: UDKey.ratesFetchQueue.rawValue)
    }
    
    func clearFetchQueue() {
        self.removeObject(forKey: UDKey.ratesFetchQueue.rawValue)
    }
}
