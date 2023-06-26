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
                return Color.red
            case "orange":
                return Color.orange
            case "yellow":
                return Color.yellow
            case "green":
                return Color.green
            case "teal":
                return Color.teal
            case "blue":
                return Color.blue
            case "purple":
                return Color.purple
            case "pink":
                return Color.pink
            case "nord1", "nord2", "nord3", "nord4", "nord5", "nord6", "nord7", "nord8", "nord9", "nord91", "nord92", "nord93", "nord94", "nord95":
                return CustomColor.nordAurora[name] ?? Color.black
            default:
                return Color.clear
        }
    }
}
