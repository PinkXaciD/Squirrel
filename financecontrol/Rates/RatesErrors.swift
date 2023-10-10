//
//  RatesErrors.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/26.
//

import Foundation

public enum InfoPlistError: Error, LocalizedError {
    case noInfoFound
    case noURLFound
    case noAPIKeyFound
    case failedToReadURLComponents
}

extension InfoPlistError {
    public var failureReason: String {
        switch self {
        case .noInfoFound:
            return NSLocalizedString("No Info file was found", comment: "")
        case .noURLFound:
            return NSLocalizedString("No URL was found", comment: "")
        case .noAPIKeyFound:
            return NSLocalizedString("No API key was found", comment: "")
        case .failedToReadURLComponents:
            return NSLocalizedString("Failed to create URL from given components", comment: "")
        }
        
    }
    
    public var errorDescription: String {
        switch self {
        case .noInfoFound, .failedToReadURLComponents:
            return NSLocalizedString("It seems some system files are missing or corrupted", comment: "")
        case .noURLFound, .noAPIKeyFound:
            return NSLocalizedString("It seems some system files are corrupted", comment: "")
        }
    }
    
    public var recoverySuggestion: String {
        switch self {
        case .noInfoFound, .failedToReadURLComponents:
            return NSLocalizedString("Please submit bug report and try to reinstall the app", comment: "")
        case .noURLFound, .noAPIKeyFound:
            return NSLocalizedString("Please submit bug report and try to restart the app", comment: "")
        }
    }
}

extension InfoPlistError {
    
    func errorType() -> ErrorType {
        switch self {
        case .failedToReadURLComponents:
            return ErrorType(infoPlistError: .failedToReadURLComponents)
        case .noAPIKeyFound:
            return ErrorType(infoPlistError: .noAPIKeyFound)
        case .noInfoFound:
            return ErrorType(infoPlistError: .noInfoFound)
        case .noURLFound:
            return ErrorType(infoPlistError: .noURLFound)
        }
    }
}

enum RatesFetchError: LocalizedError {
    case emptyDatabase
}

extension RatesFetchError {
    var errorDescription: String {
        switch self {
        case .emptyDatabase:
            return NSLocalizedString("It seems some system files are missing or corrupted", comment: "")
        }
    }
    
    var recoverySuggestion: String {
        switch self {
        case .emptyDatabase:
            return NSLocalizedString("Please submit bugreport and try to reinstall the app", comment: "")
        }
    }
}
