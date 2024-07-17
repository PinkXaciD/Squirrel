//
//  CustomAlertTypes.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/24.
//

import SwiftUI

enum CustomAlertType: Hashable {
    case error, warning, success, info
    
    var color: Color {
        switch self {
        case .error:
            .red
        case .warning:
            .yellow
        case .success:
            .green
        case .info:
            .blue
        }
    }
    
    var haptic: UINotificationFeedbackGenerator.FeedbackType? {
        switch self {
        case .error:
            .error
        case .warning:
            .warning
        case .success:
            .success
        case .info:
            nil
        }
    }
}
