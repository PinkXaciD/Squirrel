//
//  RatesView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/18.
//

import SwiftUI

struct RatesView: View {
    
    @StateObject private var rvm: RatesViewModel = RatesViewModel(update: true)
    
    var body: some View {
        
        List {
            
            let filtered = rvm.rates
            
            ForEach(Array(filtered.keys), id: \.self) { key in
                
                HStack {
                    Text(key)
                    Spacer()
                    Text(String(filtered[key] ?? 0))
                }
            }
        }
    }
}

struct RatesView_Previews: PreviewProvider {
    static var previews: some View {
        RatesView()
    }
}
