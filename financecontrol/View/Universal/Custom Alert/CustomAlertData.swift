//
//  CustomAlertData.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/07/02.
//

import SwiftUI

struct CustomAlertData: Identifiable {
    let id: UUID = .init()
    let type: CustomAlertType
    let title: LocalizedStringKey
    let description: LocalizedStringKey?
    let systemImage: String
    
    init(type: CustomAlertType, title: LocalizedStringKey, description: LocalizedStringKey? = nil, systemImage: String = "questionmark.circle") {
        self.type = type
        self.title = title
        self.description = description
        self.systemImage = systemImage
    }
    
    static func noConnection(_ description: LocalizedStringKey? = nil) -> Self {
        let image: String = {
            if #available(iOS 17, *) {
                return "network.slash"
            } else {
                return "network"
            }
        }()
        
        return CustomAlertData(
            type: .warning,
            title: "No connection",
            description: description,
            systemImage: image
        )
    }
    
    static func error(_ error: LocalizedError) -> Self {
        .init(type: .error, title: "Error", description: LocalizedStringKey(error.localizedDescription), systemImage: "xmark.circle")
    }
}
