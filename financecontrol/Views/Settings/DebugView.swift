//
//  DebugView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/10.
//

import SwiftUI

struct DebugView: View {
    var body: some View {
        Form {
            infoPlistSection
            
            ratesFetchErrorSection
            
            urlErrorSection
        }
    }
    
    private var infoPlistSection: some View {
        Section(header: Text("Info.plist error")) {
            
            Button("Throw Info.plist error") {
                ErrorType(infoPlistError: .noInfoFound).publish()
            }
            
            Button("Throw URL error") {
                ErrorType(infoPlistError: .noURLFound).publish()
            }
            
            Button("Throw URL components error") {
                ErrorType(infoPlistError: .failedToReadURLComponents).publish()
            }
            
            Button("Throw API key error") {
                ErrorType(infoPlistError: .noAPIKeyFound).publish()
            }
        }
    }
    
    private var ratesFetchErrorSection: some View {
        Section(header: Text("Rates fetch errors")) {
            
            Button("Throw Empty database error") {
                ErrorType(localizedError: RatesFetchError.emptyDatabase).publish()
            }
        }
    }
    
    private var urlErrorSection: some View {
        Section(header: Text("URL errors")) {
            
            Button("Throw URL bad response error") {
                ErrorType(urlError: URLError(.badServerResponse)).publish()
            }
            
            Button("Throw bad URL error") {
                ErrorType(urlError: URLError(.badURL)).publish()
            }
        }
    }
}

#Preview {
    DebugView()
}
