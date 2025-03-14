//
//  CloudKitKVSManager.swift
//  Squirrel
//
//  Created by PinkXaciD on 2025/01/07.
//

import Foundation
import Combine

final class CloudKitKVSManager: ObservableObject {
    @Published
    var iCloudSync: Bool
    
    private let store: NSUbiquitousKeyValueStore
    private var valueSubscription: AnyCancellable?
    
    init(store: NSUbiquitousKeyValueStore = .default) {
        self.iCloudSync = store.bool(forKey: UDKey.iCloudSync.rawValue)
        self.store = store
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(update(_:)),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: store
        )
        
        self.toggleKVS()
        
        store.synchronize()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: self.store
        )
    }
    
    @objc
    func update(_ notification: Notification) {
        guard let changedKeys = notification.userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? Array<String> else {
            return
        }
        
        if changedKeys.contains(UDKey.iCloudSync.rawValue) {
            DispatchQueue.main.async {
                self.iCloudSync = self.store.bool(forKey: UDKey.iCloudSync.rawValue)
            }
        }
    }
    
    private func toggleKVS() {
        self.valueSubscription = self.$iCloudSync
            .sink { newValue in
                self.store.set(newValue, forKey: UDKey.iCloudSync.rawValue)
            }
    }
}
