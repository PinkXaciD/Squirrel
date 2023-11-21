//
//  AboutView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/09.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.openURL) private var openURL
    let version: String? = Bundle.main.releaseVersionNumber
    
    @State private var showDebug: Bool = false
    
    var body: some View {
        Form {
            aboutSection
            
            githubSection
                                                
            if showDebug {
                debugSection
            }
        }
    }
    
    var aboutSection: some View {
        Section(header: aboutHeader) {
            Text("An open-source spending tracker. \nDeveloped by PinkXaciD. Exchange rates API by nulledzero")
            
            Button("App site") {}
            
            Button("GitHub") {
                openURL(URL(string: "https://github.com/PinkXaciD/Squirrel")!)
            }
        }
    }
    
    var aboutHeader: some View {
        VStack(alignment: .center) {
            if let image = Bundle.main.icon {
                Image(uiImage: image)
                    .cornerRadius(15)
            }
            
            Text("Squirrel, version \(version ?? "unknown")")
                .font(.body)
                .bold()
                .foregroundColor(.primary)
                .padding(.top)
        }
        .frame(maxWidth: .infinity)
        .textCase(nil)
        .onTapGesture(count: 5) {
            showDebug.toggle()
        }
        .padding(.vertical, 15)
    }
    
    var githubSection: some View {
        Section {
            Button("Create a new issue on GitHub") {
                openURL(URL(string: "https://github.com/PinkXaciD/Squirrel/issues/new")!)
            }
            
            Button("Buy me some noodles") {}
        }
    }
    
    var debugSection: some View {
        Section {
            NavigationLink("Debug") {
                DebugView()
                    .navigationTitle("Debug")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    AboutView()
}
