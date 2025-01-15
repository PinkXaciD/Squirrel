//
//  ICloudSyncView.swift
//  Squirrel
//
//  Created by PinkXaciD on 2024/12/28.
//

import SwiftUI

@MainActor
struct ICloudSyncView: View {
    @EnvironmentObject
    private var kvsManager: CloudKitKVSManager
    @StateObject
    private var vm = ICloudSyncViewModel()
    
    let cloudSyncWasEnabled: Bool
    
    @ScaledMetric
    private var imageSize: CGFloat = 50
    
    init(cloudSyncWasEnabled: Bool) {
        self.cloudSyncWasEnabled = cloudSyncWasEnabled
    }
    
    var body: some View {
        List {
            Section {
                VStack(spacing: 6) {
                    Image(systemName: kvsManager.iCloudSync ? "checkmark.icloud.fill" : "icloud.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: imageSize)
                        .foregroundColor(kvsManager.iCloudSync ? .accentColor : .secondary)
                        .padding(15)
                        .wrappedContentTransition()
                    
                    Text(kvsManager.iCloudSync ? "Your expenses are syncing to iCloud" : "Sync your expenses to iCloud")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(kvsManager.iCloudSync ? "Your data is stored in your iCloud storage. We don't have access to your data." : "Your data will be stored in your iCloud storage. We don't have access to your data.")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .listRowBackground(Color.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Section {
                Button(kvsManager.iCloudSync ? "Disable iCloud sync" : "Enable iCloud sync") {
                    kvsManager.iCloudSync.toggle()
                }
            } footer: {
                Text("appication-restart-required-key")
                    .foregroundStyle(.red)
                    .opacity(cloudSyncWasEnabled == kvsManager.iCloudSync ? 0 : 1)
            }
            
            if !kvsManager.iCloudSync, vm.dataStoredInCloudKit {
                Section {
                    Button("Delete data from iCloud", role: .destructive) {
                        Task {
                            do {
                                try await CloudKitManager.shared.dropUserDataFromPublicDatabase()
                                
                                await vm.updateDataStatus()
                            } catch {
                                ErrorType(error: error).publish()
                            }
                        }
                    }
                    .disabled(cloudSyncWasEnabled)
                } footer: {
                    if cloudSyncWasEnabled {
                        Text("You will be able to delete your data after restarting the application")
                    }
                }
            }
        }
        .navigationTitle("iCloud sync")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.default, value: kvsManager.iCloudSync)
        .animation(.default, value: vm.dataStoredInCloudKit)
        .refreshable {
            await vm.updateDataStatus()
        }
    }
}

fileprivate extension View {
    @ViewBuilder
    func wrappedContentTransition() -> some View {
        if #available(iOS 17.0, *) {
            self
                .contentTransition(.symbolEffect(.replace))
        } else {
            self
        }
    }
}

//#Preview {
//    ICloudSyncView(cloudSyncWasEnabled: true)
//        .tint(.orange)
//}
