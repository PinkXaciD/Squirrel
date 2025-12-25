//
//  ContactUsView.swift
//  Squirrel
//
//  Created by PinkXaciD on 2024/10/30.
//

import SwiftUI

struct ContactUsView: View {
    @Environment(\.openURL)
    private var openURL
    
    @State
    private var showSocialNetworkConfirmationDialog: Bool = false
    @State
    private var socialNetworkToOpen: SocialNetworkModel? = nil
    @State
    private var showEmailConfirmationDialog: Bool = false
    @State
    private var showGitHubURLConfirmationDialog: Bool = false
    @State
    private var showGitHubIssueURLConfirmationDialog: Bool = false
    
    var socialNetworks: [SocialNetworkModel] {
        guard let data = UserDefaults.standard.data(forKey: UDKey.socialNetworksJSON.rawValue) else {
            return []
        }
        
        let result = try? JSONDecoder().decode([SocialNetworkModel].self, from: data)
        
        guard let result else {
            return []
        }
        
        return result
    }
    
    var body: some View {
        List {
            Section {
                Button("Email") {
                    showEmailConfirmationDialog = true
                }
                .confirmationDialog(URL.appEmail, isPresented: $showEmailConfirmationDialog, titleVisibility: .visible) {
                    Button("Write") {
                        if let mailURL = URL(string: "mailto:\(URL.appEmail)") {
                            openURL(mailURL)
                        }
                    }
                    
                    Button("Copy to clipboard") {
                        UIPasteboard.general.string = URL.appEmail
                    }
                }
            } header: {
                Text("Email")
            }
            
            Section {
                Button {
                    showGitHubURLConfirmationDialog = true
                } label: {
                    Text(verbatim: "GitHub")
                }
                .confirmationDialog(URL.github.absoluteString, isPresented: $showGitHubURLConfirmationDialog, titleVisibility: .visible) {
                    Button("Open in browser") {
                        openURL(.github)
                    }
                    
                    Button("Copy to clipboard") {
                        UIPasteboard.general.url = .github
                    }
                }
                
                Button("Create an issue on GitHub") {
                    showGitHubIssueURLConfirmationDialog = true
                }
                .confirmationDialog(URL.newGithubIssue.absoluteString, isPresented: $showGitHubIssueURLConfirmationDialog, titleVisibility: .visible) {
                    Button("Open in browser") {
                        openURL(.newGithubIssue)
                    }
                    
                    Button("Copy to clipboard") {
                        UIPasteboard.general.url = .newGithubIssue
                    }
                }
            } header: {
                Text(verbatim: "GitHub")
            }
            
            if !socialNetworks.isEmpty {
                Section {
                    ForEach(socialNetworks, id:\.name) { network in
                        SocialNetworkRow(network: network)
                    }
                } header: {
                    Text("Social Networks")
                }
            }
        }
        #if DEBUG
        .refreshable {
            await CloudKitManager.shared.updateCloudKitContent(forceUpdate: true)
        }
        #endif
        .navigationTitle("Contact Us")
    }
}

fileprivate struct SocialNetworkRow: View {
    @Environment(\.openURL)
    private var openURL
    
    @State
    private var showConfirmationDialog: Bool = false
    
    let network: SocialNetworkModel
    
    var body: some View {
        Button(network.name) {
            showConfirmationDialog = true
        }
        .confirmationDialog("\(network.name)", isPresented: $showConfirmationDialog, titleVisibility: .visible) {
            Button("Open in browser") {
                if let url = network.getURL() {
                    openURL(url)
                }
            }
            
            Button("Copy username to clipboard") {
                UIPasteboard.general.string = network.displayUsername
            }
            
            Button("Copy link to clipboard") {
                if let url = network.getURL() {
                    UIPasteboard.general.url = url
                }
            }
        } message: {
            Text(network.displayUsername)
        }
    }
}

#if DEBUG
#Preview("Contact us") {
    NavigationView {
        ContactUsView()
    }
}
#endif
