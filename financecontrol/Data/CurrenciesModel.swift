//
//  CurrenciesModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/07.
//

import Foundation
import CoreData

extension CoreDataViewModel {
    
    func fetchCurrencies() {
        
        let request = CurrencyEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            savedCurrencies = try context.fetch(request)
        } catch let error {
            print("Error fetching currencies: \(error)")
        }
    }
    
    func addCurrency(name: String, tag: String, isFavorite: Bool = false) {
        
        if let description = NSEntityDescription.entity(forEntityName: "CurrencyEntity", in: context) {
            
            let newCurrency = CurrencyEntity(entity: description, insertInto: context)
            
            newCurrency.name = name
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
