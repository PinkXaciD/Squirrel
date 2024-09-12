//
//  Keychain.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/07/22.
//

import Foundation

struct Keychain {
    let url: String
    
    init(_ url: String) {
        self.url = url
    }
    
    func setPassword(_ key: String, overrideExisting: Bool = false) throws {
        guard let keyData = key.data(using: .utf8) else {
            throw KeychainError.failedToEncodeURL
        }
        
        if overrideExisting, try self.getPassword() != nil {
            try self.removePassword()
        }
        
        let query: [String : Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: url,
            kSecValueData as String: keyData
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.failedToSetValue
        }
    }
    
    func getPassword() throws -> String? {
        let query: [String:Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: url,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return nil
            }
            return nil
        }
        
        guard let existingItem = item as? [String:Any],
              let apiKeyData = existingItem[kSecValueData as String] as? Data,
              let apiKey = String(data: apiKeyData, encoding: .utf8)
        else {
            throw KeychainError.failedToUnwrapValue
        }
        
        return apiKey
    }
    
    func removePassword() throws {
        let query: [String:Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: url
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess else {
            HapticManager.shared.notification(.error)
            throw KeychainError.failedToRemoveValue
        }
        
        HapticManager.shared.notification(.success)
    }
}

enum KeychainError: String, LocalizedError {
    case failedToEncodeURL, failedToSetValue, failedToUnwrapValue, failedToRemoveValue
    
    var errorDescription: String? {
        "Keychain error \(self.rawValue)"
    }
    
    var recoverySuggestion: String? {
        "Try to restart the app"
    }
    
    var failureReason: String? {
        "KeychainError.\(self.rawValue)"
    }
}
