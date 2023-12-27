//
//  CustomColorSelector.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/09.
//

import Foundation
import SwiftUI

struct CustomColorSelector: View {
    
    @Binding var colorSelected: Color
    @Binding var colorSelectedDescription: String
    
    var body: some View {
        
        let colors = CustomColor.nordAurora
        
        let columns = [GridItem(.adaptive(minimum: 35))]
        
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(colors.compactMap{$0.key}.sorted{$0 < $1}, id: \.self) { colorDescription in
                if colorDescription == colorSelectedDescription {
                    ZStack {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(colors[colorDescription])

                        Image(systemName: "circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color(UIColor.systemGroupedBackground))
                            .scaleEffect(0.9)

                        Image(systemName: "circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(colors[colorDescription])
                            .scaleEffect(0.8)
                    }
                    .onTapGesture {
                        withAnimation(.linear(duration: 0.2)) {
                            colorSelected = Color.clear
                            colorSelectedDescription = ""
                        }
                    }
                } else {
                    Image(systemName: "circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(colors[colorDescription])
                        .onTapGesture {
                            withAnimation(.linear(duration: 0.2)) {
                                colorSelected = colors[colorDescription] ?? Color.black
                                colorSelectedDescription = colorDescription
                            }
                        }
                }
            }
        }
    }
}
