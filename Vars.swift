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
    
    static let firstAvailableDate: Date = Date(timeIntervalSinceReferenceDate: 599_529_600) // 2020/01/01, 0:00 GMT
}

struct URLs {
    private init() {}
    
    static let addExpenseAction: URL! = URL(string: "squirrel://addExpense")
    
    static let github: URL! = URL(string: "https://github.com/PinkXaciD/Squirrel")
    
    static let newGithubIssue: URL! = URL(string: "\(github.absoluteString)/issues/new")
    
    static let appSite: URL! = URL(string: "https://squirrelapp.dev")
    
    static let privacyPolicy: URL! = URL(string: "\(appSite.absoluteString)/privacy")
}

enum UDKeys: String {
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
}
