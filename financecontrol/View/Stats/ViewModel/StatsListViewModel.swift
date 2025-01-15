//
//  StatsListViewModel.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/02/27.
//

import Combine
import SwiftUI
#if DEBUG
import OSLog
#endif

final class StatsListViewModel: ViewModel {
    #if DEBUG
    let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
    #endif
//    private var savedSpendingsPublisher: Published<[SpendingEntity]>.Publisher
    private var searchModel: StatsSearchViewModel
    private var fvm: FiltersViewModel
    private var pcvm: PieChartViewModel
//    private var cdm: CoreDataModel
    @Published var selection: Int
    @Published var selectedCategoryId: UUID?
    @Published var data: [Date:[SpendingEntity]] = .init()
    var cancellables = Set<AnyCancellable>()
    private let context = DataManager.shared.context
    
    init(cdm: CoreDataModel, fvm: FiltersViewModel, pcvm: PieChartViewModel, searchModel: StatsSearchViewModel) {
//        self.savedSpendingsPublisher = cdm.$savedSpendings
        self.searchModel = searchModel
        self.fvm = fvm
        self.pcvm = pcvm
//        self.cdm = cdm
        self.selection = pcvm.selection
        self.selectedCategoryId = pcvm.selectedCategory?.id
        subscribeToSelection()
        subscribeToSelectedCategory()
        
//        NotificationCenter.default.addObserver(
//            forName: .NSManagedObjectContextDidSave,
//            object: cdm.context,
//            queue: .main
//        ) { [weak self] _ in
//            self?.fetch()
//        }
//        
//        fetch()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .NSManagedObjectContextDidSave, object: context)
    }
    
    private func fetch() {
        context.perform { [weak self] in
            let request = SpendingEntity.fetchRequest()
            request.predicate = self?.getPredicate()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \SpendingEntity.date, ascending: false)]
            
            do {
                guard let result = try self?.context.fetch(request) else { return }
                
                self?.data = Dictionary(grouping: result) {
                    $0.startOfDay
                }
            } catch {
//                print(error)
            }
        }
    }
    
    private func getPredicate() -> NSPredicate {
        if pcvm.selection == 0, !fvm.applyFilters, pcvm.selectedCategory == nil, searchModel.search.isEmpty {
            return NSPredicate(value: true)
        }
        
        var predicates = [NSPredicate]()
        
        if let selectedCategory = pcvm.selectedCategory {
            let selectedCategoryPredicate = NSPredicate(format: "category.id == %@", selectedCategory.id as CVarArg)
            predicates.append(selectedCategoryPredicate)
        }
        
        if pcvm.selection != 0 {
            let selectedMonthPredicate = NSPredicate(
                format: "date >= %@ AND date < %@",
                Date().getFirstDayOfMonth(-pcvm.selection) as CVarArg,
                Date().getFirstDayOfMonth(-pcvm.selection + 1) as CVarArg
            )
            predicates.append(selectedMonthPredicate)
        }
        
        if fvm.applyFilters {
            let datePredicate = NSPredicate(format: "date >= %@ AND date < %@", fvm.startFilterDate as CVarArg, fvm.endFilterDate as CVarArg)
            predicates.append(datePredicate)
            
            if !fvm.filterCategories.isEmpty {
                let filterCategoriesPredicate = NSPredicate(format: "category.id IN %@", fvm.filterCategories as CVarArg)
                predicates.append(filterCategoriesPredicate)
            }
            
            if !fvm.currencies.isEmpty {
                let currenciesPredicate = NSPredicate(format: "currency IN %@", fvm.currencies as CVarArg)
                predicates.append(currenciesPredicate)
            }
            
            if let withReturns = fvm.withReturns {
                let returnsPredicate = NSPredicate(format: "returns.@count \(withReturns ? ">" : "==") 0")
                predicates.append(returnsPredicate)
            }
        }
        
        if !searchModel.search.isEmpty {
            let searchPredicate = NSPredicate(format: "place CONTAINS %@ OR comment CONTAINS %@", searchModel.search, searchModel.search)
            predicates.append(searchPredicate)
        }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    private func subscribeToSelection() {
        pcvm.$selection
            .receive(on: DispatchQueue.main)
            .dropFirst()
//            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] newValue in
                self?.selection = newValue
            }
            .store(in: &cancellables)
    }
    
    private func subscribeToSelectedCategory() {
        pcvm.$selectedCategory
            .receive(on: DispatchQueue.main)
            .sink { [weak self] category in
                self?.selectedCategoryId = category?.id
            }
            .store(in: &cancellables)
    }
    
    func cancelSubscriptions() {
        cancellables.cancelAll()
    }
}

extension Set<AnyCancellable> {
    func cancelAll() {
        for item in self {
            item.cancel()
        }
    }
}
