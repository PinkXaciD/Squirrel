//
//  PieChart.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/20.
//

import SwiftUI

/// Drawing new arc for PieChart, takes startDegree of type Double and endDegree of type Double
struct PieChartPiece: Shape {
    let startDegree: Double
    let endDegree: Double
    
    func path(in rect: CGRect) -> Path {
        Path { p in
            let center = CGPoint(x: rect.midX, y: rect.midY)
            p.move(to: center)
            p.addArc(
                center: center,
                radius: rect.width / 2,
                startAngle: Angle(degrees: startDegree),
                endAngle: Angle(degrees: endDegree),
                clockwise: false
            )
            p.closeSubpath()
        }
    }
}

struct PieChartPiece_Previews: PreviewProvider {
    static var previews: some View {
        PieChartPiece(startDegree: 0.0, endDegree: 190.0)
    }
}
