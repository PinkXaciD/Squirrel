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
    private var savedSpendingsPublisher: Published<[SpendingEntity]>.Publisher
    private var searchModel: StatsSearchViewModel
    private var fvm: FiltersViewModel
    private var pcvm: PieChartViewModel
    private var cdm: CoreDataModel
    @Published var showedSearch: String
    @Published var selection: Int
    @Published var selectedCategoryId: UUID?
    var defaultData: StatsListData
    var cancellables = Set<AnyCancellable>()
    
    init(cdm: CoreDataModel, fvm: FiltersViewModel, pcvm: PieChartViewModel, searchModel: StatsSearchViewModel) {
        self.savedSpendingsPublisher = cdm.$savedSpendings
        self.searchModel = searchModel
        self.fvm = fvm
        self.pcvm = pcvm
        self.cdm = cdm
        self.defaultData = [:]
        self.showedSearch = ""
        self.selection = pcvm.selection
        self.selectedCategoryId = pcvm.selectedCategory?.id
        subscribeToSelection()
        subscribeToSelectedCategory()
    }
    
    private func subscribeToData() {
        cdm.$savedSpendings
            .receive(on: DispatchQueue.main)
            .sink { [weak self] spendings in
                guard let self else { return }
                
                self.updateDefaultData(spendings.map { $0.safeObject() })
            }
            .store(in: &cancellables)
    }
    
    private func updateDefaultData(_ data: [TSSpendingEntity]) {
        #if DEBUG
        logger.debug("\(#function) called")
        #endif
        
        self.defaultData = Dictionary(grouping: data) { spending in
            Calendar.current.startOfDay(for: spending.wrappedDate)
        }
        .filter { !$0.value.isEmpty }
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
