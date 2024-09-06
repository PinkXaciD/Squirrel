//
//  OnboardingHeaderView.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/09/06.
//

import SwiftUI

struct OnboardingHeaderView: View {
    let header: LocalizedStringKey
    let description: LocalizedStringKey
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(header)
                    .font(.largeTitle.bold())
                    .lineLimit(1)
                
                Text(description)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            Spacer()
        }
        .foregroundColor(.primary)
    }
}
