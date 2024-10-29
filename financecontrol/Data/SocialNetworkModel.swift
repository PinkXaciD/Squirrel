//
//  SocialNetworkModel.swift
//  Squirrel
//
//  Created by PinkXaciD on 2024/10/29.
//

import Foundation

struct SocialNetworkModel: Codable, Equatable {
    let urlString: String
    let name: String
    let displayUsername: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case urlString = "url"
        case displayUsername = "display_username"
    }
    
    func getURL() -> URL? {
        URL(string: self.urlString)
    }
}
