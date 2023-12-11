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
                    
                    var formatter: ISO8601DateFormatter {
                        let formatter = ISO8601DateFormatter()
                        formatter.timeZone = .gmt
                        return formatter
                    }
                    
                    if
                        let date = formatter.date(from: safeRates.timestamp),
                        Calendar.current.isDate(date, equalTo: .now, toGranularity: .hour)
                    {
                        UserDefaults.standard.set(safeRates.timestamp, forKey: "updateTime")
                    }
                    
                    UserDefaults.standard.set(false, forKey: "updateRates")
                    
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
        guard
            let rates = UserDefaults.standard.value(forKey: "rates") as? [String:Double]
        else {
            return [:]
        }
        
        return rates
    }
    
    private func addRates(_ data: [String:Double]) {
        UserDefaults.standard.setValue(data, forKey: "rates")
    }
    
    func deleteOldRates() {
    }
}
