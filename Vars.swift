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
    
    static let appIdentifier: String = "dev.squirrelapp.squirrel"
    
    static let widgetIdentifier: String = "dev.squirrelapp.squirrel.squirrelWidget"
}

struct URLs {
    private init() {}
    
    static let addExpenseAction: URL! = URL(string: "squirrel://addExpense")
    
    static let github: URL! = URL(string: "https://github.com/PinkXaciD/Squirrel")
    
    static let newGithubIssue: URL! = URL(string: "https://github.com/PinkXaciD/Squirrel/issues/new")
}
