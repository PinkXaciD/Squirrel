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
    private var mailToOpen: String? = nil
    @State
    private var showURLConfirmationDialog: Bool = false
    @State
    private var urlToOpen: URL? = nil
    
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
                    openEmailButtonAction(URL.appEmail)
                }
            } header: {
                Text("Email")
            }
            
            Section {
                Button {
                    openURLButtonAction(.github)
                } label: {
                    Text(verbatim: "GitHub")
                }
                
                Button("Create an issue on GitHub") {
                    openURLButtonAction(.newGithubIssue)
                }
            } header: {
                Text(verbatim: "GitHub")
            }
            
            if !socialNetworks.isEmpty {
                Section {
                    ForEach(socialNetworks, id:\.name) { network in
                        Button(network.name) {
                            openSocailNetworkButtonAction(network)
                        }
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
        .confirmationDialog("\(socialNetworkToOpen?.name ?? "")", isPresented: $showSocialNetworkConfirmationDialog, titleVisibility: .visible, presenting: socialNetworkToOpen) { socialNetwork in
            Button("Open in browser") {
                if let url = socialNetwork.getURL() {
                    openURL(url)
                }
            }
            
            Button("Copy username to clipboard") {
                UIPasteboard.general.string = socialNetwork.displayUsername
            }
            
            Button("Copy link to clipboard") {
                if let url = socialNetwork.getURL() {
                    UIPasteboard.general.url = url
                }
            }
        } message: { socialNetwork in
            Text(socialNetwork.displayUsername)
        }
        .confirmationDialog("\(urlToOpen?.absoluteString ?? "")", isPresented: $showURLConfirmationDialog, titleVisibility: .visible, presenting: urlToOpen) { url in
            Button("Open in browser") {
                openURL(url)
            }
            
            Button("Copy to clipboard") {
                UIPasteboard.general.url = url
            }
        }
        .confirmationDialog("\(mailToOpen ?? "")", isPresented: $showEmailConfirmationDialog, titleVisibility: .visible, presenting: mailToOpen) { mailString in
            Button("Write") {
                if let mailURL = URL(string: "mailto:\(mailString)") {
                    openURL(mailURL)
                }
            }
            
            Button("Copy to clipboard") {
                UIPasteboard.general.string = mailString
            }
        }
        .navigationTitle("Contact Us")
    }
    
    private func openEmailButtonAction(_ mail: String) {
        mailToOpen = mail
        showEmailConfirmationDialog.toggle()
    }
    
    private func openURLButtonAction(_ url: URL) {
        urlToOpen = url
        showURLConfirmationDialog.toggle()
    }
    
    private func openSocailNetworkButtonAction(_ socialNetwork: SocialNetworkModel) {
        socialNetworkToOpen = socialNetwork
        showSocialNetworkConfirmationDialog.toggle()
    }
}

#if DEBUG
#Preview("Contact us") {
    NavigationView {
        ContactUsView()
    }
}
#endif
