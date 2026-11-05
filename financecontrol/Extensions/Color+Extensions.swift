//
//  ColorExtensions.swift
//  Squirrel
//
//  Created by PinkXaciD on 2023/09/11.
//

import SwiftUI
import Beige

extension Color {
    static subscript(name: String) -> Color {
        if name.hasPrefix("nord") {
            return CustomColor.nordAurora[name] ?? .black
        }
        
        let parsedNumber = name.split {
            !CharacterSet(charactersIn: "\($0)").isSubset(of: CharacterSet.decimalDigits)
        }.joined(separator: ".")
            
        if let hueValue = Double(parsedNumber) {
            return Color(lightness: 0.7, chroma: 0.15, hue: hueValue)
        }
        
        switch name {
        case "red":
            return .red
        case "orange":
            return .orange
        case "yellow":
            return .yellow
        case "green":
            return .green
        case "teal":
            return .teal
        case "blue":
            return .blue
        case "purple":
            return .purple
        case "pink":
            return .pink
        case "secondary":
            return .secondary
        default:
            return .clear
        }
    }
}
