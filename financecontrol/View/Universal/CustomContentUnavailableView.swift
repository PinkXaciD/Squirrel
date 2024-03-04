//
//  CustomContentUnavailableView.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/03/05.
//

import SwiftUI

struct CustomContentUnavailableView: View {
    let imageName: String
    let title: String
    let description: String?
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .foregroundColor(.secondary)
                .padding(15)
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            if let description {
                Text(description)
                    .foregroundColor(.secondary)
                    .font(.callout)
            }
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 30)
    }
    
    init(_ title: String, imageName: String = "questionmark", description: String? = nil) {
        self.title = title
        self.imageName = imageName
        self.description = description
    }
}

#Preview {
    CustomContentUnavailableView("Test")
}
