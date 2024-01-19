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
        let localeDefaultCurrency: String = Locale.current.currencyCode ?? "USD"
        
        do {
            savedCurrencies = try context.fetch(request)
            if savedCurrencies.isEmpty {
                addCurrency(tag: localeDefaultCurrency, isFavorite: true)
                UserDefaults.standard.set(localeDefaultCurrency, forKey: "defaultCurrency")
                UserDefaults(suiteName: Vars.groupName)?.set(localeDefaultCurrency, forKey: "defaultCurrency")
            }
        } catch let error {
            ErrorType(error: error).publish()
        }
    }
    
    func addCurrency(tag: String, isFavorite: Bool = false) {
        
        if let description = NSEntityDescription.entity(forEntityName: "CurrencyEntity", in: context) {
            
            let newCurrency = CurrencyEntity(entity: description, insertInto: context)
            
            newCurrency.tag = tag
            newCurrency.isFavorite = isFavorite
            
            manager.save()
            fetchCurrencies()
        }
    }
    
    func changeFavoriteStateOfCurrency(_ currency: CurrencyEntity) {
        
        currency.isFavorite.toggle()
        manager.save()
        fetchCurrencies()
    }
    
    func deleteCurrency(_ currency: CurrencyEntity) {
        
        context.delete(currency)
        manager.save()
        fetchCurrencies()
    }
}
