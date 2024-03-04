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
    let colors = CustomColor.nordAurora
    
    var body: some View {
        
        let columns = [
            GridItem(.flexible(minimum: 35, maximum: 50)),
            GridItem(.flexible(minimum: 35, maximum: 50)),
            GridItem(.flexible(minimum: 35, maximum: 50)),
            GridItem(.flexible(minimum: 35, maximum: 50)),
            GridItem(.flexible(minimum: 35, maximum: 50)),
            GridItem(.flexible(minimum: 35, maximum: 50)),
            GridItem(.flexible(minimum: 35, maximum: 50))
        ]
        
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(colors.compactMap{$0.key}.sorted{$0 < $1}, id: \.self) { colorDescription in
//                if colorDescription == colorSelectedDescription {
//                    ZStack {
//                        Image(systemName: "circle.fill")
//                            .resizable()
//                            .scaledToFit()
//                            .foregroundColor(colors[colorDescription])
//
//                        Image(systemName: "circle.fill")
//                            .resizable()
//                            .scaledToFit()
//                            .foregroundColor(Color(UIColor.systemGroupedBackground))
//                            .scaleEffect(0.9)
//
//                        Image(systemName: "circle.fill")
//                            .resizable()
//                            .scaledToFit()
//                            .foregroundColor(colors[colorDescription])
//                            .scaleEffect(0.8)
//                    }
//                    .onTapGesture {
//                        withAnimation(.linear(duration: 0.2)) {
//                            colorSelected = Color.clear
//                            colorSelectedDescription = ""
//                        }
//                    }
//                } else {
////                    Image(systemName: "circle.fill")
////                        .resizable()
////                        .scaledToFit()
////                        .foregroundColor(colors[colorDescription])
////                        .onTapGesture {
////                            withAnimation(.linear(duration: 0.2)) {
////                                colorSelected = colors[colorDescription] ?? Color.black
////                                colorSelectedDescription = colorDescription
////                            }
////                        }
//                    buttonLabel(colorDescription)
//                }
                Button {
                    buttonAction(colorDescription)
                } label: {
                    buttonLabel(colorDescription)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func buttonLabel(_ colorDescription: String) -> some View {
        Circle()
            .fill(colors[colorDescription] ?? .black)
            .overlay {
                Circle()
                    .stroke(lineWidth: colorDescription == colorSelectedDescription ? 3 : 0)
                    .foregroundColor(Color(uiColor: .secondarySystemGroupedBackground))
                    .opacity(colorDescription == colorSelectedDescription ? 1 : 0)
                    .scaleEffect(colorDescription == colorSelectedDescription ? 0.8 : 1)
            }
    }
    
    private func buttonAction(_ colorDescription: String) {
        withAnimation(.bouncy) {
            colorSelected = colors[colorDescription] ?? Color.black
            colorSelectedDescription = colorDescription
        }
    }
}

struct CustomColorSelectorPreviews: PreviewProvider {
    @State static var colorSelected: Color = .nordRed
    @State static var colorSelectedDescription: String = "nordRed"
    
    static var previews: some View {
        List {
            CustomColorSelector(colorSelected: $colorSelected, colorSelectedDescription: $colorSelectedDescription)
        }
    }
}
