//
//  Vars.swift
//  Squirrel
//
//  Created by PinkXaciD on 2024/01/17.
//

import Foundation

enum Vars {
    static let groupName: String = "group.dev.squirrelapp.squirrel"
    
    static let appIdentifier: String = Bundle.main.bundleIdentifier ?? "dev.squirrelapp.squirrel"
    
    static let widgetIdentifier: String = appIdentifier + ".squirrelWidget"
    
    static let iCloudContainerIdentifier: String = "iCloud.dev.squirrelapp.squirrel"
    
    static let privacyBlur: CGFloat = 10
}

enum CategoryColorValues {
    static let chroma: Double = 0.15
    
    static let darkModeLightness: Double = 0.73
    static let lightModeLightness: Double = 0.66
    
    static let lightnessModifier: Double = 0.06
    
    static let presetsHueSet: Set<Double> = [15, 55, 90, 130, 190, 260, 310]
}
