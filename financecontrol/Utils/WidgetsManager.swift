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
    let sumWidgets: [Widgets] = [.smallSum, .accessorySum, .weeklySpendings, .weeklySpendingsAccessory]
    
    #if DEBUG
    let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
    #endif
    
    var sumWidgetsNeedsToReload: Bool = false
    var accentColorChanged: Bool = false
    
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
//                print(widget.kind)
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
    
    func updateSpendingsWidgets(data: [String:Double], amount: Double) {
        guard let sharedDefaults else {
            #if DEBUG
            logger.error("Failed to initialize UserDefaults")
            #endif
            return
        }
        
        #if DEBUG
//        logger.debug("\(data)")
        #endif
        
        let currentDate = Calendar.current.startOfDay(for: .now)
        sharedDefaults.set(amount, forKey: "amount")
        sharedDefaults.set(currentDate, forKey: "date")
        sharedDefaults.set(data, forKey: "WeeklySpendingsWidgetData")
        sumWidgetsNeedsToReload = true
    }
    
    func updateAccentColor() {
        if accentColorChanged {
            let widgetsWithAccentColor: [Widgets] = [.weeklySpendings]
            
            for widget in widgetsWithAccentColor {
                WidgetCenter.shared.reloadTimelines(ofKind: widget.kind)
            }
        }
    }
}

enum Widgets {
    case smallSum, accessorySum, accessoryCircularAddExpense, weeklySpendings, weeklySpendingsAccessory
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
        case .weeklySpendings:
            "WeeklySpendingsWidget"
        case .weeklySpendingsAccessory:
            "WeeklySpendingsAccessoryWidget"
        }
    }
}
// WeeklySpendingsAccessoryWidget, WeeklySpendingsWidget
