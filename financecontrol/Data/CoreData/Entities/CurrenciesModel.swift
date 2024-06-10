//
//  CurrenciesModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/07.
//

import Foundation
import CoreData

extension CoreDataModel {
    
    func fetchCurrencies() {
        let request = CurrencyEntity.fetchRequest()
        
        do {
            savedCurrencies = try context.fetch(request)
        } catch let error {
            ErrorType(error: error).publish()
        }
    }
    
    func migrateCurrenciesToDefaults() {
        if !savedCurrencies.isEmpty {
            let value = Array(Set(self.savedCurrencies.compactMap { $0.tag }))
            UserDefaults.standard.setValue(value, forKey: UDKeys.savedCurrencies.rawValue)
            
            if ((UserDefaults.standard.array(forKey: UDKeys.savedCurrencies.rawValue) as? [String]) ?? .init()) == savedCurrencies.compactMap({ $0.tag }) {
                let currencies = self.savedCurrencies
                for currency in currencies {
                    context.delete(currency)
                }
                manager.save()
                fetchCurrencies()
            }
        }
    }
    
    func deleteCurrency(_ currency: CurrencyEntity) {
        context.delete(currency)
        manager.save()
        fetchCurrencies()
    }
}

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
