//
//  WrappedNavigationSplitView.swift
//  Squirrel
//
//  Created by PinkXaciD on 2026/08/21.
//

import SwiftUI

struct WrappedNavigationSplitView<Sidebar, Content>: View where Sidebar: View, Content: View {
    enum WrappedNavigationSplitViewStyle {
        case balanced, automatic, prominentDetail
        
        @available(iOS 16.0, *)
        var nativeStyle: any NavigationSplitViewStyle {
            switch self {
            case .balanced:
                    .balanced
            case .automatic:
                    .automatic
            case .prominentDetail:
                    .prominentDetail
            }
        }
    }
    
    let style: WrappedNavigationSplitViewStyle
    let sidebar: () -> Sidebar
    let detail: () -> Content
    
    init(
        style: WrappedNavigationSplitViewStyle = .automatic,
        sidebar: @escaping () -> Sidebar,
        detail: @escaping () -> Content
    ) {
        self.style = style
        self.sidebar = sidebar
        self.detail = detail
    }
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationSplitView(columnVisibility: .constant(.all), sidebar: sidebar, detail: detail)
                .navigationSplitViewStyle(style.nativeStyle)
                .ignoresSafeArea()
        } else {
            NavigationView {
                sidebar()
                
                detail()
            }
        }
    }
}
