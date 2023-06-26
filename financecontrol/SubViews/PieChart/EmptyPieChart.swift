//
//  EmptyPieChart.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/26.
//

import SwiftUI

struct EmptyPieChart: View {
    @State private var scaleAnimation: CGFloat = 0.75
    
    let size: CGFloat
    
    var body: some View {
        
        HStack {
            Spacer()
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let innerWidth = width/1.4
                
                ZStack {
                    Circle() // Empty pie
                        .frame(width: width, height: height)
                        .foregroundColor(Color(UIColor.systemGroupedBackground))
                        .scaleEffect(scaleAnimation)
                    
                    Circle() // Inner circle
                        .frame(width: innerWidth)
                        .foregroundColor(Color(UIColor.secondarySystemGroupedBackground))
                    
                    Text("No operations")
                        .font(.system(size: 30, weight: .semibold))
                        .lineLimit(1)
                        .frame(maxWidth: innerWidth*0.9)
                        .scaledToFit()
                        .minimumScaleFactor(0.5)
                }
            }
            .frame(width: size, height: size, alignment: .center)
            .onAppear(perform: appearActions)
            .onDisappear(perform: disappearActions)
            Spacer()
        }
    }
    
    func appearActions() {
        withAnimation(.easeOut(duration: 0.2)) {
            scaleAnimation = 1
        }
    }
    
    func disappearActions() {
        scaleAnimation = 0.75
    }
}

struct EmptyPieChart_Previews: PreviewProvider {
    static var previews: some View {
        EmptyPieChart(size: UIScreen.main.bounds.width/1.7)
    }
}
