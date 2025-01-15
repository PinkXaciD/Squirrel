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
    @EnvironmentObject
    private var fvm: FiltersViewModel
    
    let size: CGFloat
    let showMinimizeButton: Bool
    
    @AppStorage(UDKey.defaultCurrency.rawValue)
    var defaultCurrency: String = Locale.current.currencyCode ?? "USD"
    
    @State
    private var minimizeLegend: Bool = UserDefaults.standard.bool(forKey: UDKey.minimizeLegend.rawValue)
    
    var body: some View {
        Section {
            VStack {
                chart
            }
            .frame(height: size * 1.1)
            .disabled(pcvm.isScrollDisabled)
            .listRowInsets(.init(top: 20, leading: 0, bottom: 20, trailing: 0))
            
            if !pcvm.data[(pcvm.selection >= pcvm.data.count || pcvm.selection < 0) ? 0 : pcvm.selection].categories.isEmpty {
                legend
            }
        } footer: {
            if showMinimizeButton {
                footer
            }
        }
        .onChange(of: pcvm.selection) { _ in
            if pcvm.showOther {
                pcvm.showOther = false
            }
        }
    }
    
    private var chart: some View {
        CustomPagingScrollView(selection: $pcvm.selection, data: pcvm.data, invert: true, viewScale: 0.65)
    }
    
    private var legend: some View {
        PieChartLegendView(minimize: $minimizeLegend, selection: $pcvm.selection, forceExpand: !showMinimizeButton)
    }
    
    private var footer: some View {
        HStack(alignment: .center) {
            if let name = pcvm.selectedCategory?.name {
                Button {
                    removeSelection()
                } label: {
                    VStack(alignment: .leading) {
                        Text("Selected category: \(name)")
                        
                        Text("Tap here to remove selection")
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
    private func toggleLegend() {
        withAnimation {
            minimizeLegend.toggle()
        }
        UserDefaults.standard.set(minimizeLegend, forKey: UDKey.minimizeLegend.rawValue)
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
    
    private func removeSelection() {
        pcvm.selectedCategory = nil
        pcvm.updateData()
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
