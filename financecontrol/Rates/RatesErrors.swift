//
//  RatesErrors.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/26.
//

import Foundation

enum APIURLError: LocalizedError {
    case noInfoFound
    case noURLFound
}

extension APIURLError {
    var errorDescription: String {
        switch self {
        case .noInfoFound:
            "No Info file was found"
        case .noURLFound:
            "No URL was found"
        }
        
    }
    
    var recoverySuggestion: String {
        switch self {
        case .noInfoFound:
            "Please submit bug report and try to reinstall the app"
        case .noURLFound:
            "Please submit bug report and try to restart the app"
        }
    }
}
