//
//  AnyTransition+Extensions.swift
//  Squirrel
//
//  Created by PinkXaciD on 2025/02/27.
//

import SwiftUI

extension AnyTransition {
    static var maskFromTheBottom: AnyTransition {
        .modifier(active: MaskFromTheBottomModifier(isActive: true), identity: MaskFromTheBottomModifier(isActive: false))
    }
}
