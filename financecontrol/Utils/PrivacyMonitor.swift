//
//  PrivacyMonitor.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/06/12.
//

import Foundation

final class PrivacyMonitor: ObservableObject {
    @Published private(set) var privacyScreenIsEnabled: Bool
    @Published private(set) var hideExpenseSum: Bool
    
    init(privacyScreenIsEnabled: Bool, hideExpenseSum: Bool) {
        self.privacyScreenIsEnabled = privacyScreenIsEnabled
        self.hideExpenseSum = hideExpenseSum
    }
    
    func changePrivacyScreenValue(_ newValue: Bool) {
        self.privacyScreenIsEnabled = newValue
    }
}
