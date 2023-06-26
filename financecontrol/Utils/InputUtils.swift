//
//  AmountInputUtils.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/28.
//

import SwiftUI

class InputUtils {
    
    func checkAll(amount: String, place: String, category: String, comment: String) -> Bool {
        return amountCheck(amount: amount) && categoryCheck(category: category) && comment.count <= 300
    }
    
    func amountCheck(amount: String) -> Bool {
        return Double(amount) != nil
    }
    
    func placeCheck(place: String) -> Bool {
        return place != ""
    }
    
    func categoryCheck(category: String) -> Bool {
        return category != "Select Category"
    }
}
