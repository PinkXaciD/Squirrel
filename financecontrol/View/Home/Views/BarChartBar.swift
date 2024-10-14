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
    let maxHeight: CGFloat
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .frame(height: maxHeight)
                .foregroundStyle(.secondary)
                .opacity(isActive ? 0.1 : 0.07)
            
            RoundedRectangle(cornerRadius: 5)
                .frame(height: data.value)
                .foregroundStyle(.primary)
                .opacity(isActive ? 1 : 0.7)
        }
        .hoverEffect()
    }
}

struct BarChartBar_Previews: PreviewProvider {
    static var previews: some View {
        BarChartBar(index: 1, data: (key: Date.now, value: 1.0), isActive: true, maxHeight: UIScreen.main.bounds.height / 5)
    }
}
