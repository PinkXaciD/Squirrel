//
//  AmountInputUtils.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/28.
//

import SwiftUI

struct InputUtils {
    func checkAll(amount: String, place: String, category: String, comment: String) -> Bool {
        amountCheck(amount: amount)
        &&
        categoryCheck(category: category)
        &&
        placeCheck(place: place)
        &&
        commentCheck(comment: comment)
    }
    
    func amountCheck(amount: String) -> Bool {
        guard
            let doubleAmount = Double(amount.replacingOccurrences(of: ",", with: ".")),
            doubleAmount < Double.greatestFiniteMagnitude,
            doubleAmount > 0
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
    
    func categoryCheck(category: String) -> Bool {
        guard
            category != "Select Category"
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
