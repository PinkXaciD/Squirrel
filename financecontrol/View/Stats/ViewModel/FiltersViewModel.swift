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
    
    init(
        startFilterDate: Date = .now.getFirstDayOfMonth(),
        endFilterDate: Date  = .now,
        dateType: FiltersView.DateType = .multi
    ) {
        self.applyFilters = false
        self.startFilterDate = startFilterDate
        self.endFilterDate = endFilterDate
        self.filterCategories = []
        self.currencies = []
        self.dateType = dateType
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
    
    func getPredicate() -> NSPredicate {
        var predicates = [NSPredicate]()
        
        let datePredicate = NSPredicate(format: "date >= %@ AND date < %@", self.startFilterDate as CVarArg, self.endFilterDate as CVarArg)
        predicates.append(datePredicate)
        
        if !self.filterCategories.isEmpty {
            let filterCategoriesPredicate = NSPredicate(format: "category.id IN %@", self.filterCategories as CVarArg)
            predicates.append(filterCategoriesPredicate)
        }
        
        if !self.currencies.isEmpty {
            let currenciesPredicate = NSPredicate(format: "currency IN %@", self.currencies as CVarArg)
            predicates.append(currenciesPredicate)
        }
        
        if let withReturns = self.withReturns {
            let returnsPredicate = NSPredicate(format: "returns.@count \(withReturns ? ">" : "==") 0")
            predicates.append(returnsPredicate)
        }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}

