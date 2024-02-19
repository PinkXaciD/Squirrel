//
//  CustomIcon.swift
//  financecontrol
//
//  Created by PinkXaciD on R 6/01/08.
//

import SwiftUI

enum CustomIcon: CaseIterable {
    case sqwoorl, firstFlight, neonNight, stealth, winterized, dawnOfSquipan, NA
}

extension CustomIcon {
    var displayName: LocalizedStringKey {
        switch self {
        case .sqwoorl:
            "Sqwoorl"
        case .firstFlight:
            "First Flight"
        case .neonNight:
            "Neon Night"
        case .winterized:
            "Winterized"
        case .dawnOfSquipan:
            "Dawn of Squipan"
        case .NA:
            "N:A"
        case .stealth:
            "Stealth"
        }
    }
    
    var description: LocalizedStringKey {
        switch self {
        case .sqwoorl:
            "Yes, that's his real name"
        case .firstFlight:
            "To the store!"
        case .neonNight:
            "Like neon glow at night"
        case .winterized:
            "Even a squirrel needs a hat in winter"
        case .dawnOfSquipan:
            "App of the rising sun"
        case .NA:
            "Everything that lives is designed to end. We are perpetually trapped in a never-ending spiral..."
        case .stealth:
            "No radar will find you now"
        }
    }
    
    var fileName: String? {
        switch self {
        case .sqwoorl:
            nil
        case .firstFlight:
            "AppIcon_FirstFlight"
        case .neonNight:
            "AppIcon_NeonNight"
        case .winterized:
            "AppIcon_Winterized"
        case .dawnOfSquipan:
            "AppIcon_DawnOfSquipan"
        case .NA:
            "AppIcon_NA"
        case .stealth:
            "AppIcon_Stealth"
        }
    }
    
    var imageName: String {
        "\(fileName ?? "AppIcon")_Image"
    }
}
