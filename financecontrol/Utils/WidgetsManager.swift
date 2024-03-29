//
//  WidgetsManager.swift
//  financecontrol
//
//  Created by PinkXaciD on R 6/01/09.
//

import WidgetKit
#if DEBUG
import OSLog
#endif

final class WidgetsManager {
    static let shared: WidgetsManager = .init()
    let sumWidgets: [Widgets] = [.smallSum, .accessorySum]
    
    #if DEBUG
    let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
    #endif
    
    var sumWidgetsNeedsToReload: Bool = false
    
    private let sharedDefaults = UserDefaults(suiteName: Vars.groupName)
    
    func reloadAll() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}

// MARK: Sum Widgets
extension WidgetsManager {
    func reloadSumWidgets() {
        if sumWidgetsNeedsToReload {
            for widget in sumWidgets {
                WidgetCenter.shared.reloadTimelines(ofKind: widget.kind)
            }
            sumWidgetsNeedsToReload = false
            
            #if DEBUG
            logger.debug("Reload executed")
            #endif
        } else {
            #if DEBUG
            logger.debug("Reload called, but not executed")
            #endif
        }
    }
    
    func passAmountToSumWidgets(_ amount: Double) {
        #if DEBUG
        logger.debug("\(#function) called")
        #endif
        
        guard let sharedDefaults = sharedDefaults else {
            #if DEBUG
            logger.error("Failed to initialize UserDefaults")
            #endif
            return
        }
        
        let currentDate = Calendar.current.startOfDay(for: .now)
        sharedDefaults.set(amount, forKey: "amount")
        sharedDefaults.set(currentDate, forKey: "date")
        sumWidgetsNeedsToReload = true
    }
}

enum Widgets {
    case smallSum, accessorySum, accessoryCircularAddExpense
}

extension Widgets {
    var kind: String {
        switch self {
        case .smallSum:
            "SmallSumWidget"
        case .accessorySum:
            "AccessorySumWidget"
        case .accessoryCircularAddExpense:
            "AccessoryCircularAddExpense"
        }
    }
}
