//
//  CustomAlertViewModel.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/07/02.
//

import Combine
import UIKit

final class CustomAlertViewModel: ObservableObject {
    let id: UUID
    
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    var cancellables = Set<AnyCancellable>()
    
    init(id: UUID, haptic: UINotificationFeedbackGenerator.FeedbackType?) {
        self.id = id
        
        if let haptic {
            HapticManager.shared.notification(haptic)
        }
        
        catchTimer()
    }
    
    func catchTimer() {
        self.timer
            .sink { [weak self] _ in
                if let id = self?.id {
                    CustomAlertManager.shared.removeAlert(id)
                }
            }
            .store(in: &cancellables)
    }
}
