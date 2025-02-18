//
//  PieChartLazyPageViewViewModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 6/02/03.
//

import SwiftUI
import Combine
#if DEBUG
import OSLog
#endif

final class PieChartViewModel: ViewModel {
    private var cdm: CoreDataModel
    var fvm: FiltersViewModel
    
    @Published var selection: Int = 0
    @Published var data: [ChartData]
    @Published var selectedCategory: ChartCategory? = nil
    @Published var isScrollDisabled: Bool = false
    @Published var showOther: Bool = false
    
    var cancellables = Set<AnyCancellable>()
    let id = UUID()
    
    init(cdm: CoreDataModel, fvm: FiltersViewModel) {
        self.cdm = cdm
        self.fvm = fvm
        
        self.data = cdm.getNewChartData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: .UpdatePieChart, object: nil)
        
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
        NotificationCenter.default.removeObserver(self, name: .init("UpdatePieChart"), object: nil)
    }
}

// MARK: Methods
extension PieChartViewModel {
    @objc func updateData() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            let chartData: [ChartData] = {
                if self.fvm.applyFilters {
                    return self.cdm.getNewFilteredChartData(
                        firstDate: self.fvm.startFilterDate,
                        secondDate: self.fvm.endFilterDate,
                        categories: self.fvm.filterCategories,
                        withReturns: self.fvm.withReturns,
                        currencies: self.fvm.currencies
                    )
                }
                
                return self.cdm.getNewChartData()
            }()
            
            self.data = chartData
        }
    }
    
    func applyFilters() {
        self.selection = 0
        self.isScrollDisabled = true
        self.selectedCategory = nil
        self.updateData()
    }
    
    func disableFilters() {
        self.selectedCategory = nil
        self.updateData()
        self.isScrollDisabled = false
    }
}
