//
//  TransitionExtensions.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/03/14.
//

import SwiftUI

extension AnyTransition {
    static var horizontalMove: AnyTransition {
        AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
    }
    
    static var moveFromBottom: AnyTransition {
        AnyTransition.move(edge: .bottom).combined(with: .opacity)
    }
}
