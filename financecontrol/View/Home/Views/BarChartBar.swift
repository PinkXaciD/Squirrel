//
//  BarChartBar.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/27.
//

import SwiftUI

struct BarChartBar: View {
    @EnvironmentObject private var cdm: CoreDataModel
    let index: Int
    var data: (key: Date, value: Double)
    var isActive: Bool
    let screenHeight = UIScreen.main.bounds.height / 5
    
    var body: some View {
        VStack(spacing: -5) {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .frame(width: 30, height: screenHeight + 10)
                    .foregroundColor(Color.secondary)
                    .opacity(0.1)
//                    .cornerRadius(5)
                
                if data.value > 0 {
                    Rectangle()
                        .frame(width: 30, height: countBarHeight() + 10)
                        .foregroundColor(isActive ? Color.accentColor : Color.secondary)
//                        .cornerRadius(5)
                }
                
                // MARK: Avg bar
//                Rectangle()
//                    .fill(LinearGradient(colors: [Color(uiColor: .secondarySystemGroupedBackground).opacity(0.2), Color(uiColor: .secondarySystemGroupedBackground).opacity(0)], startPoint: .top, endPoint: .bottom))
//                    .frame(width: 30, height: countAvgBarHeight() + 10)
//                    .foregroundColor(.secondary.opacity(0.1))
            } // Column rectangle end
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .overlay(alignment: .bottom) {
                Rectangle()
                    .frame(width: 30, height: 10)
                    .foregroundColor(Color(UIColor.secondarySystemGroupedBackground))
                    .animation(.none, value: isActive)
            }
            
            Text(weekdayDateFormat(data.key))
                .font(.footnote)
                .foregroundColor(Color.secondary)
        } // VStack w bar and text
    }
    
    private func weekdayDateFormat(_ date: Date) -> String {
        return date
            .formatted(Date.FormatStyle(locale: Locale.current)
                .weekday(.abbreviated)
            )
    }
    
    private func countBarHeight() -> Double {
        let max = cdm.barChartData.max
        let height = screenHeight
        return height / max * data.value
    }
    
    private func countAvgBarHeight() -> Double {
        let avg = cdm.barChartData.sum/7
        return screenHeight / cdm.barChartData.max * avg
    }
}

struct BarChartBar_Previews: PreviewProvider {
    static var previews: some View {
        BarChartBar(index: 1, data: (key: Date.now, value: 1.0), isActive: true)
            .environmentObject(CoreDataModel())
    }
}
