//
//  BarChart.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/08.
//

import SwiftUI

struct BarChart: View {
    @EnvironmentObject private var cdm: CoreDataModel
    @Binding var itemSelected: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // MARK: Avg dashed line
                if !cdm.barChartData.sum.isZero {
                    Line()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .frame(height: 2)
                        .offset(y: -(10 + countAvgBarHeight()))
                        .foregroundColor(.secondary.opacity(0.3))
                        .padding(.horizontal, countDashedLinePadding(geometry.size.width))
                }
                
                HStack(alignment: .bottom) {
                    ForEach(cdm.barChartData.bars.sorted(by: { $0.key < $1.key }), id: \.key) { data in
                        HStack {
                            Spacer()
                            
                            BarChartBar(index: countIndex(data.key), data: (key: data.key, value: data.value), isActive: isActive(index: countIndex(data.key)))
                            
                            Spacer()
                        }
                        .onTapGesture {
                            tapActions(index: countIndex(data.key))
                        }
                    }
                }
            }
            .animation(.smooth, value: cdm.barChartData)
        }
        .frame(height: UIScreen.main.bounds.height / 5 + 20)
    }
    
    private func tapActions(index: Int) {
        if itemSelected == index {
            withAnimation(.linear(duration: 0.1)) {
                itemSelected = -1
            }
        } else {
            withAnimation(.linear(duration: 0.1)) {
                itemSelected = index
            }
        }
    }
    
    private func countDashedLinePadding(_ width: CGFloat) -> CGFloat {
        let barWidth: CGFloat = 30
        let spacing = width - (barWidth * 7)
        return spacing / 14
    }
    
    private func isActive(index: Int) -> Bool {
        if itemSelected != -1 {
            return index == itemSelected
        }
        return true
    }
    
    private func countIndex(_ date: Date) -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        return Calendar.current.dateComponents([.day], from: date, to: today).day ?? 0
    }
    
    private func countAvgBarHeight() -> Double {
        let avg = cdm.barChartData.sum/7
        return (UIScreen.main.bounds.height / 5 + 10) / cdm.barChartData.max * avg
    }
}

struct BarChart_Previews: PreviewProvider {
    static var previews: some View {
        @State var itemSelected = -1
        
        BarChart(itemSelected: $itemSelected)
            .environmentObject(CoreDataModel())
    }
}
