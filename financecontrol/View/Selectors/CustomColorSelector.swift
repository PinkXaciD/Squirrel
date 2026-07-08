//
//  CustomColorSelector.swift
//  Squirrel
//
//  Created by PinkXaciD on 2023/09/09.
//

import SwiftUI
import Beige

struct CustomColorSelector: View {
    @Environment(\.colorScheme)
    private var colorScheme
    @Environment(\.colorSchemeContrast)
    private var colorSchemeContrast
    
    @ScaledMetric
    private var pickerSize: CGFloat = 40
    
    @Binding var oklch: OKLCH
    
    let usedColors: [OKLCH]
    let unusedColors: [Double]
    
    private var padding: CGFloat {
        if #available(iOS 26.0, *) {
            return 5
        }
        
        return 0
    }
    
    private var tintColor: Color {
        switch colorScheme {
        case .dark:
            return oklch.shift(lightness: CategoryColorValues.darkModeLightness - 0.7).color
        default:
            return oklch.shift(lightness: CategoryColorValues.lightModeLightness - 0.7).color
        }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Button {
                    oklch = .init(lightness: 0.7, chroma: 0.15, hue: getUnusedColor())
                } label: {
                    Circle()
                        .fill(tintColor)
                        .frame(width: pickerSize)
                        .overlay {
                            Image(systemName: "shuffle")
                                .foregroundStyle(.white)
                        }
                }
                .buttonStyle(.plain)
                
                Divider()
                
                if !usedColors.isEmpty {
                    usedColorsView
                } else {
                    Text("Already used colors will appear here")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        
        BeigeColorPicker(color: $oklch)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .frame(height: pickerSize)
            .padding()
    }
    
    private var usedColorsView: some View {
        ForEach(usedColors, id: \.self) { color in
            Button {
                oklch = color
            } label: {
                Circle()
                    .fill(color.color)
                    .frame(width: pickerSize)
                    .overlay {
                        Circle()
                            .stroke(lineWidth: oklch.h == color.h ? 3 : 0)
                            .foregroundColor(Color(uiColor: .secondarySystemGroupedBackground))
                            .opacity(oklch.h == color.h ? 1 : 0)
                            .scaleEffect(oklch.h == color.h ? 0.8 : 1)
                    }
                    .animation(.default, value: oklch)
            }
            .buttonStyle(.plain)
        }
    }
    
    private func getUnusedColor() -> Double {
        guard !unusedColors.isEmpty else {
            return Double((0...360).randomElement() ?? 0)
        }
        
        guard var result = unusedColors.randomElement() else {
            return 0
        }
        
        while result == oklch.h {
            result = unusedColors.randomElement() ?? -1
        }
        
        return result
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
            CustomColorSelector(oklch: .constant(.init(lightness: 0.7)), usedColors: [], unusedColors: [])
        }
    }
}
