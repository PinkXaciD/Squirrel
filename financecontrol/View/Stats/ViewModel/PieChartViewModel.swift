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
    @AppStorage("defaultCurrency") private var defaultCurrency: String = Locale.current.currencyCode ?? "USD"
    private var cdm: CoreDataModel
    @Published var selection: Int = 0
    @Published var content: [PieChartCompleteView<CenterChartView>] = []
    @Published var selectedCategory: CategoryEntity? = nil
    let size: CGFloat
    var cancellables = Set<AnyCancellable>()
    let id = UUID()
    
    init(selection: Int = 0, cdm: CoreDataModel) {
        self.cdm = cdm
        
        let size: CGFloat = {
            let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let windowBounds = currentScene?.windows.first(where: { $0.isKeyWindow })?.bounds
            let width = windowBounds?.width ?? UIScreen.main.bounds.width
            let height = windowBounds?.height ?? UIScreen.main.bounds.height
            return width > height ? (height / 1.7) : (width / 1.7)
        }()
        
        self.size = size
        
        let chartData = cdm.getChartData()
        
        var data: [PieChartCompleteView<CenterChartView>] = []
        var count = 0
        for element in chartData {
            data.append(
                PieChartCompleteView(
                    chart: APChart(
                        separators: 0.15,
                        innerRadius: 0.73,
                        data: setData(element.categories)
                    ),
                    center: CenterChartView(
                        selectedMonth: element.date,
                        width: size,
                        operationsInMonth: element.categories
                    ),
                    count: count,
                    size: size
                )
            )
            
            count += 1
        }
        
        self.content = data
        subscribeToUpdate()
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
    
    func updateData() {
        let chartData: [ChartData] = cdm.getChartData(categoryName: selectedCategory?.name)
        
        var data: [PieChartCompleteView<CenterChartView>] = []
        var count = 0
        
//        if let selectedCategory = selectedCategory {
//            var places: [String:Double] = [:]
//            
//            for element in chartData {
//                guard 
//                    let index = element.categories.firstIndex(where: { $0.name == selectedCategory.name })
//                else {
//                    continue
//                }
//                
//                for spending in element.categories[index].spendings {
//                    let spendingName = spending.place.isEmpty ? "Unknown" : spending.place
//                    print(spendingName)
//                    
//                    if let existing = places[spendingName] {
//                        places.updateValue(existing + spending.amountUSDWithReturns, forKey: spendingName)
//                    } else {
//                        places.updateValue(spending.amountUSDWithReturns, forKey: spendingName)
//                    }
//                }
//            }
//            
//            print(places)
//        }
            
        for element in chartData {
            data.append(
                .init(
                    chart: APChart(
                        separators: 0.15,
                        innerRadius: 0.73,
                        data: setData(element.categories)
                    ),
                    center: CenterChartView(
                        selectedMonth: element.date,
                        width: size,
                        operationsInMonth: element.categories
                    ),
                    count: count,
                    size: size
                )
            )
            
            count += 1
        }
        
        self.content = data
    }
    
    private func setData(_ operations: [CategoryEntityLocal]) -> [APChartSectorData] {
        let result = operations.map { element in
            let value = element.spendings.map { $0.amountUSDWithReturns }.reduce(0, +)
            return APChartSectorData(
                value,
                Color[element.color],
                id: element.id
            )
        }
        
        return result.compactMap { $0 }.filter { $0.value != 0 }.sorted(by: >)
    }
    
    private func subscribeToUpdate() {
        cdm.$updateCharts
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                if value {
                    self?.updateData()
                    self?.cdm.updateCharts = false
                }
            }
            .store(in: &cancellables)
    }
}
