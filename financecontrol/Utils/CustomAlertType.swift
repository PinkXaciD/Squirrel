//
//  CustomAlertTypes.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/24.
//

import SwiftUI

enum CustomAlertType {
    case success
    case failure
    case warning
    case noInternet
    case unknown
}

extension CustomAlertType {
    var alertTitle: String {
        switch self {
        case .success:
            return "Success"
        case .failure:
            return "Failure"
        case .warning:
            return "Warning"
        case .unknown:
            return "Unknown"
        case .noInternet:
            return "No internet connection"
        }
    }
    
    var image: Image {
        switch self {
        case .success:
            return Image(systemName: "checkmark.circle")
        case .failure:
            return Image(systemName: "xmark.circle")
        case .warning:
            return Image(systemName: "exclamationmark.circle")
        case .unknown:
            return Image(systemName: "questionmark.circle")
        case .noInternet:
            return Image(systemName: "network.slash")
        }
    }
    
    var imageColor: Color {
        switch self {
        case .success:
            return Color.green
        case .failure:
            return Color.red
        case .warning:
            return Color.yellow
        case .unknown:
            return Color.accentColor
        case .noInternet:
            return Color.blue
        }
    }
    
    var haptic: UINotificationFeedbackGenerator.FeedbackType {
        switch self {
        case .success:
            UINotificationFeedbackGenerator.FeedbackType.success
        case .failure:
            UINotificationFeedbackGenerator.FeedbackType.error
        case .warning, .noInternet, .unknown:
            UINotificationFeedbackGenerator.FeedbackType.warning
        }
    }
}
