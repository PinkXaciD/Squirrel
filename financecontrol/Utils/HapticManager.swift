//
//  HapticManager.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/25.
//

import UIKit
#if targetEnvironment(simulator)
import OSLog
#endif

final class HapticManager {
    static let shared = HapticManager()
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
        #if targetEnvironment(simulator)
        let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
        logger.debug("\(type.debugDescription) haptic occured")
        #endif
    }
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
        #if targetEnvironment(simulator)
        let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
        logger.debug("\(style.debugDescription) haptic occured")
        #endif
    }
}

#if targetEnvironment(simulator)
extension UINotificationFeedbackGenerator.FeedbackType {
    var debugDescription: String {
        switch self {
        case .success:
            "Success"
        case .warning:
            "Warning"
        case .error:
            "Error"
        @unknown default:
            "Unknown"
        }
    }
}

extension UIImpactFeedbackGenerator.FeedbackStyle {
    var debugDescription: String {
        switch self {
        case .light:
            "Light"
        case .medium:
            "Medium"
        case .heavy:
            "Heavy"
        case .soft:
            "Soft"
        case .rigid:
            "Rigid"
        @unknown default:
            "Unknown"
        }
    }
}
#endif
