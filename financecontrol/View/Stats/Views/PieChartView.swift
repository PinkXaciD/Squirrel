//
//  PieChartView.swift
//  Squirrel
//
//  Created by PinkXaciD on 2023/08/26.
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
    let spendingsCount: Int
    let inSidebar: Bool
    
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
    
    private var useAlternativeBackground: Bool {
        if #available(iOS 26.0, *) {
            return inSidebar
        }
        
        return false
    }
    
    private var selectedDate: Date {
        Calendar.current.date(byAdding: .month, value: -pcvm.selection, to: Date()) ?? Date()
    }
    
    init(size: CGFloat, showMinimizeButton: Bool, spendingsCount: Int, inSidebar: Bool = false) {
        self.size = size
        self.showMinimizeButton = showMinimizeButton
        self.spendingsCount = spendingsCount
        self.inSidebar = inSidebar
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            chart
                .frame(height: size * 1.1)
                .disabled(pcvm.isScrollDisabled)
                .clipped()
                .padding(.bottom, padding)
            
            if inSidebar {
                buttons
                    .padding(.bottom)
            }
            
            legend
        }
        .padding(.top, padding)
        .background {
            if useAlternativeBackground {
                Color.secondary
                    .opacity(0.1)
            } else {
                Color(uiColor: .secondarySystemGroupedBackground)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: Self.listCornerRadius))
        .onChange(of: pcvm.selection) { _ in
            if pcvm.showOther {
                pcvm.showOther = false
            }
        }
        
        footer
    }
    
    private var chart: some View {
        CustomPagingScrollView(
            selection: $pcvm.selection,
            data: pcvm.data,
            invert: true,
            viewScale: inSidebar ? 0.8 : 0.65,
            spendingsCount: spendingsCount,
            inSidebar: inSidebar
        )
    }
    
    private var buttons: some View {
        HStack {
            Button {
                NotificationCenter.default.post(.init(name: .PieChartScrollPrevious))
            } label: {
                HStack {
                    Image(systemName: "chevron.backward")
                    
                    dateText(adjustDate: -1)
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .center)
                .background {
                    RoundedRectangle(cornerRadius: Self.listCornerRadius)
                        .fill(Color(uiColor: .systemGray3).opacity(0.3))
                }
            }
            .disabled(pcvm.selection >= pcvm.data.count - 1)
            
            Spacer()
            
            Button {
                NotificationCenter.default.post(.init(name: .PieChartScrollNext))
            } label: {
                HStack {
                    dateText(adjustDate: 1)
                    
                    Image(systemName: "chevron.forward")
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .center)
                .background {
                    RoundedRectangle(cornerRadius: Self.listCornerRadius)
                        .fill(Color(uiColor: .systemGray3).opacity(0.3))
                }
            }
            .disabled(pcvm.selection <= 0)
        }
        .padding(.horizontal, 8)
    }
    
    @ViewBuilder
    private func dateText(monthFormatWidth: Date.FormatStyle.Symbol.Month = .wide, adjustDate: Int) -> some View {
        let adjustedDate = Calendar.autoupdatingCurrent.date(byAdding: .month, value: adjustDate, to: selectedDate) ?? .distantPast
        
        if Calendar.current.isDate(adjustedDate, equalTo: Date(), toGranularity: .year) {
            Text(adjustedDate, format: .dateTime.month(monthFormatWidth))
        } else {
            Text(adjustedDate, format: .dateTime.month().year())
        }
    }
    
    private var legend: some View {
        PieChartLegendView(minimize: showMinimizeButton ? $minimizeLegend : .constant(false), selection: $pcvm.selection, inSidebar: inSidebar)
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
                    
                    if showMinimizeButton {
                        Button(action: toggleLegend, label: expandButtonLabel)
                    }
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
                
                if showMinimizeButton {
                    Button(action: toggleLegend, label: expandButtonLabel)
                }
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
