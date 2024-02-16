//
//  HapticManager.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/25.
//

import UIKit

final class HapticManager {
    static let shared = HapticManager()
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
