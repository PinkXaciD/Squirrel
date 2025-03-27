//
//  FiltersViewModel.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/02/27.
//

import Foundation
#if DEBUG
import OSLog
#endif

final class FiltersViewModel: ViewModel {
    @Published
    var startFilterDate: Date
    @Published
    var endFilterDate: Date
    @Published
    var filterCategories: [UUID]
    @Published
    var currencies: [String]
    @Published
    var month: Int
    @Published
    var year: Int
    @Published
    var dateType: FiltersView.DateType
    @Published
    var applyFilters: Bool
    @Published
    var updateList: Bool
    @Published
    var withReturns: Bool?
    
    init() {
        self.applyFilters = false
        self.startFilterDate = .now.getFirstDayOfMonth()
        self.endFilterDate = .now
        self.filterCategories = []
        self.currencies = []
        self.dateType = .multi
        self.month = Calendar.current.component(.month, from: .now)
        self.year = Calendar(identifier: .gregorian).component(.year, from: .now)
        self.updateList = false
        
        #if DEBUG
        let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
        logger.debug("ViewModel initialized")
        #endif
    }
    
    deinit {
        #if DEBUG
        let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
        logger.debug("ViewModel deinitialized")
        #endif
    }
    
    func clearFilters() {
        self.applyFilters = false
        self.startFilterDate = .now.getFirstDayOfMonth()
        self.endFilterDate = .now
        self.filterCategories = []
        self.updateList = true
        self.withReturns = nil
        self.currencies = []
        self.dateType = .multi
        self.year = Calendar(identifier: .gregorian).component(.year, from: .now)
        self.month = Calendar.current.component(.month, from: .now)
    }
    
    func listUpdated() {
        self.updateList = false
    }
}

