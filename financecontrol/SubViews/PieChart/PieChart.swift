//
//  PieChart.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/26.
//

import SwiftUI
import ApplePie

struct PieChart: View {
    @EnvironmentObject private var vm: CoreDataViewModel
    @EnvironmentObject private var rvm: RatesViewModel
    
    @AppStorage("defaultCurrency") var defaultCurrency: String = "USD"
    
    @State private var scaleAnimation: CGFloat = 0.75
    
    let size: CGFloat
    
    var body: some View {
        let pcData = PieChartData(vm)
        let percentage = pcData.getPercentage()

        Section {
            VStack(spacing: 15) {
                GeometryReader { geometry in
                    
                    ZStack {
                        ApplePie().generatePie(chartData(UIScreen.main.bounds.width))
                        
                        CenterChartView(width: geometry.size.width)
                    }
                } // End of GR
                .frame(width: size, height: size)
                .onAppear(perform: appearActions)
                
                Divider()
                HStack {
                    VStack (alignment: .leading, spacing: 10){
                        ForEach(0..<percentage.count, id: \.self) { index in
                            
                            if let category = vm.findCategory(percentage[index].key) {
                                
                                HStack {
                                    Image(systemName: "circle.fill")
                                        .foregroundColor(Color[category.color ?? ""])
                                    
                                    Text("\(category.name ?? "Error"): \(String(format: "%.1f", percentage[index].value))%")
                                }
                                
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
    }
    
    private func chartData(_ screenWidth: CGFloat) -> ApplePieChartData {
//        let colors: [Color] = donutColors()
        let pcData = PieChartData(vm)
        
        var data: ApplePieChartData {
            var number = 0
            let data = pcData.getPercentage()
            var arr = [ApplePieChartPieceData]()
            for i in data {
                arr.append(ApplePieChartPieceData(i.value, Color[vm.findCategory(i.key)?.color ?? ""]))
                number += 1
            }
            
            let cd = ApplePieChartData(
                arr,
                backgroundColor: Color(UIColor.secondarySystemGroupedBackground),
                separators: true,
                donut: true,
                size: screenWidth/1.7
            )
            return cd
        }
        
        return data
    }
    
    private func appearActions() {
        withAnimation(.easeOut(duration: 0.15)) {
            scaleAnimation = 1
        }
    }
}

struct CenterChartView: View {
    @EnvironmentObject private var vm: CoreDataViewModel
    @EnvironmentObject private var rvm: RatesViewModel
    @AppStorage("defaultCurrency") var defaultCurrency: String = "USD"
    
    let width: CGFloat
    
    var body: some View {
        VStack(alignment: .center) {
            Text("All Expenses")
                .padding(.top, 10)
            
            Text(String(vm.operationsSum() * (rvm.rates[defaultCurrency] ?? 1)).currencyFormat)
                .lineLimit(1)
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .frame(maxWidth: width/1.4)
                .scaledToFit()
                .minimumScaleFactor(0.01)
            
            Text(defaultCurrency)
                .foregroundColor(Color.secondary)
        }
    }
}

struct PieChart_Previews: PreviewProvider {
    static var previews: some View {
        PieChart(size: 200)
            .environmentObject(CoreDataViewModel())
    }
}
