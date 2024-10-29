//
//  URL+Extensions.swift
//  Squirrel
//
//  Created by PinkXaciD on 2024/10/23.
//

import Foundation

extension URL {
    static let addExpenseAction: URL! = URL(string: "squirrel://addExpense")
    
    static let github: URL = {
        UserDefaults.standard.url(forKey: UDKey.githubURL.rawValue) ?? URL(string: "https://github.com/PinkXaciD/Squirrel")!
    }()
    
    static let newGithubIssue: URL! = URL(string: "\(github.absoluteString)/issues/new")
    
    static let appWebsite: URL = {
        UserDefaults.standard.url(forKey: UDKey.appWebsiteURL.rawValue) ?? URL(string: "https://squirrelapp.dev")!
    }()
    
    static let privacyPolicy: URL! = URL(string: "\(appWebsite.absoluteString)/privacy")
    
    static let appEmail: String = {
        guard let websiteURLString = URL.appWebsite.absoluteString.split(separator: "/").last else {
            return "contact@\(URL.appWebsite.absoluteString.replacingOccurrences(of: "https://", with: ""))"
        }
        
        return "contact@\(websiteURLString)"
    }()
}
