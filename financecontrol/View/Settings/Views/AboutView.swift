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
    
    @State private var showDebug: Bool = false
    
    @Binding
    var presentOnboarding: Bool
    
    var body: some View {
        Form {
            aboutSection
            
            onboardingSection
            
            githubSection
                                                
            if showDebug {
                debugSection
            }
        }
    }
    
    private var aboutSection: some View {
        Section(header: aboutHeader) {
            Text("An open-source spending tracker. \nDeveloped by PinkXaciD. \nExchange rates API by nulledzero.")
                .normalizePadding()
            
            Button("App site") {}
            
            Button {
                openURL(URLs.github)
            } label: {
                Text(verbatim: "GitHub")
            }
        }
    }
    
    private var aboutHeader: some View {
        VStack(alignment: .center) {
            let imageName = (UIApplication.shared.alternateIconName ?? "AppIcon") + "_Image"
            let appName = Bundle.main.displayName ?? "Squirrel"
            
            Image(imageName, bundle: .main)
                .cornerRadius(15)
                .onTapGesture(count: 5, perform: debugToggle)
                .overlay { iconOverlay }
                .hoverEffect(.lift)
            
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
                openURL(URLs.newGithubIssue)
            }
            
            Button("Buy me some noodles") {}
        }
    }
    
    private var debugSection: some View {
        Section {
            NavigationLink("Debug") {
                DebugView()
            }
        }
    }
    
    private var copyrightText: Text {
        Text(verbatim: "© \(Date().formatted(.dateTime.year())) PinkXaciD")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    private func debugToggle() {
        withAnimation {
            showDebug.toggle()
        }
        HapticManager.shared.impact(.rigid)
    }
}

#Preview {
    AboutView(presentOnboarding: .constant(false))
}
