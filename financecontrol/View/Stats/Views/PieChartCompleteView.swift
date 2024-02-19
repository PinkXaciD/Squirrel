//
//  PieChartCompleteView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 6/02/03.
//

import SwiftUI
import ApplePie

struct PieChartCompleteView<Content: View>: View {
    @Environment(\.layoutDirection) private var layoutDirection
    let chart: APChart
    let center: Content
    let count: Int
    let size: CGFloat
    
    var body: some View {
        ZStack {
            chart
                .frame(width: size, height: size)
                .rotationEffect(layoutDirection == .rightToLeft ? Angle(degrees: 180) : Angle(degrees: 0))
            
            center
        }
    }
}
