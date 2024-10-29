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
