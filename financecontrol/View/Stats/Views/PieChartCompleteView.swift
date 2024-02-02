//
//  PieChartCompleteView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 6/02/03.
//

import SwiftUI
import ApplePie

struct PieChartCompleteView<Content: View>: View {
    let chart: APChart
    let center: Content
    let count: Int
    
    var body: some View {
        ZStack {
            chart
            
            center
        }
    }
}
