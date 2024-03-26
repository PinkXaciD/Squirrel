//
//  CoreDataErrors.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/02/21.
//

import Foundation

enum CoreDataError: LocalizedError {
    case failedToGetEntityDescription, failedToFindCategory
}

extension CoreDataError {
    var failureReason: String? {
        switch self {
        case .failedToGetEntityDescription:
            return NSLocalizedString("Failed to get CoreData entity description", comment: "")
        case .failedToFindCategory:
            return NSLocalizedString("Failed to find category for this spending", comment: "")
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .failedToGetEntityDescription, .failedToFindCategory:
            return NSLocalizedString("It seems some system files are corrupted", comment: "")
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .failedToGetEntityDescription, .failedToFindCategory:
            return NSLocalizedString("Please submit a bug report and try to restart or reinstall the app", comment: "")
        }
    }
}
