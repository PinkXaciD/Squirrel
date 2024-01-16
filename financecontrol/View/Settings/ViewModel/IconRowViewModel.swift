//
//  IconRowViewModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 6/01/08.
//

import SwiftUI

final class IconRowViewModel: ViewModel {
    let icon: CustomIcon
    @Binding var selectedIcon: String?
    
    init(icon: CustomIcon, selection: Binding<String?>) {
        self.icon = icon
        self._selectedIcon = selection
    }
    
    func setIcon() {
        UIApplication.shared.setAlternateIconName(icon.fileName, completionHandler: completionHandler)
    }
    
    private func completionHandler(_ error: Error?) {
        if let error = error {
            ErrorType(error: error).publish()
            return
        }
        
        withAnimation {
            selectedIcon = icon.fileName
        }
    }
    
    func getIconImage() -> Image {
        return Image(icon.imageName, bundle: .main)
    }
}
