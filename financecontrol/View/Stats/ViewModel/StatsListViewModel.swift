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
    
    @Published private(set) var selection: Int
    @Published private(set) var selectedCategoryId: UUID?
    @Published private(set) var data: [(key: Date, value: [StatsRowData])] = .init()
    
    private var allSpendingsCount: Int
    
    private var searchModel: StatsSearchViewModel
    private var fvm: FiltersViewModel
    private var pcvm: PieChartViewModel
    private let context = DataManager.shared.context
    private var cancellables = Set<AnyCancellable>()
    
    init(cdm: CoreDataModel, fvm: FiltersViewModel, pcvm: PieChartViewModel, searchModel: StatsSearchViewModel) {
        self.allSpendingsCount = 0
        self.searchModel = searchModel
        self.fvm = fvm
        self.pcvm = pcvm
        self.selection = pcvm.selection
        self.selectedCategoryId = pcvm.selectedCategory?.id
        subscribeToSelection()
        subscribeToSelectedCategory()
        subscribeToSearch()
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchFromNotification), name: .UpdatePieChart, object: nil)
        
        Task {
            await fetch()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UpdatePieChart, object: nil)
    }
    
    @objc
    private func fetchFromNotification() {
        Task {
            await self.fetch(animateChanges: true)
        }
    }
    
    private func fetch(animateChanges: Bool = false) async {
        let request = SpendingEntity.fetchRequest()
        request.predicate = self.getPredicate()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SpendingEntity.date, ascending: false)]
        
        do {
            let result = try self.context.performAndWait {
                try self.context.fetch(request)
            }
            
            let sectionedResult = Dictionary(grouping: result) { spending in
                return self.context.performAndWait {
                    spending.startOfDay
                }
            }
            
            let sortedResult = sectionedResult
                .mapValues { arr in
                    var result = [StatsRowData]()
                    result.reserveCapacity(arr.count)
                    
                    for entity in arr {
                        context.performAndWait {
                            result.append(StatsRowData(entity: entity))
                        }
                    }
                    
                    return result
                }
                .sorted { (firstSection, secondSection) in
                    firstSection.key > secondSection.key
                }
            
            await MainActor.run {
                withAnimation(animateChanges ? .default : .none) {
                    self.data = sortedResult
                }
            }
        } catch {
            ErrorType(error: error).publish()
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
            let searchPredicate = NSPredicate(format: "place CONTAINS[cd] %@ OR comment CONTAINS[cd] %@", searchModel.search, searchModel.search)
            predicates.append(searchPredicate)
        }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    private func subscribeToSelection() {
        pcvm.$selection
            .dropFirst()
            .sink { [weak self] newValue in
                self?.selection = newValue
                
                Task {
                    await self?.fetch()
                }
            }
            .store(in: &cancellables)
    }
    
    private func subscribeToSelectedCategory() {
        pcvm.$selectedCategory
            .dropFirst()
            .sink { [weak self] _ in
                Task {
                    await self?.fetch()
                }
            }
            .store(in: &cancellables)
    }
    
    private func subscribeToSearch() {
        searchModel.getPublisher()
            .dropFirst()
            .sink { [weak self] _ in
                Task {
                    await self?.fetch()
                }
            }
            .store(in: &cancellables)
    }
    
    func cancelSubscriptions() {
        cancellables.cancelAll()
    }
}

struct StatsRowData: Identifiable {
    let entity: SpendingEntity
    let amount: Double
    let currency: String
    let categoryName: String
    let date: Date
    let place: String?
    let showTimeZoneIcon: Bool
    let hasReturns: Bool
    
    let id: UUID
    
    init(entity: SpendingEntity) {
        self.id = entity.wrappedId
        
        self.entity = entity
        self.amount = entity.amount
        self.currency = entity.wrappedCurrency
        self.categoryName = entity.categoryName
        self.date = entity.dateAdjustedToTimeZone
        self.place = entity.place
        self.hasReturns = !(entity.returns?.allObjects.isEmpty ?? true)
        
        guard let entityTimeZoneID = entity.timeZoneIdentifier, let entityTimeZoneOffset = TimeZone(identifier: entityTimeZoneID)?.secondsFromGMT() else {
            self.showTimeZoneIcon = false
            return
        }
        
        self.showTimeZoneIcon = entityTimeZoneOffset != Calendar.autoupdatingCurrent.timeZone.secondsFromGMT()
    }
}
