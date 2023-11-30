//
//  RatesViewModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/18.
//

import Foundation
import CoreData

//MARK: Rates Structure

struct Rates: Codable {
    let timestamp: String
    let rates: [String: Double]
}

//MARK: Rates View Model

final class RatesViewModel: ViewModel {
    
    @Published var rates: [String:Double] = [:]
    
    let manager = DataManager.shared
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    init() {
        
        self.container = manager.container
        self.context = manager.context
        
        insertRates()
        
        if UserDefaults.standard.bool(forKey: "updateRates") {
            Task {
                do {
                    let safeRates = try await getRates()
                    
                    await MainActor.run {
                        rates = safeRates.rates
                        addRates(safeRates.rates)
                    }
                    
                    UserDefaults.standard.set(false, forKey: "updateRates")
//                    UserDefaults.standard.set(safeRates.date, forKey: "updateTime")
                    print("Rates fetched from web")
                } catch {
                    print(error)
                }
            }
        }
    }
}

//MARK: Rates View Model networking

extension RatesViewModel {
    
    func getRates(_ timeStamp: Date? = nil) async throws -> Rates {
        
        do {
            return try await RatesModel().downloadRates(timeStamp: timeStamp)
        } catch {
            throw error
        }
    }
}

//MARK: Rates View Model CoreData

extension RatesViewModel {
    
    private func insertRates() {
        
        do {
            rates = try fetchRates()
            print("Rates fetched from db")
        } catch {
            rates = [:]
            print("Fallback Rates inserted")
        }
    }
    
    private func fetchRates() throws -> [String:Double] {
        
        let request = RatesEntity.fetchRequest()
        var newRates: [String:Double] = [:]
        
        do {
            let fetchedRates = try context.fetch(request)
            for element in fetchedRates {
                newRates.updateValue(element.rate, forKey: element.name ?? "Error")
            }
            if newRates == [:] {
                throw RatesFetchError.emptyDatabase
            }
            return newRates
        } catch {
            throw error
        }
    }
    
    private func addRates(_ data: [String:Double]) {
        
        if let description = NSEntityDescription.entity(forEntityName: "RatesEntity", in: context) {
            
            for element in data {
                
                let newRate = RatesEntity(entity: description, insertInto: context)
                
                newRate.name = element.key
                newRate.rate = element.value
            }
            
            manager.save()
        }
    }
}
