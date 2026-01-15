//
//  AnyTransition+Extensions.swift
//  Squirrel
//
//  Created by PinkXaciD on 2025/02/27.
//

import SwiftUI

extension AnyTransition {
    static var horizontalMoveForward: AnyTransition {
        AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
    }
    
    static var horizontalMoveBackward: AnyTransition {
        AnyTransition.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))
    }
    
    static var moveFromBottom: AnyTransition {
        AnyTransition.move(edge: .bottom).combined(with: .opacity)
    }
    
    static var maskFromTheBottomWithOpacity: AnyTransition {
        .modifier(active: MaskFromTheBottomModifier(isActive: true, withOpacity: true), identity: MaskFromTheBottomModifier(isActive: false, withOpacity: true))
    }
    
    static var maskFromTheBottom: AnyTransition {
        .modifier(active: MaskFromTheBottomModifier(isActive: true, withOpacity: false), identity: MaskFromTheBottomModifier(isActive: false, withOpacity: false))
    }
    
    static func maskFromTheTopWithOpacity(padding: CGFloat) -> AnyTransition {
        .modifier(active: MaskFromTheTopModifier(isActive: true, withOpacity: true, padding: padding), identity: MaskFromTheTopModifier(isActive: false, withOpacity: true, padding: padding))
    }
    
    static var blurWithOpacity: AnyTransition {
        .modifier(active: BlurWithOpacityModifier(isActive: true), identity: BlurWithOpacityModifier(isActive: false))
    }
}
