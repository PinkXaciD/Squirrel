//
//  DebugView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/10.
//

#if DEBUG
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
        List {
            errorsSection
            
            ratesSection
            
            bundleSection
            
            networkSection
            
            defaultsSection
            
            keychainSection
            
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
                    
                    keyChainErrorsSection
                    
                    cloudKitErrorsSection
                }
                .navigationTitle("Errors")
            }
        } header: {
            Text("Errors")
        }
    }
    
    private var infoPlistSection: some View {
        Section {
            Button {
                ErrorType(InfoPlistError.noInfoFound).publish()
            } label: {
                Text(verbatim: "Info.plist error")
            }
            
            Button {
                ErrorType(InfoPlistError.noURLFound).publish()
            } label: {
                Text(verbatim: "URL error")
            }
            
            Button {
                ErrorType(InfoPlistError.failedToReadURLComponents).publish()
            } label: {
                Text(verbatim: "URL components error")
            }
            
            Button {
                ErrorType(InfoPlistError.noAPIKeyFound).publish()
            } label: {
                Text(verbatim: "API key error")
            }
        } header: {
            Text(verbatim: "Info.plist error")
        }
    }
    
    private var ratesFetchErrorSection: some View {
        Section {
            Button {
                ErrorType(RatesFetchError.emptyDatabase).publish()
            } label: {
                Text(verbatim: "Empty database error")
            }
        } header: {
            Text(verbatim: "Rates fetch errors")
        }
    }
    
    private var urlErrorSection: some View {
        Section {
            Button {
                ErrorType(URLError(.badServerResponse)).publish()
            } label: {
                Text(verbatim: "URL bad response error")
            }
            
            Button {
                ErrorType(URLError(.badURL)).publish()
            } label: {
                Text(verbatim: "Bad URL error")
            }
        } header: {
            Text(verbatim: "URL errors")
        }
    }
    
    private var coreDataErrorSection: some View {
        Section {
            Button {
                ErrorType(CoreDataError.failedToGetEntityDescription).publish()
            } label: {
                Text(verbatim: "Entity description error")
            }
            
            Button {
                ErrorType(CoreDataError.failedToFindCategory).publish()
            } label: {
                Text(verbatim: "Category error")
            }
        } header: {
            Text(verbatim: "CoreData errors")
        }
    }
    
    private var keyChainErrorsSection: some View {
        Section {
            Button {
                ErrorType(KeychainError.failedToSetValue).publish()
            } label: {
                Text(verbatim: "Failed to set value")
            }
            
            Button {
                ErrorType(KeychainError.failedToRemoveValue).publish()
            } label: {
                Text(verbatim: "Failed to remove value")
            }
            
            Button {
                ErrorType(KeychainError.failedToEncodeURL).publish()
            } label: {
                Text(verbatim: "Failed to encode URL")
            }
            
            Button {
                ErrorType(KeychainError.failedToUnwrapValue).publish()
            } label: {
                Text(verbatim: "Failed to unwrap")
            }
        } header: {
            Text(verbatim: "Keychain errors")
        }
    }
    
    private var cloudKitErrorsSection: some View {
        Section {
            Button {
                ErrorType(CloudKitManager.CloudKitError.failedToDecodeResult).publish()
            } label: {
                Text(verbatim: "Failed to decode result")
            }
            
            Button {
                ErrorType(CloudKitManager.CloudKitError.failedToGetResult).publish()
            } label: {
                Text(verbatim: "Failed to get result")
            }
            
        } header: {
            Text(verbatim: "cloudkit errors")
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
            
            Button(role: .destructive) {
                rvm.checkForUpdate()
            } label: {
                Text(verbatim: "Update rates")
            }
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
    
    private var networkSection: some View {
        Section {
            HStack {
                Text("Is connected", comment: "Debug view: is network available")
                
                Spacer()
                
                Image(systemName: "checkmark")
                    .font(.body.bold())
                    .foregroundStyle(NetworkMonitor.shared.isConnected ? Color.accentColor : .secondary)
                    .opacity(NetworkMonitor.shared.isConnected ? 1 : 0.5)
            }
            
            HStack {
                Text("Is expensive", comment: "Debug view: is network expensive")
                
                Spacer()
                
                Image(systemName: "checkmark")
                    .font(.body.bold())
                    .foregroundStyle(NetworkMonitor.shared.isExpensive ? Color.accentColor : .secondary)
                    .opacity(NetworkMonitor.shared.isExpensive ? 1 : 0.5)
            }
            
            HStack {
                Text("Status:", comment: "Debug view: network status")
                
                Spacer()
                
                Text("\(NetworkMonitor.shared.status)")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text(verbatim: "Network")
        }
    }
    
    private var defaultsSection: some View {
        Section {
            NavigationLink {
                List {
                    HStack {
                        Text(verbatim: "Version")
                        
                        Spacer()
                        
                        Text(UserDefaults.standard.integer(forKey: UDKey.urlUpdateVersion.rawValue).description)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(verbatim: "GitHub URL")
                                .foregroundStyle(.secondary)
                            
                            Text(URL.github.absoluteString)
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(verbatim: "Website URL")
                                .foregroundStyle(.secondary)
                            
                            Text(URL.appWebsite.absoluteString)
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(verbatim: "New GitHub issue URL")
                                .foregroundStyle(.secondary)
                            
                            Text(URL.newGithubIssue.absoluteString)
                        }
                        
                        Spacer()
                    }
                }
                .refreshable {
                    let ckManager = CloudKitManager.shared
                    await ckManager.updateCloudKitContent(forceUpdate: true)
                }
            } label: {
                Text(verbatim: "URLs")
            }
            
            NavigationLink {
                UserDefaultsValuesView(defaults: .standard)
            } label: {
                Text(verbatim: "UserDefaults values")
            }
            
            Button(role: .destructive) {
                defaultsConfirmationIsShowing.toggle()
            } label: {
                Text("Clear UserDefaults")
            }
            
            NavigationLink("Rates fetch queue") {
                List {
                    ForEach(UserDefaults.standard.getFetchQueue(), id: \.self) { id in
                        Text(id.uuidString)
                    }
                }
            }
            
            Button(role: .destructive) {
                UserDefaults.standard.clearFetchQueue()
            } label: {
                Text("Clear fetch queue")
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
    
    private var keychainSection: some View {
        Section {
            Button(role: .destructive) {
                try? Keychain("api.squirrelapp.dev").removePassword()
            } label: {
                Text(verbatim: "Remove API key from keychain")
            }
        } header: {
            Text(verbatim: "Keychain")
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
        
        let isoDateFromatter = ISO8601DateFormatter()
        
        switch type {
        case .fallback:
            let date: Date = isoDateFromatter.date(from: Rates.fallback.timestamp) ?? DateFormatter.forRatesTimestamp.date(from: Rates.fallback.timestamp) ?? .distantPast
            return dateFormatter.string(from: date)
        case .update:
            let ratesUpdateTime: String = UserDefaults.standard.string(forKey: UDKey.updateTime.rawValue) ?? "Error"
            let date: Date = isoDateFromatter.date(from: ratesUpdateTime) ?? DateFormatter.forRatesTimestamp.date(from: ratesUpdateTime) ?? .distantPast
            return dateFormatter.string(from: date)
        }
    }
}

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
