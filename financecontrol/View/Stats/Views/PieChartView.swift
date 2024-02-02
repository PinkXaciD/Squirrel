//
//  PieChartView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/26.
//

import SwiftUI

struct PieChartView: View {
    @EnvironmentObject 
    private var cdm: CoreDataModel
    @EnvironmentObject
    private var rvm: RatesViewModel
    @EnvironmentObject
    private var lpvvm: PieChartLazyPageViewViewModel
    
    @Binding
    var filterCategories: [CategoryEntity]
    @Binding
    var applyFilters: Bool
    
    let size: CGFloat
    
    @AppStorage("defaultCurrency")
    var defaultCurrency: String = "USD"
    
    @State
    private var showLegend: Bool = true
    
    var body: some View {
        Section {
            chart
            
            if showLegend {
                legend
            }
        } footer: {
            expandButton
        }
    }
    
    private var chart: some View {
        
        PieChartLazyPageView<PieChartCompleteView<CenterChartView>>(viewSize: size)
            .frame(height: size * 1.1)
            .invertLayoutDirection()
            .listRowInsets(.init(top: 20, leading: 0, bottom: 20, trailing: 0))
            .onAppear {
                if cdm.updateCharts {
                    lpvvm.updateData()
                    cdm.updateCharts = false
                }
            }
            .onChange(of: cdm.updateCharts) { newValue in
                if newValue {
                    lpvvm.updateData()
                    cdm.updateCharts = false
                }
            }
    }
    
    private var legend: some View {
        PieChartLegendView(filterCategories: $filterCategories, applyFilters: $applyFilters)
    }
    
    private var expandButton: some View {
        HStack {
            Spacer()
            
            Image(systemName: "chevron.down")
                .rotationEffect(showLegend ? .degrees(180) : .zero)
                .foregroundColor(.accentColor)
            
            Button(showLegend ? "Minimize" : "Expand") {
                withAnimation {
                    showLegend.toggle()
                }
            }
        }
        .font(.body)
    }
}

extension PieChartView {
    internal init(
        filterCategories: Binding<[CategoryEntity]>,
        applyFilers: Binding<Bool>,
        size: CGFloat
    ) {
        self._filterCategories = filterCategories
        self._applyFilters = applyFilers
        self.size = size
    }
}

//struct PieChart_Previews: PreviewProvider {
//    static var previews: some View {
//        @StateObject var cdm: CoreDataModel = CoreDataModel()
//        let operationsInMonth = cdm.operationsInMonth((Calendar.current.date(byAdding: .month, value: 0, to: .now) ?? .distantPast))
//
//        PieChartView(selectedMonth: .constant(0), size: 200, operationsInMonth: operationsInMonth)
//            .environmentObject(CoreDataModel())
//    }
//}
