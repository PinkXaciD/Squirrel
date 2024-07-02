//
//  CustomAlertViewExtension.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/07/02.
//

import SwiftUI

extension View {
    func customAlert() -> some View {
        return self
            .overlay(alignment: .top) {
                CustomAlerts()
            }
    }
}

private struct CustomAlerts: View {
    @ObservedObject private var manager = CustomAlertManager.shared
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(manager.alerts.reversed()) { alert in
                CustomAlertView(data: alert)
            }
        }
    }
}
