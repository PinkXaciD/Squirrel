//
//  RatesViewModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/18.
//

import SwiftUI
#if DEBUG
import OSLog
#endif

// MARK: Rates View Model

final class RatesViewModel: ViewModel {
    enum RatesDownloadStatus {
        case none, downloading, waitingForNetwork, failed, success, tryingAgain
    }
    
    @Published
    private(set) var rates: [String:Double] = [:]
    @Published
    private(set) var status: RatesDownloadStatus = .none
    
    private(set) var cache = [Date:Rates]()
    private var updateTime: Date = Date()
    
    init() {
        insertRates()
        
        hourlyUpdate()
        
        if UserDefaults.standard.bool(forKey: UDKey.updateRates.rawValue) {
            updateRates(checkURLVersion: true)
        }
    }
    
    private func updateRates(checkURLVersion: Bool = false) {
        let isTryingAgain = self.status == .tryingAgain
        self.status = .downloading
        
        Task { [weak self, isTryingAgain] in
            guard let self else { return }
            
            do {
                let (cloudKitUpdateDate, safeRates) = try await getRates(checkURLVersion: checkURLVersion)
                
                // MARK: Is latest check
                guard
                    Calendar.gmt.isDate(cloudKitUpdateDate, equalTo: Date(), toGranularity: .hour)
                else {
                    // Try again
                    if !isTryingAgain {
                        await self.tryAgain()
                        
                        return
                    }
                    
                    await MainActor.run {
                        self.status = .failed
                    }
                    
                    return
                }
                
                await MainActor.run {
                    let isoFormatter = ISO8601DateFormatter()
                    
                    self.rates = safeRates.rates
                    self.addRates(safeRates.rates)
                    
                    UserDefaults.standard.set(isoFormatter.string(from: cloudKitUpdateDate), forKey: UDKey.updateTime.rawValue)
                    UserDefaults.standard.set(false, forKey: UDKey.updateRates.rawValue)
                    
                    self.updateTime = Date()
                    NotificationCenter.default.post(name: .UpdatePieChart, object: nil)
                    self.status = .success
                }
                
                #if DEBUG
                let logger = Logger(subsystem: Vars.appIdentifier, category: "RatesViewModel info")
                logger.debug("Rates fetched from web")
                #endif
                
            } catch CloudKitManager.CloudKitError.networkUnavailable {
                await MainActor.run {
                    CustomAlertManager.shared.addAlert(.noConnection("Unable to update exchange rates"))
                    self.waitForConnectionToEstablish()
                }
            } catch {
//                print(error)
                await MainActor.run {
                    ErrorType(error: error).publish()
                    self.status = .failed
                }
            }
        }
    }
    
    private func tryAgain() async {
        await MainActor.run {
            self.status = .tryingAgain
        }
        
        try? await Task.sleep(nanoseconds: 10_000_000_000) // 10 sec.
        
        await MainActor.run {
            self.updateRates()
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
    
    func checkForUpdate() {
        if !Calendar.current.isDate(updateTime, equalTo: Date(), toGranularity: .hour) {
            updateRates()
        }
    }
    
    /// Will update exchange rates automatically every hour
    private func hourlyUpdate() {
        let currentHour = Calendar.current.component(.hour, from: .now)
        
        let fireTime = Calendar.current.date(byAdding: .hour, value: currentHour + 1, to: Calendar.current.startOfDay(for: Date())) ?? Calendar.current.startOfDay(for: Date())
        
        let timer = Timer(fire: fireTime, interval: .hour, repeats: true) { [weak self] timer in
            if (self?.status != .downloading && self?.status != .waitingForNetwork), !Calendar.current.isDate(self?.updateTime ?? .distantPast, equalTo: Date(), toGranularity: .hour) {
                self?.updateRates()
            }
        }
        
        RunLoop.main.add(timer, forMode: .default)
    }
}

// MARK: Rates View Model networking

extension RatesViewModel {
    func getRates(_ timestamp: Date? = nil, checkURLVersion: Bool = false) async throws -> (editDate: Date, rates: Rates) {
        if let timestamp, let cached = cache[Calendar.gmt.startOfDay(for: timestamp)] {
            return (timestamp, cached)
        }
        
        var timestampString: String? {
            if let timestamp {
                let dateFormatter = DateFormatter.forRatesTimestamp
                return dateFormatter.string(from: Calendar.gmt.startOfDay(for: timestamp))
            }
            
            return nil
        }
        
        let ckManager = CloudKitManager.shared
        
        let result = try await ckManager.fetchRates(timestamp: timestampString ?? "latest")
        
        return result
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
    
    private func addRates(_ data: [String : Double]) {
        UserDefaults.standard.set(data, forKey: UDKey.rates.rawValue)
    }
}
