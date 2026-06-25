//
//  Vars.swift
//  financecontrol
//
//  Created by PinkXaciD on R 6/01/17.
//

import Foundation

struct Vars {
    private init() {}
    
    static let groupName: String = "group.dev.squirrelapp.squirrel"
    
    static let appIdentifier: String = Bundle.main.bundleIdentifier ?? "dev.squirrelapp.squirrel"
    
    static let widgetIdentifier: String = appIdentifier + ".squirrelWidget"
    
    static let iCloudContainerIdentifier: String = "iCloud.dev.squirrelapp.squirrel"
    
    static let privacyBlur: CGFloat = 10
}

struct CategoryColorValues {
    private init() {}
    
    static let chroma: Double = 0.15
    
    static let darkModeLightness: Double = 0.73
    static let lightModeLightness: Double = 0.66
    
    static let lightnessModifier: Double = 0.06
}
