//
//  RatesViewModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/18.
//

import Foundation
import UIKit
#if DEBUG
import OSLog
#endif

// MARK: Rates View Model

final class RatesViewModel: ViewModel {
    enum RatesDownloadStatus {
        case none, downloading, waitingForNetwork, failed, success
    }
    
    @Published
    var rates: [String:Double] = [:]
    @Published
    var status: RatesDownloadStatus = .none
    
    var cache = [Date:Rates]()
    
    init() {
        insertRates()
        
        if UserDefaults.standard.bool(forKey: UDKeys.updateRates.rawValue) {
            self.status = .downloading
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
                
                // MARK: Is latest check
                guard
                    let date = formatter.date(from: safeRates.timestamp),
                    Calendar.current.isDate(date, equalTo: .now, toGranularity: .hour)
                else {
                    await MainActor.run {
                        self.status = .failed
                    }
                    
                    return
                }
                
                UserDefaults.standard.set(safeRates.timestamp, forKey: UDKeys.updateTime.rawValue)
                UserDefaults.standard.set(false, forKey: UDKeys.updateRates.rawValue)
                print(UserDefaults.standard.bool(forKey: UDKeys.updateRates.rawValue))
                
                await MainActor.run {
                    self.status = .success
                }
                
                #if DEBUG
                let logger = Logger(subsystem: Vars.appIdentifier, category: "RatesViewModel info")
                logger.debug("Rates fetched from web")
                #endif
            } catch URLError.notConnectedToInternet, URLError.timedOut {
                await MainActor.run {
                    CustomAlertManager.shared.addAlert(.noConnection("Unable to update exchange rates"))
                    waitForConnectionToEstablish()
                }
            } catch {
                print(error)
                await MainActor.run {
                    ErrorType(error: error).publish()
                    self.status = .failed
                }
            }
        }
    }
    
    private func waitForConnectionToEstablish() {
        if !(self.status == .waitingForNetwork) {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.updateOnNetworkConnection),
                name: NSNotification.Name("ConnectionEstablished"),
                object: NetworkMonitor.shared
            )
            
            self.status = .waitingForNetwork
        }
    }
    
    @objc
    private func updateOnNetworkConnection() {
        updateRates()
        
        #if DEBUG
        CustomAlertManager.shared.addAlert(.init(type: .info, title: "\(#function)", description: "Function called", systemImage: "info.circle"))
        #endif
        
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name("ConnectionEstablished"),
            object: NetworkMonitor.shared
        )
        
        #if DEBUG
        CustomAlertManager.shared.addAlert(.init(type: .info, title: "Observer removed", systemImage: "info.circle"))
        #endif
        
        self.status = .success
    }
}

// MARK: Rates View Model networking

extension RatesViewModel {
    func getRates(_ timestamp: Date? = nil) async throws -> Rates {
//        guard self.status != .waitingForNetwork else {
//            throw URLError(.notConnectedToInternet)
//        }
        
        do {
            if let timestamp, let cached = cache[Calendar.current.startOfDay(for: timestamp)] {
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
        UserDefaults.standard.set(data, forKey: UDKeys.rates.rawValue)
    }
}
