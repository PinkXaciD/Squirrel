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
}

struct URLs {
    private init() {}
    
    static let addExpenseAction: URL! = URL(string: "squirrel://addExpense")
    
    static let github: URL! = URL(string: "https://github.com/PinkXaciD/Squirrel")
    
    static let newGithubIssue: URL! = URL(string: "https://github.com/PinkXaciD/Squirrel/issues/new")
}

struct UDKeys {
    private init() {}
    
    static let presentOnboarding = "presentOnboarding"
    
    static let color = "color"
    
    @available(*, deprecated, message: "Use boolean values `autoDarkMode` and `darkMode`")
    static let theme = "theme"
    
    static let defaultCurrency = "defaultCurrency"
    
    static let savedCurrencies = "savedCurrencies"
    
    static let minimizeLegend = "minimizeLegend"
    
    static let rates = "rates"
    
    static let updateTime = "updateTime"
    
    static let updateRates = "updateRates"
    
    static let addExpenseAction = "addExpenseAction"
    
    static let autoDarkMode = "autoDarkMode"
    
    static let darkMode = "darkMode"
}
