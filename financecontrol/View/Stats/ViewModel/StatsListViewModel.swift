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
    private var savedSpendingsPublisher: Published<[SpendingEntity]>.Publisher
    private var searchModel: StatsSearchViewModel
    private var fvm: FiltersViewModel
    @Published var data: StatsListData
    @Published var showedSearch: String
    var defaultData: StatsListData
    var cancellables = Set<AnyCancellable>()
    let backgroundDispatchQueue: DispatchQueue
    
    init(cdm: CoreDataModel, fvm: FiltersViewModel, searchModel: StatsSearchViewModel) {
        self.savedSpendingsPublisher = cdm.$savedSpendings
        self.searchModel = searchModel
        self.fvm = fvm
        let data = cdm.operationsForList()
        self.data = data
        self.showedSearch = ""
        self.defaultData = data
        self.backgroundDispatchQueue = DispatchQueue.global(qos: .userInteractive)
        subscribeToData()
        subscribeToFilters()
        subscribeToSearch()
    }
    
    private func setData(_ data: StatsListData) {
        DispatchQueue.main.async {
            withAnimation(.easeIn(duration: 0.3)) {
                self.data = data
            }
        }
    }
    
    private func setDefaultData() {
        DispatchQueue.main.async {
            withAnimation(.easeIn(duration: 0.3)) {
                self.data = self.defaultData
            }
        }
    }
    
    private func subscribeToData() {
        savedSpendingsPublisher
            .subscribe(on: backgroundDispatchQueue)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] spendings in
                let safeSpendings = spendings.map { $0.safeObject() }
                self?.backgroundDispatchQueue.async {
                    self?.update(safeSpendings)
                }
            }
            .store(in: &cancellables)
    }
    
    private func subscribeToFilters() {
        fvm.$updateList
            .subscribe(on: backgroundDispatchQueue)
            .receive(on: backgroundDispatchQueue)
            .sink { [weak self] value in
                if value {
                    self?.update()
//                    guard let self else { return }
//                    
//                    guard self.fvm.applyFilters else {
//                        self.setDefaultData()
//                        #if DEBUG
//                        let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
//                        logger.debug("\(#function) worked")
//                        #endif
//                        
//                        return
//                    }
//
//                    var result = self.defaultData
//                    let context = DataManager.shared.context
//                    let request = SpendingEntity.fetchRequest()
//                    
//                    request.predicate = NSPredicate(format: "date >= %@ AND date < %@", fvm.startFilterDate as NSDate, fvm.endFilterDate as NSDate)
//                    
//                    let spendings = context.performAndWait {
//                        try? context.fetch(request).map { $0.safeObject() }
//                    }
//                    
//                    guard let spendings else { return }
//                    
//                    var result: StatsListData = [:]
//                    
//                    for spending in spendings {
//                        let day = Calendar.current.startOfDay(for: spending.wrappedDate)
//                        var existingData = result[day] ?? []
//                        existingData.append(spending)
//                        result.updateValue(existingData, forKey: day)
//                    }
//                    
//                    result = self.filterByDate(result)
//                    
//                    result = self.filterByCategory(result)
//                    
//                    if !self.searchModel.search.isEmpty {
//                        result = self.searchFunc(result, prompt: searchModel.search)
//                    }
//                    
//                    result = result.filter { !$0.value.isEmpty }
//                    
//                    self.setData(result)
//                    
//                    self.fvm.listUpdated()
//                    
//                    #if DEBUG
//                    let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
//                    logger.debug("\(#function) worked")
//                    #endif
                }
            }
            .store(in: &cancellables)
    }
    
    private func subscribeToSearch() {
        searchModel.$search
            .subscribe(on: backgroundDispatchQueue)
            .receive(on: backgroundDispatchQueue)
            .debounce(for: .seconds(0.3), scheduler: backgroundDispatchQueue)
            .sink { [weak self] search in
                guard let self else { return }
                
                var result = self.defaultData
                
                if self.fvm.applyFilters {
                    result = self.filterByDate(result)
                    
                    result = self.filterDataByCategory(result)
                }
                
                result = self.searchFunc(result, prompt: search)
                
                result = result.filter { !$0.value.isEmpty }
                
                DispatchQueue.main.async {
                    if result.isEmpty {
                        withAnimation(.easeIn(duration: 0.3)) {
                            self.showedSearch = search
                        }
                    } else {
                        withAnimation(.easeIn(duration: 0.3)) {
                            self.showedSearch = ""
                        }
                    }
                    
                    self.setData(result)
                }
            }
            .store(in: &cancellables)
    }
    
    private func update(_ data: [TSSpendingEntity]? = nil) {
        guard self.fvm.applyFilters || data != nil else {
            self.setDefaultData()
            #if DEBUG
            let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
            logger.debug("\(#function) exited")
            #endif
            
            return
        }
        
        let context = DataManager.shared.context
        let request = SpendingEntity.fetchRequest()
        
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", argumentArray: [fvm.startFilterDate as NSDate, fvm.endFilterDate as NSDate])
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let spendings = data != nil ? data : context.performAndWait {
            try? context.fetch(request).map { $0.safeObject() }
        }
        
        guard let spendings else { return }
        
        if data != nil {
            DispatchQueue.global(qos: .utility).async { [weak self] in
                var defaultData: StatsListData = [:]
                
                for spending in spendings {
                    let day = Calendar.current.startOfDay(for: spending.wrappedDate)
                    var existingData = defaultData[day] ?? []
                    existingData.append(spending)
                    defaultData.updateValue(existingData, forKey: day)
                }
                
                self?.defaultData = defaultData
            }
        }
        
        let filteredSpendings = self.filterByCategory(spendings)
        
        var result: StatsListData = [:]
        
        for spending in filteredSpendings {
            let day = Calendar.current.startOfDay(for: spending.wrappedDate)
            var existingData = result[day] ?? []
            existingData.append(spending)
            result.updateValue(existingData, forKey: day)
        }
        
        self.setData(result)
        
        self.fvm.listUpdated()
        
        #if DEBUG
        let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
        logger.debug("\(#function) worked")
        #endif
    }
    
    private func updateFromData(_ data: [TSSpendingEntity]) {
        var preResult = data
        
        if self.fvm.applyFilters {
            preResult = preResult
                .filter { $0.date ?? .distantFuture >= self.fvm.startFilterDate && $0.date ?? .distantPast < self.fvm.endFilterDate }
            
            preResult = self.filterByCategory(preResult)
        }
        
        var result: StatsListData = [:]
        
        for spending in preResult {
            let day = Calendar.current.startOfDay(for: spending.wrappedDate)
            var existingData = result[day] ?? []
            existingData.append(spending)
            result.updateValue(existingData, forKey: day)
        }
        
        self.defaultData = result
        
        if !searchModel.search.isEmpty {
            result = self.searchFunc(result, prompt: searchModel.search)
        }
        
        setData(result)
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
        
//        let dateRange = fvm.startFilterDate..<fvm.endFilterDate
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
