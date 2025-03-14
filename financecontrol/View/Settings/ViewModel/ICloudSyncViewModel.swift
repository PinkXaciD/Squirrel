//
//  ICloudSyncViewModel.swift
//  Squirrel
//
//  Created by PinkXaciD on 2025/01/06.
//

import Foundation

final class ICloudSyncViewModel: ObservableObject {
    @Published
    private(set) var dataStoredInCloudKit: Bool
    
    init() {
        self.dataStoredInCloudKit = false
        
        Task {
            await updateDataStatus()
        }
    }
    
    func updateDataStatus() async {
        let result = await CloudKitManager.shared.hasDataInCloudKit()
        
        await MainActor.run { [weak self] in
            self?.dataStoredInCloudKit = result
        }
    }
}
