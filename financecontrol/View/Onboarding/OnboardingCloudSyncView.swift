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
                .padding(.vertical, 11)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: 10)
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
