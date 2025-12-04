//
//  PieChartView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/26.
//

import SwiftUI

struct PieChartView: View {
    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize
    
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
    
    @Namespace
    var namespace
    
    private var padding: CGFloat {
        if #available(iOS 26, *) {
            return 14
        }
        
        return 8
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            chart
                .frame(height: size * 1.1)
                .disabled(pcvm.isScrollDisabled)
                .clipped()
                .padding(.bottom, padding)
            
            legend
        }
        .padding(.top, padding)
        .background {
            RoundedRectangle(cornerRadius: Self.listCornerRadius)
                .foregroundStyle(Color(uiColor: .secondarySystemGroupedBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: Self.listCornerRadius))
        .onChange(of: pcvm.selection) { _ in
            if pcvm.showOther {
                pcvm.showOther = false
            }
        }
        
        if showMinimizeButton {
            footer
        }
    }
    
    private var chart: some View {
        CustomPagingScrollView(selection: $pcvm.selection, data: pcvm.data, invert: true, viewScale: 0.65)
    }
    
    private var legend: some View {
        PieChartLegendView(minimize: showMinimizeButton ? $minimizeLegend : .constant(true), selection: $pcvm.selection)
    }
    
    @ViewBuilder
    private var footer: some View {
        if dynamicTypeSize > .accessibility1 {
            HStack(spacing: 0) {
                VStack(alignment: .leading) {
                    if let name = pcvm.selectedCategory?.name {
                        Button {
                            removeSelection()
                        } label: {
                            VStack(alignment: .leading) {
                                Text("Selected category: \(name)")
                                
                                Text("Tap here to remove selection")
                            }
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Spacer()
                    
                    Button(action: toggleLegend, label: expandButtonLabel)
                }
                .padding(.horizontal)
                
                Spacer()
            }
        } else {
            HStack(alignment: .center) {
                if let name = pcvm.selectedCategory?.name {
                    Button {
                        removeSelection()
                    } label: {
                        VStack(alignment: .leading) {
                            Text("Selected category: \(name)")
                            
                            Text("Tap here to remove selection")
                        }
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                Button(action: toggleLegend, label: expandButtonLabel)
            }
            .padding(.horizontal)
        }
    }
}

extension PieChartView {
    private func toggleLegend() {
        withAnimation(UIAccessibility.prefersCrossFadeTransitions ? .linear(duration: 0) : .default) {
            minimizeLegend.toggle()
        }
        
        UserDefaults.standard.set(minimizeLegend, forKey: UDKey.minimizeLegend.rawValue)
    }
    
    private func expandButtonLabel() -> some View {
        Label {
            if minimizeLegend {
                Text("Expand")
                    .fixedSize()
                    .matchedGeometryEffect(id: UIAccessibility.prefersCrossFadeTransitions ? "None" : "MinimizeButtonText", in: namespace)
            } else {
                Text("Minimize")
                    .fixedSize()
                    .matchedGeometryEffect(id: "MinimizeButtonText", in: namespace)
            }
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
