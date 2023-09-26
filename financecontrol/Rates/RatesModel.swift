//
//  RatesModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/25.
//

import Foundation

//MARK: Rates Model

final class RatesModel {
    
    init() {
        print("RatesModel initialized")
    }
    
    deinit {
        print("RatesModel deinitialized")
    }
    
}

//MARK: Rates Model networking

extension RatesModel {
    
    private func getURL() throws -> String {
        
        guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist") else {
            throw APIURLError.noInfoFound
        }
        
        let plist = NSDictionary(contentsOfFile: filePath)
        
        guard let value = plist?.object(forKey: "API_URL") as? String else {
            throw APIURLError.noURLFound
        }
        
        return value
    }
    
    func downloadRates() async throws -> [String:Double] {
        
        var urlString: String = ""
        
        do {
            urlString = try getURL()
        } catch {
            throw error
        }
        
        guard let url: URL = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            return try handleResponse(data: data, response: response).usd
        } catch {
            throw error
        }
    }
    
    private func handleResponse(data: Data, response: URLResponse) throws -> Rates {
        
        guard let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
            throw URLError(.badServerResponse)
        }
        
        do {
            let result = try JSONDecoder().decode(Rates.self, from: data)
            return result
        } catch {
            throw error
        }
    }
}
