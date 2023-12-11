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
    let build: String? = Bundle.main.buildVersionNumber
    
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
    
    private var aboutSection: some View {
        Section(header: aboutHeader) {
            Text("An open-source spending tracker. \nDeveloped by PinkXaciD.")
            
            Button("App site") {}
            
            Button {
                openURL(URL(string: "https://github.com/PinkXaciD/Squirrel")!)
            } label: {
                Text(verbatim: "GitHub")
            }
        }
    }
    
    private var aboutHeader: some View {
        VStack(alignment: .center) {
            if let image = Bundle.main.icon {
                Image(uiImage: image)
                    .cornerRadius(15)
                    .onTapGesture(count: 5, perform: debugToggle)
            }
            
            Text("Squirrel, version \(version ?? "unknown")")
                .font(.body.bold())
                .foregroundColor(.primary)
            
            Text("Build: \(build ?? "")")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .textCase(nil)
        .padding(.vertical, 15)
    }
    
    private var githubSection: some View {
        Section {
            Button("Create an issue on GitHub") {
                openURL(URL(string: "https://github.com/PinkXaciD/Squirrel/issues/new")!)
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
    
    private func debugToggle() {
        withAnimation {
            showDebug.toggle()
        }
    }
}

#Preview {
    AboutView()
}
