//
//  NetworkMonitor.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/07/02.
//

import Foundation
import Network
#if DEBUG
import OSLog
import Combine
#endif

// TODO: Doesn't setting up properly on init()
final class NetworkMonitor: ObservableObject {
//    static let shared = NetworkMonitor()
    
    private let monitor: NWPathMonitor
    private let queue: DispatchQueue
    
    #if DEBUG
    let logger: Logger
    var cancellables = Set<AnyCancellable>()
    #endif
    
    @Published
    var isConnected: Bool
    @Published
    var isExpensive: Bool
    
    private init() {
        self.monitor = NWPathMonitor()
        self.isConnected = monitor.currentPath.status == .satisfied
        self.isExpensive = monitor.currentPath.isExpensive
        self.queue = DispatchQueue(label: "NetworkMonitor")
        
        #if DEBUG
        self.logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
        logToCL()
        #endif
        
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
                self.isExpensive = path.isExpensive
            }
        }
        
        monitor.start(queue: self.queue)
    }
    
    deinit {
        #if DEBUG
        logger.log("deinit")
        #endif
    }
    
    #if DEBUG
    private func logToCL() {
        self.$isConnected
            .sink { value in
                print(value.description)
            }
            .store(in: &cancellables)
    }
    #endif
}
