//
//  RatesViewModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/18.
//

import Foundation
//import Combine
#if DEBUG
import OSLog
#endif

// MARK: Rates View Model

final class RatesViewModel: ViewModel {
    @Published 
    var rates: [String:Double] = [:]
    
    var cache = [Date:Rates]()
//    var cancellables = Set<AnyCancellable>()
    
    init() {
        insertRates()
        
        if UserDefaults.standard.bool(forKey: UDKeys.updateRates.rawValue) {
            updateRates()
        }
    }
    
    private func updateRates() {
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
                
                UserDefaults.standard.set(safeRates.timestamp, forKey: UDKeys.updateTime.rawValue)
                UserDefaults.standard.set(false, forKey: UDKeys.updateRates.rawValue)
                
                #if DEBUG
                let logger = Logger(subsystem: Vars.appIdentifier, category: "RatesViewModel info")
                logger.debug("Rates fetched from web")
                #endif
            } catch {
                await MainActor.run {
                    if error as? URLError == URLError(.notConnectedToInternet) {
//                        waitForConnectionToEstablish()
                        CustomAlertManager.shared.addAlert(.noConnection("Unable to update exchange rates"))
                    } else {
                        ErrorType(error: error).publish()
                    }
                }
            }
        }
    }
    
//    private func waitForConnectionToEstablish() {
//        NetworkMonitor.shared.$isConnected
//            .sink { [weak self] value in
//                if value {
//                    self?.updateRates()
//                    self?.cancellables.cancelAll()
//                }
//            }
//            .store(in: &cancellables)
//    }
}

// MARK: Rates View Model networking

extension RatesViewModel {
    func getRates(_ timestamp: Date? = nil) async throws -> Rates {
        do {
            if let timestamp, let cached = cache[Calendar.current.startOfDay(for: timestamp)] {
//                print("Get cached rates")
                return cached
            }
            
            let rm: RatesModel = .init()
            let downloaded = try await rm.downloadRates(timestamp: timestamp)
            if let timestamp {
                cache.updateValue(downloaded, forKey: Calendar.current.startOfDay(for: timestamp))
            }
            return downloaded
        } catch {
            throw error
        }
    }
}

// MARK: Rates View Model UserDefaults

extension RatesViewModel {
    private func insertRates() {
        guard
            let fetchedRates = UserDefaults.standard.getRates()
        else {
            rates = Rates.fallback.rates
            return
        }
        
        rates = fetchedRates
    }
    
    private func addRates(_ data: [String: Double]) {
        UserDefaults.standard.setValue(data, forKey: UDKeys.rates.rawValue)
    }
}
