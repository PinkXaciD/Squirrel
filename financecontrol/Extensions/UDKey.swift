//
//  UDKeys.swift
//  Squirrel
//
//  Created by PinkXaciD on 2024/10/24.
//

import Foundation

enum UDKey: String {
    case presentOnboarding
    case color
    case defaultCurrency
    case defaultSelectedCurrency
    case savedCurrencies
    case minimizeLegend
    case rates
    case updateTime
    case updateRates
    case autoDarkMode
    case darkMode
    case privacyScreen
    case separateCurrencies
    case ratesFetchQueue
    case formatWithoutTimeZones
    case githubURL
    case appWebsiteURL
    case urlUpdateVersion
    case socialNetworksUpdateVersion
    case socialNetworksJSON
    
    static var urlKeys: [Self] {
        [.appWebsiteURL, .githubURL]
    }
    
    var ckID: String? {
        switch self {
        case .appWebsiteURL:
            "website"
        case .githubURL:
            "github"
        default:
            nil
        }
    }
}
