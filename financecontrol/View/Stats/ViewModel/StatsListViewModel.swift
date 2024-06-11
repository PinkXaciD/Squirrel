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
    @Published var data: StatsListData
    @Published var showedSearch: String
    var defaultData: StatsListData
    var cancellables = Set<AnyCancellable>()
    
    init(cdm: CoreDataModel, fvm: FiltersViewModel, pcvm: PieChartViewModel, searchModel: StatsSearchViewModel) {
        self.savedSpendingsPublisher = cdm.$savedSpendings
        self.searchModel = searchModel
        self.fvm = fvm
        self.pcvm = pcvm
        let data = cdm.operationsForList()
        self.data = data
        self.defaultData = data
        self.showedSearch = ""
        subscribeToData()
        subscribeToFilters()
        subscribeToSearch()
        subscribeToSelection()
    }
    
    private func setData(_ data: StatsListData) {
        self.data = data.mapValues { Array(Set($0)).sorted { $0.wrappedDate > $1.wrappedDate } }
    }
    
    private func setDefaultData() {
        self.data = self.defaultData
    }
    
    private func subscribeToData() {
        pcvm.$data
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                guard let self else { return }
                
                self.updateDefaultData(data.flatMap { $0.categories.flatMap { $0.spendingsArray } }.sorted { $0.wrappedDate > $1.wrappedDate })
                
                self.update(animation: false)
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
            .sink { [weak self] selection in
                if selection == 0 {
                    withAnimation {
                        self?.setDefaultData()
                    }
                    
                    HapticManager.shared.impact(.soft)
                    
                    return
                }
                
                self?.update(animation: true)
                
                HapticManager.shared.impact(.soft)
            }
            .store(in: &cancellables)
    }
    
    private func subscribeToFilters() {
        fvm.$updateList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                if value {
                    self?.update(animation: false)
                }
            }
            .store(in: &cancellables)
    }
    
    private func subscribeToSearch() {
        searchModel.$search
            .receive(on: DispatchQueue.main)
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .sink { [weak self] search in
                guard let self else { return }
                
                var result = self.defaultData
                
                if self.fvm.applyFilters {
                    result = self.filterByDate(result)
                    
                    result = self.filterDataByCategory(result)
                }
                
                result = self.searchFunc(result, prompt: search)
                
                result = result.filter { !$0.value.isEmpty }
                
                if result.isEmpty {
                    self.showedSearch = search
                } else {
                    self.showedSearch = ""
                }
                
                self.setData(result)
            }
            .store(in: &cancellables)
    }
        
    private func update(animation: Bool = false) {
        guard self.fvm.applyFilters || pcvm.selection != 0 else {
            setDefaultData()
            
            return
        }
        
        #if DEBUG
        logger.debug("\(#function) called")
        #endif
        
        if pcvm.selection != 0 {
            #if DEBUG
            logger.debug("Selection != 0")
            #endif
            var data = pcvm.data[(pcvm.selection >= pcvm.data.count || pcvm.selection < 0) ? 0 : pcvm.selection].categories.flatMap { $0.spendingsArray }
            
            if let selectedCategory = pcvm.selectedCategory, let id = selectedCategory.id {
                data = data.filter { $0.categoryID == id }
            }
            
            setupList(data, animation: animation)
        } else {
            #if DEBUG
            logger.debug("Selection == 0")
            #endif
            
            guard fvm.applyFilters else {
                self.setDefaultData()
                return
            }
            
            var data = filterByDate(self.defaultData)
            
            data = filterDataByCategory(data)
            
            self.setData(data)
        }
    }
    
    private func setupList(_ spendings: [TSSpendingEntity], animation: Bool = false) {
        let data: StatsListData = Dictionary(grouping: spendings) { spending in
            Calendar.current.startOfDay(for: spending.wrappedDate)
        }
        
        #if DEBUG
        logger.debug("\(#function) called")
        #endif
        
        if animation {
            withAnimation(.easeIn(duration: 0.3)) {
                self.setData(data)
            }
        } else {
            self.setData(data)
        }
    }
        
    private func filterByDate(_ data: StatsListData) -> StatsListData {
        guard fvm.applyFilters else {
            return data
        }
        
        var result: StatsListData = .init()
        for key in data.keys.sorted(by: <) {
            if key < fvm.startFilterDate {
                continue
            } else if key >= fvm.endFilterDate {
                break
            } else {
                result.updateValue(data[key] ?? [], forKey: key)
            }
        }
        
        return result
    }
    
    private func filterDataByCategory(_ data: StatsListData) -> StatsListData {
        guard fvm.applyFilters, !fvm.filterCategories.isEmpty else {
            return data
        }
        
        return data.mapValues { spendings in
            spendings.filter { spending in
                guard let id = spending.categoryID else { return false }
                return fvm.filterCategories.contains(id)
            }
        }
        .filter { !$0.value.isEmpty }
    }
    
    private func filterByCategory(_ data: [TSSpendingEntity]) -> [TSSpendingEntity] {
        guard fvm.applyFilters, !fvm.filterCategories.isEmpty else {
            return data
        }
        
        return data.filter { spending in
            guard let id = spending.categoryID else {
                return false
            }
            
            return fvm.filterCategories.contains(id)
        }
    }
    
    func searchFunc(_ data: StatsListData, prompt: String) -> StatsListData {
        guard !prompt.isEmpty else { return data }
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        return data.mapValues { spendings in
            spendings.filter { spending in
                spending.place?.localizedCaseInsensitiveContains(trimmedPrompt) ?? false || spending.comment?.localizedCaseInsensitiveContains(trimmedPrompt) ?? false
            }
        }
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
