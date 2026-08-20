//
//  WrappedNavigationStack.swift
//  Squirrel
//
//  Created by PinkXaciD on 2026/08/21.
//

import SwiftUI

struct WrappedNavigationStack<Content>: View where Content: View {
    let content: () -> Content
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack(root: content)
        } else {
            NavigationView(content: content)
                .navigationViewStyle(.stack)
        }
    }
}
