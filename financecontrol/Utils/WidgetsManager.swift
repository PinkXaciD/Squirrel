//
//  WidgetsManager.swift
//  financecontrol
//
//  Created by PinkXaciD on R 6/01/09.
//

import WidgetKit
import OSLog

final class WidgetsManager {
    static let shared: WidgetsManager = .init()
    let sumWidgets: [Widgets] = [.smallSum, .accessoryRectangularSum]
    let logger = Logger(subsystem: "com.pinkxacid.financecontrol", category: "WidgetsManager")
    
    var sumWidgetsNeedsToReload: Bool = false
    
    private let sharedDefaults = UserDefaults(suiteName: "group.financecontrol")
    
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
            logger.debug("Reload executed")
        } else {
            logger.debug("Reload called, but not executed")
        }
    }
    
    func passAmountToSumWidgets(_ amount: Double) {
        logger.debug("passAmountToSumWidget(_: Double) called")
        guard let sharedDefaults = sharedDefaults else {
            logger.error("Failed to initialize UserDefaults")
            return
        }
        let currentDate = Calendar.current.startOfDay(for: .now)
        sharedDefaults.set(amount, forKey: "amount")
        sharedDefaults.set(currentDate, forKey: "date")
        sumWidgetsNeedsToReload = true
    }
}

enum Widgets {
    case smallSum, accessoryRectangularSum, accessoryCircularAddExpense
}

extension Widgets {
    var kind: String {
        switch self {
        case .smallSum:
            "SmallSumWidget"
        case .accessoryRectangularSum:
            "AccessoryRectangularSumWidget"
        case .accessoryCircularAddExpense:
            "AccessoryCircularAddExpense"
        }
    }
}
