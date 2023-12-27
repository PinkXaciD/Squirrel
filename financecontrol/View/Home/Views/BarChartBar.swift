//
//  BarChartBar.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/27.
//

import SwiftUI

struct BarChartBar: View {
    let index: Int
    var data: (key: Date, value: Double)
    var isActive: Bool
    
    var body: some View {
        let screenHeight = UIScreen.main.bounds.height
        
        VStack(spacing: -5) {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .frame(width: 30, height: screenHeight/5+10)
                    .foregroundColor(Color.secondary)
                    .opacity(0.1)
                    .cornerRadius(5)
                
                if data.value > 0 {
                    Rectangle()
                        .frame(width: 30, height: data.value+10)
                        .foregroundColor(isActive ? Color.accentColor : Color.secondary)
                        .cornerRadius(5)
                }
                
                Rectangle()
                    .frame(width: 30, height: 10)
                    .foregroundColor(Color(UIColor.secondarySystemGroupedBackground))
                    .animation(.none, value: isActive)
            } // Column rectangle end
            
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
}

struct BarChartBar_Previews: PreviewProvider {
    static var previews: some View {
        BarChartBar(index: 1, data: (key: Date.now, value: 1.0), isActive: true)
            .environmentObject(CoreDataModel())
    }
}
