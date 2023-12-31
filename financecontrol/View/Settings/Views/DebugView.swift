//
//  DebugView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/10.
//

import SwiftUI

struct DebugView: View {
    @EnvironmentObject
    private var rvm: RatesViewModel
    
    var body: some View {
        Form {
            infoPlistSection
            
            ratesFetchErrorSection
            
            urlErrorSection
            
            ratesSection
        }
        .navigationTitle("Debug")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var infoPlistSection: some View {
        Section {
            Button("Throw Info.plist error") {
                ErrorType(.noInfoFound).publish()
            }
            
            Button("Throw URL error") {
                ErrorType(.noURLFound).publish()
            }
            
            Button("Throw URL components error") {
                ErrorType(.failedToReadURLComponents).publish()
            }
            
            Button("Throw API key error") {
                ErrorType(.noAPIKeyFound).publish()
            }
        } header: {
            Text(verbatim: "Info.plist error")
        }
    }
    
    private var ratesFetchErrorSection: some View {
        Section {
            Button("Throw Empty database error") {
                ErrorType(RatesFetchError.emptyDatabase).publish()
            }
        } header: {
            Text(verbatim: "Rates fetch errors")
        }
    }
    
    private var urlErrorSection: some View {
        Section {
            Button("Throw URL bad response error") {
                ErrorType(URLError(.badServerResponse)).publish()
            }
            
            Button("Throw bad URL error") {
                ErrorType(URLError(.badURL)).publish()
            }
        } header: {
            Text(verbatim: "URL errors")
        }
    }
    
    private var ratesSection: some View {
        Section {
            VStack(alignment: .leading) {
                Text("Rates updated at:")
                
                Text(getDate(.update))
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading) {
                Text("Fallback rates timestamp:")
                
                Text(getDate(.fallback))
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("Rates")
        }
    }
}

extension DebugView {
    private enum DateType {
        case fallback, update
    }
    
    private func getDate(_ type: DateType) -> String {
        var dateFormatter: DateFormatter {
            let f = DateFormatter()
            f.dateStyle = .medium
            f.timeStyle = .long
            f.locale = Locale.current
            f.timeZone = Calendar.current.timeZone
            return f
        }
        
        var isoDateFromatter: ISO8601DateFormatter {
            let f = ISO8601DateFormatter()
            f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            f.timeZone = .gmt
            return f
        }
        
        switch type {
        case .fallback:
            let date: Date = isoDateFromatter.date(from: Rates.fallback.timestamp) ?? .distantPast
            return dateFormatter.string(from: date)
        case .update:
            let ratesUpdateTime: String = UserDefaults.standard.string(forKey: "updateTime") ?? "Error"
            let date: Date = isoDateFromatter.date(from: ratesUpdateTime) ?? .distantPast
            return dateFormatter.string(from: date)
        }
    }
}

#Preview {
    DebugView()
}
