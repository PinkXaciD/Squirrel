//
//  ErrorHandler.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/08.
//

import Foundation

final class ErrorHandler: ObservableObject {
    
    static let instance = ErrorHandler()
    
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
    
    init(_ error: LocalizedError) {
        self.errorDescription = error.errorDescription ?? ""
        self.failureReason = error.failureReason ?? ""
        self.recoverySuggestion = error.recoverySuggestion ?? ""
        self.helpAnchor = error.helpAnchor ?? ""
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
            
        default:
            self.errorDescription = "URL failed: \(urlError.localizedDescription)"
            self.failureReason = urlError.localizedDescription
            self.recoverySuggestion = "Try to restart the app"
            self.helpAnchor = ""
        }
    }
    
    func publish() {
        
        let errorHandler = ErrorHandler.instance
        errorHandler.appError = self
        errorHandler.showAlert = true
    }
}
