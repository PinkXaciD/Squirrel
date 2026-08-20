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
    
    @Binding
    private var oklch: OKLCH
    
    private let usedColors: [OKLCH]
    private let unusedColors: [Double]
    
    private var presets: [OKLCH] {
        let lightness = colorScheme.colorLightness
        
        return [
            OKLCH(lightness: lightness, chroma: CategoryColorValues.chroma, hue: 15),
            OKLCH(lightness: lightness, chroma: CategoryColorValues.chroma, hue: 55),
            OKLCH(lightness: lightness, chroma: CategoryColorValues.chroma, hue: 90),
            OKLCH(lightness: lightness, chroma: CategoryColorValues.chroma, hue: 130),
            OKLCH(lightness: lightness, chroma: CategoryColorValues.chroma, hue: 190),
            OKLCH(lightness: lightness, chroma: CategoryColorValues.chroma, hue: 260),
            OKLCH(lightness: lightness, chroma: CategoryColorValues.chroma, hue: 310)
        ]
    }
    
    private var lightnessModifier: Double {
        let lightness = colorScheme.colorLightness
        return lightness - 0.7
    }
    
    init(oklch: Binding<OKLCH>, usedColors: [OKLCH], unusedColors: [Double]) {
        self._oklch = oklch
        self.unusedColors = unusedColors
        
        let presetsHueSet = CategoryColorValues.presetsHueSet
        
        self.usedColors = usedColors.filter { color in
            !presetsHueSet.contains(color.h.rounded())
        }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .top, pinnedViews: .sectionHeaders) {
                Section {
                    randomButton
                        .frame(width: pickerSize)
                        .padding(.top, 15)
                }
                
                HStack(spacing: 0) {
                    Divider()
                        .padding(.top, 10)
                        .padding(.leading, 3)
                        .padding(.trailing, -2)
                }
                
                Section {
                    HStack {
                        presetsView
                            .frame(height: pickerSize + 10)
                            .padding(.top, 10)
                    }
                    .padding(.leading, -45)
                } header: {
                    Text("Presets")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .offset(x: 9, y: -8)
                }
                
                HStack(spacing: 0) {
                    Divider()
                        .padding(.top, 10)
                        .padding(.leading, 3)
                        .padding(.trailing, -2)
                }
                
                if !usedColors.isEmpty {
                    Section {
                        HStack {
                            usedColorsView
                        }
                        .frame(height: pickerSize + 10)
                        .padding(.top, 10)
                        .padding(.leading, -30)
                    } header: {
                        Text("Used")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .offset(x: 9, y: -8)
                    }
                } else {
                    Text("Already used colors will appear here")
                        .foregroundStyle(.secondary)
                        .frame(height: pickerSize + 10)
                        .padding(.top, 10)
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
    
    private var randomButton: some View {
        Button {
            oklch = OKLCH(lightness: colorScheme.colorLightness, chroma: 0.15, hue: getUnusedColor())
        } label: {
            Circle()
                .fill(OKLCH(lightness: colorScheme.colorLightness, chroma: CategoryColorValues.chroma, hue: oklch.h).color)
                .overlay {
                    Image(systemName: "shuffle")
                        .foregroundStyle(.white)
                }
                .contentShape(.hoverEffect, Circle())
                .hoverEffect(.lift)
        }
        .buttonStyle(.plain)
        .frame(height: pickerSize)
    }
    
    private var presetsView: some View {
        ForEach(presets, id: \.self) { color in
            Button {
                oklch = OKLCH(lightness: colorScheme.colorLightness, chroma: 0.15, hue: color.h)
            } label: {
                Circle()
                    .fill(OKLCH(lightness: colorScheme.colorLightness, chroma: CategoryColorValues.chroma, hue: color.h).color)
                    .frame(width: pickerSize)
                    .overlay {
                        Circle()
                            .stroke(lineWidth: oklch.h == color.h ? 3 : 0)
                            .foregroundColor(Color(uiColor: .secondarySystemGroupedBackground))
                            .opacity(oklch.h == color.h ? 1 : 0)
                            .scaleEffect(oklch.h == color.h ? 0.8 : 1)
                    }
                    .animation(.default, value: oklch)
                    .contentShape(.hoverEffect, Circle())
                    .hoverEffect(.lift)
            }
            .buttonStyle(.plain)
            .id(color.h)
        }
    }
    
    private var usedColorsView: some View {
        ForEach(usedColors, id: \.self) { color in
            Button {
                oklch = OKLCH(lightness: colorScheme.colorLightness, chroma: 0.15, hue: color.h)
            } label: {
                Circle()
                    .fill(OKLCH(lightness: colorScheme.colorLightness, chroma: CategoryColorValues.chroma, hue: color.h).color)
                    .frame(width: pickerSize)
                    .overlay {
                        Circle()
                            .stroke(lineWidth: oklch.h == color.h ? 3 : 0)
                            .foregroundColor(Color(uiColor: .secondarySystemGroupedBackground))
                            .opacity(oklch.h == color.h ? 1 : 0)
                            .scaleEffect(oklch.h == color.h ? 0.8 : 1)
                    }
                    .animation(.default, value: oklch)
                    .contentShape(.hoverEffect, Circle())
                    .hoverEffect(.lift)
            }
            .buttonStyle(.plain)
            .id(color.h)
        }
    }
    
    private func getUnusedColor() -> Double {
        guard unusedColors.count > 1 else {
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
    var body: some View {
        List {
            CustomColorSelector(oklch: .constant(.init(lightness: 0.7)), usedColors: [], unusedColors: [])
        }
    }
}
