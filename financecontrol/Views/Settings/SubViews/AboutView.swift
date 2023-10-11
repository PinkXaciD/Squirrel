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
            Section {
                
            } footer: {
                VStack(alignment: .center) {
//                    Spacer()
                    
                    if let image = Bundle.main.icon {
                        Image(uiImage: image)
                            .cornerRadius(10)
                    }
                    
                    Text("Squirrel, version \(version ?? "")")
                        .font(.body)
                        .bold()
                        .foregroundColor(.primary)
                        .padding(.top)
                    
//                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .onTapGesture(count: 5, perform: {
                    showDebug.toggle()
                })
            }
            
            Section {
                Text("An open-source spending tracker. \nDeveloped by PinkXaciD. Exchange rates API by nulledzero")
                
                Button("App site") {
                    
                }
                
                Button("GitHub") {
                    openURL(URL(string: "https://github.com/PinkXaciD/Squirrel")!)
                }
            }
                        
            Section {
                Button("ApplePie, Swift framework for creating pie charts") {
                    openURL(URL(string: "https://github.com/PinkXaciD/ApplePie")!)
                }
            } header: {
                Text("Open-source libraries")
            }
            
            Section {
                Button("Submit bugreport") {
                    openURL(URL(string: "https://github.com/PinkXaciD/Squirrel/issues")!)
                }
                
                Button("Contribute") {
                    
                }
                
                Button("Buy me a coffee") {
                    
                }
            }
            
            if showDebug {
                NavigationLink("Debug") {
                    DebugView()
                        .navigationTitle("Debug")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}

#Preview {
    AboutView()
}
