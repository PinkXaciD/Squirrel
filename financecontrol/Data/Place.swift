//
//  Place.swift
//  Squirrel
//
//  Created by PinkXaciD on 2026/01/16.
//

import Foundation

struct Place {
    var place: String
    var normalized: String
    var weight: Int
}

extension Place: Comparable {
    static func < (a: Place, b: Place) -> Bool {
        if a.weight != b.weight {
            return a.weight > b.weight
        }
        
        return a.place > b.place
    }
    
    static func == (a: Place, b: Place) -> Bool {
        a.weight == b.weight
    }
}
