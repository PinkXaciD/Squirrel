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
    @EnvironmentObject
    private var cdm: CoreDataModel
    
    @State
    private var defaultsConfirmationIsShowing: Bool = false
    @State
    private var timelineConfirmationIsShowing: Bool = false
    @State
    private var validateConfirmationIsShowing: Bool = false
    
    var body: some View {
        Form {
            errorsSection
            
            ratesSection
            
            bundleSection
            
            defaultsSection
            
            reloadWidgetsSection
            
            validateSection
        }
        .confirmationDialog("This will clear all settings of app. \nYou can't undo this action.", isPresented: $defaultsConfirmationIsShowing, titleVisibility: .visible) {
            clearSharedDefaultsButton
            
            clearStandartDefaultsButton
        }
        .confirmationDialog("", isPresented: $timelineConfirmationIsShowing) {
            Button("Reload all widget timelines", role: .destructive, action: WidgetsManager.shared.reloadAll)
        }
        .confirmationDialog("", isPresented: $validateConfirmationIsShowing) {
            Button("Validate returns", role: .destructive) {
                cdm.validateReturns(rvm: rvm)
            }
        }
        .navigationTitle("Debug")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var errorsSection: some View {
        Section {
            NavigationLink("Errors") {
                List {
                    infoPlistSection
                    
                    ratesFetchErrorSection
                    
                    urlErrorSection
                    
                    coreDataErrorSection
                }
                .navigationTitle("Errors")
            }
        } header: {
            Text("Errors")
        }
    }
    
    private var infoPlistSection: some View {
        Section {
            Button("Throw Info.plist error") {
                ErrorType(InfoPlistError.noInfoFound).publish()
            }
            
            Button("Throw URL error") {
                ErrorType(InfoPlistError.noURLFound).publish()
            }
            
            Button("Throw URL components error") {
                ErrorType(InfoPlistError.failedToReadURLComponents).publish()
            }
            
            Button("Throw API key error") {
                ErrorType(InfoPlistError.noAPIKeyFound).publish()
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
    
    private var coreDataErrorSection: some View {
        Section {
            Button("Throw entity description error") {
                ErrorType(CoreDataError.failedToGetEntityDescription).publish()
            }
            
            Button("Throw category error") {
                ErrorType(CoreDataError.failedToFindCategory).publish()
            }
        } header: {
            Text(verbatim: "CoreData errors")
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
            
            #if DEBUG
            Button(role: .destructive) {
                let rm = RatesModel()
                Task {
                    try await rm.downloadRates(timestamp: Date())
                }
            } label: {
                Text(verbatim: "Fetch rates")
            }
            #endif
        } header: {
            Text("Rates")
        }
    }
    
    private var bundleSection: some View {
        Section {
            VStack(alignment: .leading) {
                Text("Identifier:")
                
                Text(Bundle.main.bundleIdentifier ?? "Error")
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("Bundle")
        }
        .onTapGesture(count: 2) {
            UIPasteboard.general.string = Bundle.main.bundleIdentifier
            HapticManager.shared.impact(.rigid)
        }
    }
    
    private var defaultsSection: some View {
        Section {
            #if DEBUG
            NavigationLink {
                UserDefaultsValuesView(defaults: .standard)
            } label: {
                Text(verbatim: "UserDefaults values")
            }
            #endif
            
            Button(role: .destructive) {
                defaultsConfirmationIsShowing.toggle()
            } label: {
                Text("Clear UserDefaults")
            }
        }
    }
    
    private var validateSection: some View {
        Section {
            Button(role: .destructive) {
                validateConfirmationIsShowing.toggle()
            } label: {
                Text("Validate returns")
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
            timelineConfirmationIsShowing.toggle()
        } label: {
            Text("Reload all widget timelines")
        }
    }
    
    private func clearStandartUserDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
        if UserDefaults.standard.dictionaryRepresentation().isEmpty {
            HapticManager.shared.notification(.success)
        } else {
            HapticManager.shared.notification(.warning)
        }
    }
    
    private func clearSharedUserDefaults() {
        let defaults = UserDefaults(suiteName: Vars.groupName)
        let dictionary = defaults?.dictionaryRepresentation()
        dictionary?.keys.forEach { key in
            defaults?.removeObject(forKey: key)
        }
        if let dict = defaults?.dictionaryRepresentation(), dict.isEmpty {
            HapticManager.shared.notification(.success)
        } else {
            HapticManager.shared.notification(.warning)
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
            f.dateStyle = .full
            f.timeStyle = .full
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
            let ratesUpdateTime: String = UserDefaults.standard.string(forKey: UDKeys.updateTime) ?? "Error"
            let date: Date = isoDateFromatter.date(from: ratesUpdateTime) ?? .distantPast
            return dateFormatter.string(from: date)
        }
    }
}

#if DEBUG
struct UserDefaultsValuesView: View {
    let defaults: [String:Any]
    
    @State
    private var search: String = ""
    
    var body: some View {
        List {
            ForEach(Array(searchFunc().sorted(by: <)), id: \.self) { key in
                Section {
                    Text(defaults[key].debugDescription)
                        .onTapGesture(count: 2) {
                            UIPasteboard.general.string = defaults[key].debugDescription
                            HapticManager.shared.impact(.rigid)
                        }
                } header: {
                    Text(key)
                        .font(.body.bold())
                        .textCase(nil)
                        .onTapGesture(count: 2) {
                            UIPasteboard.general.string = key
                            HapticManager.shared.impact(.rigid)
                        }
                }
            }
        }
        .searchable(text: $search)
        .navigationTitle(Text(verbatim: "UserDefaults"))
    }
    
    private func searchFunc() -> [String] {
        if search.isEmpty {
            return Array(defaults.keys)
        } else {
            return Array(defaults.keys).filter { $0.localizedCaseInsensitiveContains(search) }
        }
    }
    
    init(defaults: UserDefaults) {
        self.defaults = defaults.dictionaryRepresentation()
    }
}

#Preview {
    DebugView()
}
#endif
