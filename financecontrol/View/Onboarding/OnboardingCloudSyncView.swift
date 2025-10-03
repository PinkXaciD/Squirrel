//
//  OnboardingCloudSyncView.swift
//  Squirrel
//
//  Created by PinkXaciD on 2025/01/10.
//

import SwiftUI

struct OnboardingCloudSyncView: View {
    @EnvironmentObject
    private var kvsManager: CloudKitKVSManager
    
    private let showHeader: Bool
    
    private var topPadding: CGFloat {
        if #available(iOS 26.0, *) {
            return 50
        }
        
        return 40
    }
    
    init(showHeader: Bool = true) {
        self.showHeader = showHeader
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if showHeader{
                OnboardingHeaderView(header: "iCloud sync", description: "You can change this later in settings")
                    .padding(.top, topPadding)
            }
            
            Spacer()
            
            CloudSyncView()
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

struct CloudSyncView: View {
    @EnvironmentObject
    private var kvsManager: CloudKitKVSManager
    
    private var padding: CGFloat {
        if #available(iOS 26.0, *) {
            return 16
        }
        
        return 11
    }
    
    var body: some View {
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
                .padding(.vertical, padding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: Self.listCornerRadius)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                }
        }
        .disabled(CloudKitManager.shared.accountStatus != .available)
        
        if CloudKitManager.shared.accountStatus != .available {
            Text("sign-in-to-icloud-key")
                .font(.footnote)
                .foregroundStyle(.red)
                .padding(.horizontal)
                .padding(.top, 1)
        }
        
        Text("Your data will be stored in your iCloud storage. We don't have access to your data.")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.horizontal)
            .padding(.top, 1)
        
        Spacer()
    }
}

#Preview("Cloud") {
    OnboardingCloudSyncView()
}

#Preview("Main") {
    OnboardingPreview()
}

fileprivate struct OnboardingPreview: View {
    @State var showSheet: Bool = true
    
    var body: some View {
        NavigationView {
            Button {
                showSheet.toggle()
            } label: {
                Rectangle()
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $showSheet) {
            OnboardingView()
                .environmentObject(CoreDataModel())
                .accentColor(.orange)
        }
    }
}
