//
//  Formatters.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/13.
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

func themeConvert(_ theme: String) -> ColorScheme? {
    switch theme {
    case "light":
        return ColorScheme.light
    case "dark":
        return ColorScheme.dark
    default:
        return nil
    }
}
