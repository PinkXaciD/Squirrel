//
//  DebugView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/10.
//

import SwiftUI

struct DebugView: View {
    var body: some View {
        List {
            Section {
                
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
            } header: {
                Text("info.plist errors")
            }
            
            Section {
                
                Button("Throw Empty database error") {
                    ErrorType(localizedError: RatesFetchError.emptyDatabase).publish()
                }
            } header: {
                Text("Rates fetch errors")
            }
            
            Section {
                
                Button("Throw URL bad response error") {
                    ErrorType(urlError: URLError(.badServerResponse)).publish()
                }
                
                Button("Throw bad URL error") {
                    ErrorType(urlError: URLError(.badURL)).publish()
                }
            } header: {
                Text("URL errors")
            }
        }
    }
}

#Preview {
    DebugView()
}
