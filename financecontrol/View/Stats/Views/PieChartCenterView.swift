//
//  CenterChartView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/11/21.
//

import SwiftUI

struct CenterChartView: View {
    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize
    
    @EnvironmentObject
    private var cdm: CoreDataModel
    @EnvironmentObject
    private var rvm: RatesViewModel
    @EnvironmentObject
    private var fvm: FiltersViewModel
    
    @AppStorage(UDKey.defaultCurrency.rawValue)
    var defaultCurrency: String = Locale.current.currencyCode ?? "USD"
    
    @ScaledMetric(relativeTo: .largeTitle)
    private var sumTextSize: CGFloat = 30
    
    var selectedMonth: Date
    
    let width: CGFloat
    let operationsInMonth: Double
    
    private var monthFormatWidth: Date.FormatStyle.Symbol.Month {
        if dynamicTypeSize > .accessibility2 {
            return .abbreviated
        }
        
        return .wide
    }
    
    var body: some View {
        VStack(alignment: .center) {
            dateText(monthFormatWidth: monthFormatWidth)
                .padding(.top, 5)
                .scaledToFit()
                .accessibilityShowsLargeContentViewer {
                    Label {
                        dateText(monthFormatWidth: .wide)
                    } icon: {
                        Image(systemName: "calendar")
                    }

//                    dateText(monthFormatWidth: .wide)
                }
            
            Text(operationsSum(operationsInMonth: operationsInMonth))
                .lineLimit(1)
                .font(.system(size: sumTextSize, weight: .semibold, design: .rounded))
                .padding(.horizontal, 6)
                .minimumScaleFactor(0.5)
                .scaledToFit()
            
            Text(defaultCurrency)
                .foregroundColor(Color.secondary)
                .accessibilityShowsLargeContentViewer {
                    Label {
                        Text(Locale.autoupdatingCurrent.localizedString(forCurrencyCode: defaultCurrency) ?? "")
                    } icon: {
                        Image(systemName: "circle")
                    }
                }
        }
        .frame(maxWidth: width/1.4)
        .scaledToFit()
        .minimumScaleFactor(0.01)
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
    }
}

extension CenterChartView {
    internal init(selectedMonth: Date, width: CGFloat, operationsInMonth: Double) {
        self.selectedMonth = selectedMonth
        self.width = width
        self.operationsInMonth = operationsInMonth
    }
    
    @ViewBuilder
    private func dateText(monthFormatWidth: Date.FormatStyle.Symbol.Month) -> some View {
        if fvm.applyFilters {
            Text("Filters applied")
        } else {
            if Calendar.current.isDate(selectedMonth, equalTo: Date(), toGranularity: .year) {
                Text(selectedMonth, format: .dateTime.month(monthFormatWidth))
            } else {
                Text(selectedMonth, format: .dateTime.month().year())
            }
        }
    }
    
    private func operationsSum(operationsInMonth: Double) -> String {
        return Locale.current.currencyNarrowFormat(operationsInMonth, currency: UserDefaults.defaultCurrency()) ?? "Error"
    }
}
