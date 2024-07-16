//
//  StatsSearchViewModel.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/03/05.
//

import Foundation
#if DEBUG
import OSLog
#endif

final class StatsSearchViewModel: SearchViewModel {
    override init() {
        super.init()
        #if DEBUG
        let logger = Logger(subsystem: Vars.appIdentifier, category: "StatsSearchViewModel.swift")
        logger.debug("ViewModel initialized")
        #endif
    }
    
    deinit {
        #if DEBUG
        let logger = Logger(subsystem: Vars.appIdentifier, category: "StatsSearchViewModel.swift")
        logger.debug("ViewModel deinitialized")
        #endif
    }
}
