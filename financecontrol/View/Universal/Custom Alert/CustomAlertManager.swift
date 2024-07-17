//
//  CustomAlertManager.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/07/02.
//

import SwiftUI

final class CustomAlertManager: ObservableObject {
    static let shared = CustomAlertManager()
    
    @Published
    var alerts: [CustomAlertData]
    
    private init() {
        self.alerts = []
    }
    
    func addAlert(_ alert: CustomAlertData) {
        withAnimation(.bouncy) {
            self.alerts.append(alert)
        }
    }
    
    func removeAlert(_ id: UUID) {
        if !self.alerts.isEmpty, let index = self.alerts.firstIndex(where: { $0.id == id }) {
            let _ = withAnimation(.bouncy) {
                self.alerts.remove(at: index)
            }
        }
    }
}
