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
    private var pcvm: PieChartViewModel
    
    @Binding
    var filterCategories: [CategoryEntity]
    @Binding
    var applyFilters: Bool
    
    let size: CGFloat
    
    @AppStorage("defaultCurrency")
    var defaultCurrency: String = "USD"
    
    @State
    private var minimizeLegend: Bool = true
    
    var body: some View {
        Section {
            chart
            
            legend
        } footer: {
            footer
        }
    }
    
    private var chart: some View {
        PieChartLazyPageView<PieChartCompleteView<CenterChartView>>(viewSize: size)
            .frame(height: size * 1.1)
            .invertLayoutDirection()
            .listRowInsets(.init(top: 20, leading: 0, bottom: 20, trailing: 0))
            .onAppear {
                if cdm.updateCharts {
                    pcvm.updateData()
                    cdm.updateCharts = false
                }
            }
            .onChange(of: cdm.updateCharts) { newValue in
                if newValue {
                    pcvm.updateData()
                    cdm.updateCharts = false
                }
            }
    }
    
    private var legend: some View {
        PieChartLegendView(
            filterCategories: $filterCategories,
            applyFilters: $applyFilters,
            minimize: $minimizeLegend,
            cdm: cdm,
            pcvm: pcvm
        )
    }
    
    private var footer: some View {
        HStack(alignment: .center) {
            if let name = pcvm.selectedCategory?.name {
                Button {
                    withAnimation {
                        pcvm.selectedCategory = nil
                        pcvm.updateData()
                    }
                    
                    if filterCategories.count == 1 {
                        withAnimation {
                            filterCategories.removeAll()
                        }
                        
                        if pcvm.selection == 0 {
                            withAnimation {
                                applyFilters = false
                            }
                        }
                    }
                } label: {
                    VStack(alignment: .leading) {
                        Text("Selected category: \(name)")
                        
                        Text("Tap to remove selection")
                    }
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            Button(action: toggleLegend, label: expandButtonLabel)
        }
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
    
    private func toggleLegend() {
        withAnimation {
            minimizeLegend.toggle()
        }
    }
    
    private func expandButtonLabel() -> some View {
        Label {
            Text(minimizeLegend ? "Expand" : "Minimize")
        } icon: {
            Image(systemName: "chevron.down")
                .rotationEffect(minimizeLegend ? .zero : .degrees(180))
                .foregroundColor(.accentColor)
        }
        .font(.body)
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
