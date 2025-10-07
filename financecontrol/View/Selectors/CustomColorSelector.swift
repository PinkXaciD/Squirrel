//
//  CustomColorSelector.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/09.
//

import Foundation
import SwiftUI

struct CustomColorSelector: View {
    
    @Binding var colorSelectedDescription: String
    let colors = CustomColor.nordAurora
    
    var body: some View {
        
        let columns: [GridItem] = Array(repeating: .init(.flexible(minimum: 35, maximum: 50), spacing: 10, alignment: .center), count: 7)
        
        LazyVGrid(columns: columns) {
            ForEach(colors.compactMap{$0.key}.sorted{$0 < $1}, id: \.self) { colorDescription in
                Button {
                    buttonAction(colorDescription)
                } label: {
                    if #available(iOS 26.0, *) {
                        newButtonLabel(colorDescription)
                    } else {
                        buttonLabel(colorDescription)
                    }
                }
                .buttonStyle(.plain)
                .contentShape(.hoverEffect, Circle())
                .hoverEffect(.lift)
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
            .frame(minWidth: 35, maxWidth: 50, minHeight: 35, maxHeight: 50)
    }
    
    @available(iOS 26.0, *)
    private func newButtonLabel(_ colorDescription: String) -> some View {
        Circle()
            .fill(colors[colorDescription] ?? .black)
            .overlay {
                Circle()
                    .stroke(lineWidth: colorDescription == colorSelectedDescription ? 3 : 0)
                    .foregroundColor(Color(uiColor: .secondarySystemGroupedBackground))
                    .opacity(colorDescription == colorSelectedDescription ? 1 : 0)
                    .scaleEffect(colorDescription == colorSelectedDescription ? 0.8 : 1)
            }
            .glassEffect(.regular, in: Circle())
            .frame(minWidth: 35, maxWidth: 50, minHeight: 35, maxHeight: 50)
    }
    
    private func buttonAction(_ colorDescription: String) {
        withAnimation(.bouncy) {
            colorSelectedDescription = colorDescription
        }
    }
}

struct CustomColorSelectorPreviews: PreviewProvider {
    static var previews: some View {
        CustomColorSelectorPreview()
    }
}

fileprivate struct CustomColorSelectorPreview: View {
    @State var colorSelectedDescription: String = "nordRed"
    
    var body: some View {
        List {
            CustomColorSelector(colorSelectedDescription: $colorSelectedDescription)
        }
    }
}
