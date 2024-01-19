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
    
    @State
    private var defaultsConfinationIsShowing: Bool = false
    @State
    private var timelineConfinationIsShowing: Bool = false
    
    var body: some View {
        Form {
            infoPlistSection
            
            ratesFetchErrorSection
            
            urlErrorSection
            
            ratesSection
            
            defaultsSection
            
            reloadWidgetsSection
        }
        .confirmationDialog("This will clear all settings of app. \nYou can't undo this action.", isPresented: $defaultsConfinationIsShowing, titleVisibility: .visible) {
            clearSharedDefaultsButton
            
            clearStandartDefaultsButton
        }
        .confirmationDialog("", isPresented: $timelineConfinationIsShowing) {
            Button("Reload all widget timelines", role: .destructive, action: WidgetsManager.shared.reloadAll)
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
            .normalizePadding()
            
            VStack(alignment: .leading) {
                Text("Fallback rates timestamp:")
                
                Text(getDate(.fallback))
                    .foregroundColor(.secondary)
            }
            .normalizePadding()
        } header: {
            Text("Rates")
        }
    }
    
    private var defaultsSection: some View {
        Section {
            Button(role: .destructive) {
                defaultsConfinationIsShowing.toggle()
            } label: {
                Text("Clear UserDefaults")
            }
        }
    }
    
    private var clearStandartDefaultsButton: some View {
        Button(role: .destructive) {
            clearStandartUserDefaults()
        } label: {
            Text("Clear standart UserDefaults")
        }
    }
    
    private var clearSharedDefaultsButton: some View {
        Button("Clear shared UserDefaults", role: .destructive) {
            clearSharedUserDefaults()
        }
    }
    
    private var reloadWidgetsSection: some View {
        Button(role: .destructive) {
            timelineConfinationIsShowing.toggle()
        } label: {
            Text("Reload all widget timelines")
        }
    }
    
    private func clearStandartUserDefaults() {
        let keys: [String] = ["defaultCurrency", "rates", "updateTime", "updateRates", "updateTime", "color", "theme"]
        
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
    private func clearSharedUserDefaults() {
        let keys: [String] = ["amount", "date"]
        let defaults: UserDefaults? = .init(suiteName: Vars.groupName)
        
        for key in keys {
            defaults?.removeObject(forKey: key)
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
            f.timeZone = .init(secondsFromGMT: 0)
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
