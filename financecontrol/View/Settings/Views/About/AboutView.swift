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
    @State
    private var showWhatsNew: Bool = false
    
    private var iconCornerRadius: CGFloat {
        if #available(iOS 26.0, *) {
            return 16.5
        }
        
        return 15
    }
    
    var body: some View {
        List {
            aboutSection
            
            contactSection
            
            onboardingSection
              
            #if DEBUG
            debugSection
            #endif
        }
        .confirmationDialog("\(urlToOpen?.absoluteString ?? "")", isPresented: $showConfirmationDialog, titleVisibility: .visible, presenting: urlToOpen) { url in
            Button("Open in browser") {
                openURL(url)
            }
            
            Button("Copy to clipboard") {
                UIPasteboard.general.url = url
            }
        }
        .sheet(isPresented: $showWhatsNew) {
            WhatsNewView()
        }
    }
    
    private var aboutSection: some View {
        Section(header: aboutHeader) {
            VStack(alignment: .leading, spacing: 10) {
                Text("An open-source expense tracker.")
                
                Text("Exchange rates are provided for reference purposes only.")
            }
            .normalizePadding()
            
            Button("Our Website") {
                openURLButtonAction(.appWebsite)
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
                .cornerRadius(iconCornerRadius)
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
        RoundedRectangle(cornerRadius: iconCornerRadius)
            .stroke(lineWidth: 1)
            .foregroundColor(.primary)
            .opacity(0.3)
    }
    
    private var onboardingSection: some View {
        Section {
            Button("What's New?") {
                showWhatsNew.toggle()
            }
            
            Button("Show Onboarding") {
                presentOnboarding = true
            }
        }
    }
    
    private var contactSection: some View {
        Section {
            NavigationLink("Contact Us") {
                ContactUsView()
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

#if DEBUG
#Preview("About") {
    NavigationView {
        AboutView(presentOnboarding: .constant(false))
    }
}
#endif
