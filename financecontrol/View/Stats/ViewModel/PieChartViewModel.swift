//
//  PieChartLazyPageViewViewModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 6/02/03.
//

import SwiftUI
import ApplePie
import Combine
#if DEBUG
import OSLog
#endif

final class PieChartViewModel: ViewModel {
    private var cdm: CoreDataModel
    var fvm: FiltersViewModel
    
    @Published var selection: Int = 0
    var previousSelection: Int = 0
    @Published var data: [ChartData]
    @Published var selectedCategory: CategoryEntity? = nil
    @Published var isScrollDisabled: Bool = false
    @Published var showOther: Bool = false
    
    var cancellables = Set<AnyCancellable>()
    let id = UUID()
    
    init(selection: Int = 0, cdm: CoreDataModel, fvm: FiltersViewModel) {
        self.cdm = cdm
        self.fvm = fvm
        
        self.data = cdm.getChartData()
        
        subscribeToUpdate()
        subscribeToSelection()
        
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
}

// MARK: Methods
extension PieChartViewModel {
    func updateData() {
        let chartData: [ChartData] = {
            if fvm.applyFilters {
                return cdm.getFilteredChartData(firstDate: fvm.startFilterDate, secondDate: fvm.endFilterDate, categories: fvm.filterCategories)
            }
            
            return cdm.getChartData(isMinimized: showOther, categoryName: selectedCategory?.name)
        }()
        
        self.data = chartData
    }
    
    func showAllCategories() {
        let dataWithAllCategories = ChartData(date: Date().getFirstDayOfMonth(-self.selection), id: self.selection, showOther: false, cdm: self.cdm, categoryName: self.selectedCategory?.name)
        self.data[selection] = dataWithAllCategories
    }
}

// MARK: Private methods
extension PieChartViewModel {
    private func subscribeToUpdate() {
        cdm.$updateCharts
            .receive(on: DispatchQueue.main)
            .filter { $0 == true }
            .sink { [weak self] value in
                if value {
                    withAnimation {
                        self?.updateData()
                    }
                    self?.cdm.updateCharts = false
                }
            }
            .store(in: &cancellables)
    }
    
    private func subscribeToSelection() {
        self.$selection
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard let self else { return }
                
                if self.showOther {
                    data[previousSelection] = ChartData(
                        date: Date().getFirstDayOfMonth(-self.previousSelection),
                        id: previousSelection,
                        showOther: true,
                        cdm: self.cdm,
                        categoryName: self.selectedCategory?.name
                    )
                    
                    self.showOther = false
                }
                
                self.previousSelection = selection
            }
            .store(in: &cancellables)
    }
}
