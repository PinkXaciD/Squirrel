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
    
    static let privacyBlur: CGFloat = 10
}

struct URLs {
    private init() {}
    
    static let addExpenseAction: URL! = URL(string: "squirrel://addExpense")
    
    static let github: URL! = URL(string: "https://github.com/PinkXaciD/Squirrel")
    
    static let newGithubIssue: URL! = URL(string: "https://github.com/PinkXaciD/Squirrel/issues/new")
}

enum UDKeys: String {
    case presentOnboarding, color, defaultCurrency, savedCurrencies, minimizeLegend, rates, updateTime, updateRates, autoDarkMode, darkMode, privacyScreen
}
