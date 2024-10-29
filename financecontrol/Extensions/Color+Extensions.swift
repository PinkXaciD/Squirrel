//
//  ColorExtensions.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/11.
//

import SwiftUI

extension Color {
    static subscript(name: String) -> Color {
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
        case "nord1", "nord2", "nord3", "nord4", "nord5", "nord6", "nord7", "nord8", "nord9", "nord91", "nord92", "nord93", "nord94", "nord95":
            return CustomColor.nordAurora[name] ?? .black
        case "secondary":
            return .secondary
        default:
            return .clear
        }
    }
}
