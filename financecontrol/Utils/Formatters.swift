//
//  Formatters.swift
//  Squirrel
//
//  Created by PinkXaciD on 2023/07/13.
//

import SwiftUI

func colorIdentifier(color: String) -> Color {
    switch color {
    case "Blue":
        return Color.blue
    case "Red":
        return Color.red
    case "Pink":
        return Color.pink
    case "Mint":
        return Color.mint
    case "Orange":
        return Color.orange
    case "Purple":
        return Color.purple
    case "Indigo":
        return Color.indigo
    case "Teal":
        return Color.teal
    default:
        return Color.accentColor
    }
}

enum TintColor: String {
    case blue, red, pink, mint, orange, purple, indigo, teal
    
    init?(rawValue: String) {
        switch rawValue {
        case "Blue":
            self = .blue
        case "Red":
            self = .red
        case "Pink":
            self = .pink
        case "Mint":
            self = .mint
        case "Purple":
            self = .purple
        case "Indigo":
            self = .indigo
        case "Teal":
            self = .teal
        default:
            self = .orange
        }
    }
    
    func getColor() -> Color {
        switch self {
        case .blue:
            .blue
        case .red:
            .red
        case .pink:
            .pink
        case .mint:
            .mint
        case .orange:
            .orange
        case .purple:
            .purple
        case .indigo:
            .indigo
        case .teal:
            .teal
        }
    }
}

func themeConvert(autoDarkMode: Bool, darkMode: Bool) -> ColorScheme? {
    if autoDarkMode {
        return nil
    }
    
    if darkMode {
        return .dark
    } else {
        return .light
    }
}
