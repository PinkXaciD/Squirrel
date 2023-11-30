//
//  ErrorHandler.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/08.
//

import Foundation

final class ErrorHandler: ObservableObject {
    
    static let shared = ErrorHandler()
    
    @Published var appError: ErrorType? = nil
    @Published var showAlert: Bool = false
    
    func dropError() {
        appError = nil
        showAlert = false
    }
}

struct ErrorType: Identifiable, Equatable {
    
    let id: UUID = UUID()
    let errorDescription: String
    let failureReason: String
    let recoverySuggestion: String
    let helpAnchor: String
    var createIssue: Bool = true
    
    init(error: Error) {
        self.errorDescription = "Unknown error: \(error.localizedDescription)"
        self.failureReason = error.localizedDescription
        self.recoverySuggestion = "Please submit bug report and try to restart the app"
        self.helpAnchor = ""
    }
    
    init(localizedError: LocalizedError) {
        self.errorDescription = localizedError.errorDescription ?? ""
        self.failureReason = localizedError.failureReason ?? ""
        self.recoverySuggestion = localizedError.recoverySuggestion ?? ""
        self.helpAnchor = localizedError.helpAnchor ?? ""
    }
    
    init(infoPlistError: InfoPlistError) {
        self.errorDescription = infoPlistError.errorDescription
        self.failureReason = infoPlistError.failureReason
        self.recoverySuggestion = infoPlistError.recoverySuggestion
        self.helpAnchor = infoPlistError.helpAnchor ?? ""
    }
    
    init(urlError: URLError) {
        switch urlError {
        case URLError(.badURL):
            self.errorDescription = "Can't reach requested URL"
            self.failureReason = urlError.localizedDescription
            self.recoverySuggestion = "Try to restart the app"
            self.helpAnchor = ""
            
        case URLError(.badServerResponse):
            self.errorDescription = "Requested URL responsed with code \(urlError.errorCode)"
            self.failureReason = urlError.localizedDescription
            self.recoverySuggestion = "Try to restart the app"
            self.helpAnchor = ""
            
        case URLError(.notConnectedToInternet):
            self.errorDescription = urlError.localizedDescription
            self.failureReason = urlError.localizedDescription
            self.recoverySuggestion = "Check your internet connection"
            self.helpAnchor = ""
            self.createIssue = false
            
        default:
            self.errorDescription = urlError.localizedDescription
            self.failureReason = urlError.localizedDescription
            self.recoverySuggestion = "Try to restart the app"
            self.helpAnchor = ""
        }
    }
    
    init(errorDescription: String, failureReason: String, recoverySuggestion: String, helpAnchor: String = "") {
        self.errorDescription = errorDescription
        self.failureReason = failureReason
        self.recoverySuggestion = recoverySuggestion
        self.helpAnchor = helpAnchor
        self.createIssue = false
    }
    
    func publish() {
        ErrorHandler.shared.appError = self
        ErrorHandler.shared.showAlert = true
    }
}
