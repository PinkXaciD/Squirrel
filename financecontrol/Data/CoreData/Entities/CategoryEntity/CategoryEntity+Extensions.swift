//
//  CategoryEntity+Extensions.swift
//  Squirrel
//
//  Created by PinkXaciD on 2026/06/22.
//

import SwiftUI
import Beige

extension CategoryEntity {
    @MainActor
    func resolveColor(colorScheme: ColorScheme, increaseContrast: ColorSchemeContrast) -> Color {
        guard let color else {
            return Color(lightness: 0, a: 0, b: 0)
        }
        
        let hue = Double(color) ?? Color[color].oklch().h
        
        var lightnessModifier: Double = 0
        
        if increaseContrast == .increased {
            if colorScheme == .light {
                lightnessModifier -= CategoryColorValues.lightnessModifier * 2
            } else {
                lightnessModifier += CategoryColorValues.lightnessModifier * 2
            }
        }
        
        return .init(
            lightness: colorScheme.colorLightness + lightnessModifier,
            chroma: CategoryColorValues.chroma,
            hue: hue
        )
    }
}
