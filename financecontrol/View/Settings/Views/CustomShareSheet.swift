//
//  CustomShareSheet.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/23.
//

import SwiftUI

struct CustomShareSheet: UIViewControllerRepresentable {
    @Binding var url: URL
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
