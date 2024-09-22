//
//  AboutView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/09.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.openURL) private var openURL
    let version: String = Bundle.main.releaseVersionNumber ?? "unknown"
    let build: String = Bundle.main.buildVersionNumber ?? "unknown"
    
    @Binding
    var presentOnboarding: Bool
    
    @State
    private var showConfirmationDialog: Bool = false
    @State
    private var urlToOpen: URL? = nil
    
    var body: some View {
        List {
            aboutSection
            
            onboardingSection
            
            githubSection
              
            #if DEBUG
            debugSection
            #endif
        }
        .confirmationDialog("Open \"\(urlToOpen?.absoluteString ?? "URL")\"?", isPresented: $showConfirmationDialog, titleVisibility: .visible, presenting: urlToOpen) { url in
            Button("Open in browser") {
                openURL(url)
            }
            
            Button("Copy to clipboard") {
                UIPasteboard.general.url = url
            }
        }
    }
    
    private var aboutSection: some View {
        Section(header: aboutHeader) {
            VStack(alignment: .leading, spacing: 10) {
                Text("An open-source expense tracker.")
                
                Text("Exchange rates are provided for reference purposes only.")
            }
            .normalizePadding()
            
            Button("Our website") {
                openURLButtonAction(URLs.appSite)
            }
            
            Button {
                openURLButtonAction(URLs.github)
            } label: {
                Text(verbatim: "GitHub")
            }
            
            NavigationLink("Privacy Policy") {
                PrivacyPolicyView()
            }
        }
    }
    
    private var aboutHeader: some View {
        VStack(alignment: .center) {
            let imageName = (UIApplication.shared.alternateIconName ?? "AppIcon") + "_Image"
            let appName = Bundle.main.displayName ?? "Squirrel"
            
            Image(imageName, bundle: .main)
                .cornerRadius(15)
                .overlay { iconOverlay }
            
            Text("\(appName), version \(version)")
                .font(.body.bold())
                .foregroundColor(.primary)
            
            Text("Build: \(build)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            copyrightText
        }
        .frame(maxWidth: .infinity)
        .textCase(nil)
        .listRowInsets(.init(top: 15, leading: 20, bottom: 15, trailing: 20))
    }
    
    private var iconOverlay: some View {
        RoundedRectangle(cornerRadius: 15)
            .stroke(lineWidth: 1)
            .foregroundColor(.primary)
            .opacity(0.3)
    }
    
    private var onboardingSection: some View {
        Section {
            Button("Show onboarding") {
                presentOnboarding = true
            }
        }
    }
    
    private var githubSection: some View {
        Section {
            Button("Create an issue on GitHub") {
                openURLButtonAction(URLs.newGithubIssue)
            }
        }
    }
    
    #if DEBUG
    private var debugSection: some View {
        Section {
            NavigationLink("Debug") {
                DebugView()
            }
        }
    }
    #endif
    
    private var copyrightText: Text {
        Text(verbatim: "© \(Date().formatted(.dateTime.year())) PinkXaciD")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    private func openURLButtonAction(_ url: URL) {
        urlToOpen = url
        showConfirmationDialog.toggle()
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.colorScheme)
    private var colorScheme
    @Environment(\.openURL)
    private var openURL
    
    @State
    private var showMore: Bool = false
    @State
    private var showConfirmationDialog: Bool = false
    @State
    private var urlToOpen: URL? = nil
    
    var body: some View {
        VStack {
            List {
                Section {
                    VStack(alignment: .leading) {
                        Text("Squirrel does not send any data or identifiers from your device.")
                        
                        Text("All expenses, settings and any other data are stored locally.")
                    }
                    
                    VStack(alignment: .leading) {
                        Text("This policy is valid for this version of the app.")
                            .animation(.none, value: showMore)
                        
                        if !showMore {
                            Button("More...") {
                                withAnimation {
                                    showMore = true
                                }
                            }
                            .font(.footnote)
                            .foregroundColor(.accentColor)
                        }
                        
                        
                        if showMore {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(uiColor: colorScheme == .dark ? .systemGray5 : .systemGray6))
                                
                                VStack(alignment: .leading) {
                                    Text ("More about policy changes")
                                        .font(.body.bold())
                                        .padding(.vertical, 5)
                                    
                                    Text("We respect your privacy and will not change our stance on tracking or storing data locally. This clarification is here so that if we add any opt-in features, such as cloud sync, this policy will be updated to reflect that.")
                                        .font(.subheadline)
                                }
                                .padding(.horizontal)
                            }
                            #if DEBUG
                            .onTapGesture {
                                withAnimation {
                                    showMore = false
                                }
                            }
                            #endif
                        }
                    }
                    .padding(.vertical, showMore ? 7 : 0)
                    
                    Button("If you believe this policy has been violated in any way, please create an issue on GitHub.") {
                        urlToOpen = URLs.newGithubIssue
                        showConfirmationDialog = true
                    }
                }
                
                Section {
                    Button("This policy is also available on our website.") {
                        urlToOpen = URLs.privacyPolicy
                        showConfirmationDialog = true
                    }
                }
            }
        }
        .confirmationDialog("Open \"\(urlToOpen?.absoluteString ?? "URL")\"?", isPresented: $showConfirmationDialog, titleVisibility: .visible, presenting: urlToOpen) { url in
            Button("Open in browser") {
                openURL(url)
            }
            
            Button("Copy to clipboard") {
                UIPasteboard.general.url = url
            }
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview("Privacy policy") {
    NavigationView {
        PrivacyPolicyView()
    }
}

#Preview("About") {
    NavigationView {
        AboutView(presentOnboarding: .constant(false))
    }
}
