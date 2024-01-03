//
//  RatesViewModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/18.
//

import CoreData
import Foundation

// MARK: Rates View Model

final class RatesViewModel: ViewModel {
    @Published 
    var rates: [String:Double] = [:]
    
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
                    
                    let formatter = ISO8601DateFormatter()
                    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    
                    guard
                        let date = formatter.date(from: safeRates.timestamp),
                        Calendar.current.isDate(date, equalTo: .now, toGranularity: .hour)
                    else {
                        return
                    }
                    
                    UserDefaults.standard.set(safeRates.timestamp, forKey: "updateTime")
                    UserDefaults.standard.set(false, forKey: "updateRates")
                    
                    print("Rates fetched from web")
                } catch {
                    print(error)
                }
            }
        }
    }
}

// MARK: Rates View Model networking

extension RatesViewModel {
    func getRates(_ timeStamp: Date? = nil) async throws -> Rates {
        do {
            let rm: RatesModel = .init()
            return try await rm.downloadRates(timeStamp: timeStamp)
        } catch {
            throw error
        }
    }
}

// MARK: Rates View Model CoreData

extension RatesViewModel {
    private func insertRates() {
        guard
            let fetchedRates = UserDefaults.standard.value(forKey: "rates") as? [String: Double]
        else {
            rates = Rates.fallback.rates
            return
        }
        
        rates = fetchedRates
    }
    
    private func addRates(_ data: [String: Double]) {
        UserDefaults.standard.setValue(data, forKey: "rates")
    }
}
