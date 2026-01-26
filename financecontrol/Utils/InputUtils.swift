//
//  AmountInputUtils.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/28.
//

import SwiftUI

struct InputUtils {
    static let shared = Self()
    
    func checkAll(amount: String, place: String, comment: String) -> Bool {
        amountCheck(amount: amount)
        &&
        placeCheck(place: place)
        &&
        commentCheck(comment: comment)
    }
    
    func amountCheck(amount: String) -> Bool {
        let formatter = NumberFormatter.standard
        
        guard
            let number = formatter.number(from: amount),
            Double(truncating: number) < Double.greatestFiniteMagnitude,
            Double(truncating: number) > 0
        else {
            return false
        }
        
        return true
    }
    
    func placeCheck(place: String) -> Bool {
        guard
            place.count <= 100
        else {
            return false
        }
        
        return true
    }
    
    func commentCheck(comment: String) -> Bool {
        guard
            comment.count <= 300
        else {
            return false
        }
        
        return true
    }
}
