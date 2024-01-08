//
//  CustomIcon.swift
//  financecontrol
//
//  Created by PinkXaciD on R 6/01/08.
//

import SwiftUI

enum CustomIcon {
    case sqwoorl, firstFlight, neonNight, winterized, dawnOfSquipan, NA
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
        }
    }
    
    var description: LocalizedStringKey {
        switch self {
        case .sqwoorl:
            "Yes, that's his real name"
        case .firstFlight:
            "To the store!"
        case .neonNight:
            ""
        case .winterized:
            "Even a squirrel needs a hat in winter"
        case .dawnOfSquipan:
            "App of the rising sun"
        case .NA:
            "Everything that lives is designed to end. We are perpetually trapped in a never-ending spiral..."
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
        }
    }
    
    var imageName: String {
        switch self {
        case .sqwoorl:
            "AppIcon_Image"
        default:
            "\(fileName ?? "")_Image"
        }
    }
}
