//
//  BarChart.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/08.
//

import SwiftUI

struct BarChart: View {
    @Binding var itemSelected: Int
    
    let data: [(key: Date, value: Double)]
    
    let invert = [6, 5, 4, 3, 2, 1, 0]
    
    var body: some View {
        
        HStack(alignment: .bottom) {
            ForEach(0..<7, id: \.self) { index in
                HStack {
                    Spacer()
                    
                    BarChartBar(index: invert[index], data: data[invert[index]], isActive: isActive(index: invert[index]))
                    
                    Spacer()
                }
                .onTapGesture {
                    tapActions(index: invert[index])
                }
            }
        }
    }
    
    private func tapActions(index: Int) {
        if itemSelected == index {
            withAnimation(.linear(duration: 0.07)) {
                itemSelected = -1
            }
        } else {
            withAnimation(.linear(duration: 0.07)) {
                itemSelected = index
            }
        }
    }
    
    private func isActive(index: Int) -> Bool {
        if itemSelected != -1 {
            return index == itemSelected
        }
        return true
    }
}

struct BarChart_Previews: PreviewProvider {
    static var previews: some View {
        @State var itemSelected = -1
        
        BarChart(itemSelected: $itemSelected, data: [(key: Date.now, value: 1.0)])
            .environmentObject(CoreDataViewModel())
    }
}
