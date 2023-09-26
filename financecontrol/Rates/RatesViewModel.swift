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
    let date: String
    let usd: [String: Double]
}

//MARK: Rates View Model

final class RatesViewModel: ObservableObject {
    
    @Published var rates: [String:Double] = [:]
    
    let manager = DataManager.instance
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    init() {
        
        self.container = manager.container
        self.context = manager.context
        
        insertRates()
        
        if UserDefaults.standard.bool(forKey: "updateRates") {
            Task {
                if let safeRates = await getRates() {
                    await MainActor.run {
                        rates = safeRates
                        addRates(safeRates)
                    }
                    UserDefaults.standard.set(false, forKey: "updateRates")
                    print("Rates fetched from web")
                }
            }
        }
    }
}

//MARK: Rates View Model networking

extension RatesViewModel {
    
    private func getRates() async -> [String:Double]? {
        
        do {
            return try await RatesModel().downloadRates()
        } catch {
            print(error)
        }
        
        return nil
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
        
        enum RatesFetchError: Error {
            case EmptyDatabase
        }
        
        let request = RatesEntity.fetchRequest()
        var newRates: [String:Double] = [:]
        
        do {
            let fetchedRates = try context.fetch(request)
            for element in fetchedRates {
                newRates.updateValue(element.rate, forKey: element.name ?? "Error")
            }
            if newRates == [:] {
                throw RatesFetchError.EmptyDatabase
            }
            return newRates
        } catch {
            throw error
        }
    }
    
    func addRates(_ data: [String:Double]) {
        
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
