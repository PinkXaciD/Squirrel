//
//  APIURLComponents.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/06.
//

import Foundation

struct APIURLComponents {
    
    var scheme: String = ""
    var host: String = ""
    var path: String = ""
    
    func createComponents(timestamp: String?) -> URLComponents {
        
        var result = URLComponents()
        
        result.scheme = scheme
        result.host = host
        result.path = path
        
        if let timestamp = timestamp {
            result.queryItems = [URLQueryItem(name: "timestamp", value: timestamp)]
        }
        
        return result
    }
}
