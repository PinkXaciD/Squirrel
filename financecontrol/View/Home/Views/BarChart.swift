//
//  BarChart.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/08.
//

import SwiftUI

struct BarChart: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var cdm: CoreDataModel
    @Binding var itemSelected: Int
    @Binding var showAverage: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // MARK: Avg dashed line
                if !cdm.barChartData.sum.isZero {
                    Line()
                        .stroke(style: StrokeStyle(lineWidth: (showAverage ? 1.5 : 1), dash: [5]))
                        .frame(height: 2)
                        .offset(y: -(10 + countAvgBarHeight()))
                        .foregroundColor(.secondary.opacity(showAverage ? 0.7 : 0.3))
//                        .padding(.horizontal, countDashedLinePadding(geometry.size.width))
                }
                
                VStack {
                    HStack(alignment: .bottom, spacing: 18) {
                        ForEach(cdm.barChartData.bars.sorted(by: { $0.key < $1.key }), id: \.key) { data in
                            BarChartBar(
                                index: countIndex(data.key),
                                data: (key: data.key, value: countBarHeight(maxHeight: geometry.size.height - 25, value: data.value)),
                                isActive: isActive(index: countIndex(data.key)),
                                maxHeight: geometry.size.height - 25
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 5.01))
                            .onTapGesture {
                                tapActions(index: countIndex(data.key))
                            }
                        }
                    }
                    
                    HStack(spacing: 18) {
                        ForEach(cdm.barChartData.bars.keys.sorted(by: <), id: \.self) { date in
                            Text(date, format: .dateTime.weekday(horizontalSizeClass == .compact ? .abbreviated : .wide))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .animation(.smooth, value: cdm.barChartData)
            .padding(.horizontal, 10)
        }
        .frame(height: max(UIScreen.main.bounds.height, UIScreen.main.bounds.width) / 5 + 25)
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
    
    private func countBarHeight(maxHeight: CGFloat, value: Double) -> Double {
        let max = cdm.barChartData.max
        let height = maxHeight
        
        if max == 0 {
            return 0
        }
        
        return height / max * value
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
        let height = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
        return (height / 5 + 10) / cdm.barChartData.max * avg
    }
}

struct BarChart_Previews: PreviewProvider {
    static var previews: some View {
        @State var itemSelected = -1
        @State var showAverage = false
        
        BarChart(itemSelected: $itemSelected, showAverage: $showAverage)
            .environmentObject(CoreDataModel())
    }
}
