//
//  WhatsNewView.swift
//  Squirrel
//
//  Created by PinkXaciD on 2025/01/11.
//

import SwiftUI

struct WhatsNewView: View {
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.openURL)
    private var openURL
    
    @AppStorage(UDKey.color.rawValue)
    private var tint: String = "Orange"
    
    @ScaledMetric
    private var imageSize: CGFloat = 50
    @ScaledMetric
    private var buttonSize: CGFloat = 50
    
    @State
    private var showConfirmationDialog: Bool = false
    
    var showSmallHeader: Bool {
        UIApplication.shared.keyWindow?.safeAreaInsets.bottom == 0 // Check if device has a home button
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                if showSmallHeader {
                    smallHeader
                } else {
                    largeHeader
                }
                
                Spacer()
                
                getNavLinkRow(
                    imageName: "icloud.fill",
                    title: "iCloud sync",
                    subtitle: "Backup your expenses seamlessly",
                    destination: cloudSyncView
                )
                
                getNavLinkRow(
                    imageName: "globe.asia.australia.fill",
                    title: "More timezone format options",
                    subtitle: "You can now change timezone format on expense screen",
                    destination: SettingsFormattingView().navigationBarTitleDisplayMode(.large)
                )
                
                getNavLinkRow(
                    imageName: "at",
                    title: "Social Networks",
                    subtitle: "More ways to reach us",
                    destination: ContactUsView().navigationBarTitleDisplayMode(.large)
                )
                
                Spacer()
                
                Button("Full changelog on GitHub") {
                    showConfirmationDialog.toggle()
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.body.bold())
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .tint(.orange)
        .accentColor(.orange)
        .confirmationDialog("\(URL.githubChangelog)", isPresented: $showConfirmationDialog, titleVisibility: .visible) {
            Button("Open in browser") {
                openURL(URL.githubChangelog)
            }
            
            Button("Copy to clipboard") {
                UIPasteboard.general.url = URL.githubChangelog
            }
        } message: {
            Text("Full changelog")
        }
    }
    
    private var smallHeader: some View {
        HStack {
            Image(.onboarding)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(lineWidth: 1)
                        .foregroundColor(.primary)
                        .opacity(0.3)
                }
            
            Text("What's new in \(Text("Squirrel \(Bundle.main.releaseVersionNumber ?? "")").foregroundColor(.orange))")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .padding(.leading)
                .multilineTextAlignment(.leading)
        }
    }
    
    private var largeHeader: some View {
        VStack {
            Image(.onboarding)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .overlay {
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(lineWidth: 1)
                        .foregroundColor(.primary)
                        .opacity(0.3)
                }
            
            Text("What's new in \(Text("Squirrel \(Bundle.main.releaseVersionNumber ?? "")").foregroundColor(.orange))")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .padding()
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    @ViewBuilder
    private func getNavLinkRow<Content>(
        imageName: String,
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey?,
        destination: Content
    ) -> some View where Content: View {
        let label = getRow(imageName: imageName, title: title, subtitle: subtitle)
        
        NavigationLink {
            destination
        } label: {
            HStack {
                label
                
                Spacer()
                
                Image(systemName: "chevron.forward")
                    .foregroundStyle(.secondary)
            }
            .background(.background)
        }
        .buttonStyle(CustomButtonStyle())
    }
    
    @ViewBuilder
    private func getRow(
        imageName: String,
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey?
    ) -> some View {
        HStack(spacing: 15) {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: imageSize, height: imageSize)
                .foregroundStyle(.tint)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                if let subtitle {
                    Text(subtitle)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
//        .minimumScaleFactor(0.8)
    }
    
    private var cloudSyncView: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                OnboardingHeaderView(header: "iCloud sync", description: "You can change this setting later in settings. App reload will be required")
                    .padding(.bottom, 50)
                
                CloudSyncView()
            }
            .padding(.horizontal)
        }
    }
    
    struct CustomButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
        }
    }
}

struct WhatsNewCloudSyncView: View {
    @EnvironmentObject
    private var kvsManager: CloudKitKVSManager
    
    private let showHeader: Bool
    
    init(showHeader: Bool = true) {
        self.showHeader = showHeader
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if showHeader{
                OnboardingHeaderView(header: "iCloud sync", description: "You can change this later in settings")
                    .padding(.top, 40)
            }
            
            Spacer()
            
            ICloudLogoAnimatedView(isEnabled: kvsManager.iCloudSync)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 40)
            
            Button {
                kvsManager.iCloudSync.toggle()
                
                HapticManager.shared.impact(.rigid)
            } label: {
                Text(kvsManager.iCloudSync ? "Disable iCloud sync" : "Enable iCloud sync")
                    .font(.body)
                    .padding(.horizontal)
                    .padding(.vertical, 11)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    }
            }
            
            Text("Your data will be stored in your iCloud storage. We don't have access to your data.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.top, 1)
            
            Spacer()
        }
        .padding()
        .padding(.bottom, 60)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea(.all)
            }
        }
    }
}

#Preview {
    NavigationView {
        Rectangle()
            .sheet(isPresented: .constant(true)) {
                WhatsNewView()
                    .tint(.orange)
            }
    }
}
