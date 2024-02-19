//
//  CustomAlertView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/24.
//

import SwiftUI

struct CustomAlertView: View {
    @Binding var isPresented: Bool
    var type: CustomAlertType
    var text: Text
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: isPresented ? 20 : 80)
                .fill(Material.regular)
                .shadow(radius: 10)
            
            HStack {
                type.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(isPresented ? 1 : 0.1)
                    .foregroundColor(type.imageColor)
                    .padding()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(type.alertTitle)
                            .fontWeight(.bold)
                        
                        text
                    }
                    .padding(.vertical, 5)
                    
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 80)
        .padding(.horizontal)
        .onChange(of: isPresented) { newValue in
            if newValue {
                HapticManager.shared.notification(type.haptic)
            }
        }
    }
}
