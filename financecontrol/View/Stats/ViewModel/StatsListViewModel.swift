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
    let backgroundDispatchQueue: DispatchQueue
    
    init(cdm: CoreDataModel, fvm: FiltersViewModel, pcvm: PieChartViewModel, searchModel: StatsSearchViewModel) {
        self.savedSpendingsPublisher = cdm.$savedSpendings
        self.searchModel = searchModel
        self.fvm = fvm
        self.pcvm = pcvm
        let data = cdm.operationsForList()
        self.data = data
        self.defaultData = data
        self.showedSearch = ""
        self.backgroundDispatchQueue = DispatchQueue.global(qos: .userInteractive)
        subscribeToData()
        subscribeToFilters()
        subscribeToSearch()
        subscribeToSelection()
    }
    
    private func setData(_ data: StatsListData) {
        self.data = data
    }
    
    private func setDefaultData() {
//        withAnimation(.easeIn(duration: 0.3)) {
        self.data = self.defaultData
//        }
    }
    
    private func subscribeToData() {
        pcvm.$data
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                guard let self else { return }
                
                self.updateDefaultData(data.flatMap { $0.categories.flatMap { $0.spendingsArray } }.sorted { $0.wrappedDate > $1.wrappedDate })
                
                self.update(animation: true)
            }
            .store(in: &cancellables)
    }
    
//    private func subscribeToData() {
//        savedSpendingsPublisher
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] spendings in
//                let safeSpendings = spendings.map { $0.safeObject() }
//                
//                #if DEBUG
//                self?.logger.debug("\(#function) called")
//                #endif
//                
//                self?.updateFromCoreData(safeSpendings)
//                
//                self?.update()
//            }
//            .store(in: &cancellables)
//    }
    
    private func updateDefaultData(_ data: [TSSpendingEntity]) {
        var defaultData: StatsListData = [:]
        
        #if DEBUG
        logger.debug("\(#function) called")
        #endif
        
        for spending in data {
            let day = Calendar.current.startOfDay(for: spending.wrappedDate)
            var existingData = defaultData[day] ?? []
            existingData.append(spending)
            defaultData.updateValue(existingData, forKey: day)
        }
        
        self.defaultData = defaultData.filter { !$0.value.isEmpty }
    }
    
    private func subscribeToSelection() {
        pcvm.$selection
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] selection in
//                self?.updateWithSelection(selection)
                if !(self?.fvm.applyFilters ?? true) && selection == 0 {
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
    
//    private func updateWithSelection(_ value: Int) {
//        let startTime = Date()
//        
//        guard value > 0 else {
//            setDefaultData()
//            
//            #if DEBUG
//            let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
//            logger.debug("\(#function) worked in \(Date().timeIntervalSince(startTime)) seconds")
//            #endif
//            
//            return
//        }
//        
////        let spendings = pcvm.data[pcvm.selection].categories.flatMap { $0.spendings }
////        
////        let context = DataManager.shared.context
////        let request = SpendingEntity.fetchRequest()
////        
////        request.predicate = NSPredicate(
////            format: "date >= %@ AND date < %@",
////            argumentArray: [Date().getFirstDayOfMonth(-value) as NSDate, Date().getFirstDayOfMonth(-value + 1) as NSDate]
////        )
////        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
////        
////        let spendings = context.performAndWait {
////            try? context.fetch(request).map { $0.safeObject() }
////        }
//        
//        let spendings = pcvm.data[pcvm.selection].categories.flatMap { $0.spendingsArray }.sorted { $0.wrappedDate > $1.wrappedDate }
//        
////        guard let spendings else { return }
//        
//        let filteredSpendings = self.filterByCategory(spendings)
//        
//        var result: StatsListData = [:]
//        
//        for spending in filteredSpendings {
//            let day = Calendar.current.startOfDay(for: spending.wrappedDate)
//            var existingData = result[day] ?? []
//            existingData.append(spending)
//            result.updateValue(existingData, forKey: day)
//        }
//        
//        self.setData(result)
//        
//        self.fvm.listUpdated()
//        
//        #if DEBUG
//        let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
//        logger.debug("\(#function) worked in \(Date().timeIntervalSince(startTime)) seconds")
//        #endif
//    }
    
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
            var data = pcvm.data[(pcvm.selection >= pcvm.data.count || pcvm.selection < 0) ? 0 : pcvm.selection].categories.flatMap { $0.spendingsArray }.sorted { $0.wrappedDate > $1.wrappedDate }
            
            if let selectedCategory = pcvm.selectedCategory, let id = selectedCategory.id {
                data = data.filter { $0.categoryID == id }
            }
            
            setupList(data, animation: animation)
        } else {
            #if DEBUG
            logger.debug("Selection == 0")
            #endif
            var data = StatsListData()
            
            data = filterByDate(self.defaultData)
            
            data = filterDataByCategory(data)
            
            self.setData(data)
        }
    }
    
    private func setupList(_ spendings: [TSSpendingEntity], animation: Bool = false) {
        var data: StatsListData = [:]
        
        #if DEBUG
        logger.debug("\(#function) called")
        #endif
        
        for spending in spendings {
            let day = Calendar.current.startOfDay(for: spending.wrappedDate)
            var existingData = data[day] ?? []
            existingData.append(spending)
            data.updateValue(existingData, forKey: day)
        }
        
        if animation {
            withAnimation(.easeIn(duration: 0.3)) {
                self.setData(data)
            }
        } else {
            self.setData(data)
        }
    }
    
//    private func update(_ data: [TSSpendingEntity]? = nil) {
//        let startTime = Date()
//        
//        guard self.fvm.applyFilters || pcvm.selection != 0 else {
//            self.setDefaultData()
//            #if DEBUG
//            let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
//            logger.debug("\(#function) exited in \(Date().timeIntervalSince(startTime)) seconds")
//            #endif
//            
//            return
//        }
//        
////        let context = DataManager.shared.context
////        let request = SpendingEntity.fetchRequest()
////        
////        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", argumentArray: [fvm.startFilterDate as NSDate, fvm.endFilterDate as NSDate])
////        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
////        
////        let spendings = (data != nil) ? data : context.performAndWait {
////            try? context.fetch(request).map { $0.safeObject() }
////        }
////        
////        guard var spendings else { return }
//        
//        var spendings = data != nil ? data ?? [] : pcvm.data[pcvm.selection].categories.flatMap { $0.spendingsArray }
//        
//        if data != nil {
//            let capturedSpendings = spendings
//            
//            DispatchQueue.global(qos: .utility).async { [weak self] in
//                var defaultData: StatsListData = [:]
//                
//                for spending in capturedSpendings {
//                    let day = Calendar.current.startOfDay(for: spending.wrappedDate)
//                    var existingData = defaultData[day] ?? []
//                    existingData.append(spending)
//                    defaultData.updateValue(existingData, forKey: day)
//                }
//                
//                self?.defaultData = defaultData
//            }
//        }
//        
////        if fvm.applyFilters {
////            spendings = spendings.filter { $0.wrappedDate >= fvm.startFilterDate && $0.wrappedDate < fvm.endFilterDate }
////        }
//        
//        spendings = self.filterByCategory(spendings)
//        
//        var result: StatsListData = [:]
//        
//        for spending in spendings {
//            let day = Calendar.current.startOfDay(for: spending.wrappedDate)
//            var existingData = result[day] ?? []
//            existingData.append(spending)
//            result.updateValue(existingData, forKey: day)
//        }
//        
//        self.setData(result)
//        
//        self.fvm.listUpdated()
//        
//        #if DEBUG
//        let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
//        logger.debug("\(#function) worked in \(Date().timeIntervalSince(startTime)) seconds")
//        #endif
//    }
    
//    private func updateFromData(_ data: [TSSpendingEntity]) {
//        var preResult = data
//        
//        if self.fvm.applyFilters {
//            preResult = preResult
//                .filter { $0.date ?? .distantFuture >= self.fvm.startFilterDate && $0.date ?? .distantPast < self.fvm.endFilterDate }
//            
//            preResult = self.filterByCategory(preResult)
//        }
//        
//        var result: StatsListData = [:]
//        
//        for spending in preResult {
//            let day = Calendar.current.startOfDay(for: spending.wrappedDate)
//            var existingData = result[day] ?? []
//            existingData.append(spending)
//            result.updateValue(existingData, forKey: day)
//        }
//        
//        self.defaultData = result
//        
//        if !searchModel.search.isEmpty {
//            result = self.searchFunc(result, prompt: searchModel.search)
//        }
//        
//        setData(result)
//    }
    
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
