//
//  PrivacyPolicyView.swift
//  Squirrel
//
//  Created by PinkXaciD on 2024/10/30.
//

import SwiftUI

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
                        
                        expensesStorageText
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
                                    
                                    Text("We respect your privacy and will not change our stance on tracking or storing data in your control. This clarification is here so that if we add any opt-in features this policy will be updated to reflect that.")
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
                }
                
                Section {
                    Button("If you believe this policy has been violated in any way, please create an issue on GitHub.") {
                        urlToOpen = .newGithubIssue
                        showConfirmationDialog = true
                    }
                }
                
                Section {
                    Button("This policy is also available on our website.") {
                        urlToOpen = .privacyPolicy
                        showConfirmationDialog = true
                    }
                }
            }
        }
        .confirmationDialog("\(urlToOpen?.absoluteString ?? "")", isPresented: $showConfirmationDialog, titleVisibility: .visible, presenting: urlToOpen) { url in
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
    
    private var expensesStorageText: some View {
        guard let attributedString = try? AttributedString(
            markdown: "All expenses are stored locally by default. You can enable cloud synchronisation in settings, this way your expenses and categories will be stored in your iCloud storage in accordance with [Apple privacy policy](https://apple.com/legal/privacy) and [iCloud terms](https://www.apple.com/legal/internet-services/icloud)."
        ) else {
            return Text("privacy-policy-fallback-key")
        }
        
        return Text(attributedString)
    }
}

#if DEBUG
#Preview("Privacy policy") {
    NavigationView {
        PrivacyPolicyView()
    }
}
#endif
