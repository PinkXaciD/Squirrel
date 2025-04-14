//
//  AnyTransition+Extensions.swift
//  Squirrel
//
//  Created by PinkXaciD on 2025/02/27.
//

import SwiftUI

extension AnyTransition {
    static var maskFromTheBottomWithOpacity: AnyTransition {
        .modifier(active: MaskFromTheBottomModifier(isActive: true, withOpacity: true), identity: MaskFromTheBottomModifier(isActive: false, withOpacity: true))
    }
    
    static var maskFromTheBottom: AnyTransition {
        .modifier(active: MaskFromTheBottomModifier(isActive: true, withOpacity: false), identity: MaskFromTheBottomModifier(isActive: false, withOpacity: false))
    }
}
