//
//  CustomIcon.swift
//  financecontrol
//
//  Created by PinkXaciD on R 6/01/08.
//

import SwiftUI

enum CustomIcon: CaseIterable {
    case sqwoorl, firstFlight, neonNight, winterized, dawnOfSquipan, ghost, NA
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
        case .ghost:
            "Ghost"
        }
    }
    
    var description: LocalizedStringKey {
        switch self {
        case .sqwoorl:
            "Yes, that's his real name"
        case .firstFlight:
            "To the store!"
        case .neonNight:
            "It's probably all LED's nowadays"
        case .winterized:
            "Even a squirrel needs a hat in winter"
        case .dawnOfSquipan:
            "App of the rising sun"
        case .NA:
            "Everything that lives is designed to end. We are perpetually trapped in a never-ending spiral..."
        case .ghost:
            "Plays for the audience"
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
        case .ghost:
            "AppIcon_Ghost"
        }
    }
    
    var imageName: String {
        "\(fileName ?? "AppIcon")_Image"
    }
}
