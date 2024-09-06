//
//  TransitionExtensions.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/03/14.
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
}
