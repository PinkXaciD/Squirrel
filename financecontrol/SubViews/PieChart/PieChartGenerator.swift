//
//  PieChartGenerator.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/28.
//

import SwiftUI

struct PieChartGenerator: View {
    @EnvironmentObject var vm: CoreDataViewModel
        
    var body: some View {
        let operations = vm.operationsSum()
        let screenWidth: CGFloat = UIScreen.main.bounds.width
                
        if operations != 0 {
            PieChart(size: screenWidth/1.7)
        } else {
            EmptyPieChart(size: screenWidth/1.7)
        }
    }
}

struct PieChartGenerator_Previews: PreviewProvider {
    static var previews: some View {
        PieChartGenerator()
            .environmentObject(CoreDataViewModel())
    }
}
