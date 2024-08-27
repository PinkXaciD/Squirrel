//
//  NetworkMonitor.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/07/02.
//

import Foundation
import Network
import Combine
#if DEBUG
import OSLog
#endif

// TODO: Doesn't setting up properly on init()
final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    let monitor: NWPathMonitor
    private let queue: DispatchQueue
    
    #if DEBUG
    let logger: Logger
    #endif
    var cancellables = Set<AnyCancellable>()
    
    @Published
    var isConnected: Bool
    @Published
    var isExpensive: Bool
    @Published
    var status: NWPath.Status
    
    private init() {
        self.monitor = NWPathMonitor()
        self.isConnected = monitor.currentPath.status == .satisfied
        self.status = monitor.currentPath.status
        self.isExpensive = monitor.currentPath.isExpensive
        self.queue = DispatchQueue(label: "NetworkMonitor")
        
        #if DEBUG
        self.logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
        logToCL()
        #endif
        sendNotificationOnConnection()
        
        
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
                self.isExpensive = path.isExpensive
                self.status = path.status
                
//                if path.status == .satisfied {
//                    NotificationCenter.default.post(name: NSNotification.Name("ConnectionEstablished"), object: self)
//                }
                
//                #if DEBUG
//                CustomAlertManager.shared.addAlert(.init(type: .info, title: "Path update handler", description: "\(path.status.description)", systemImage: "info.circle"))
//                #endif
            }
        }
        
        monitor.start(queue: self.queue)
    }
    
    deinit {
        #if DEBUG
        logger.log("deinit")
        #endif
    }
    
    private func sendNotificationOnConnection() {
        self.$isConnected
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                if value {
                    NotificationCenter.default.post(name: Notification.Name("ConnectionEstablished"), object: self)
                }
            }
            .store(in: &cancellables)
    }
    
    #if DEBUG
    private func logToCL() {
        self.$isConnected
            .sink { [weak self] value in
                self?.logger.debug("\(value.description)")
            }
            .store(in: &cancellables)
    }
    #endif
}

extension NWPath.Status {
    var description: String {
        switch self {
        case .satisfied:
            "satisfied"
        case .unsatisfied:
            "unsatisfied"
        case .requiresConnection:
            "requiresConnection"
        @unknown default:
            "unknown"
        }
    }
}
