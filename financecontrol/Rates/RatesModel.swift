//
//  RatesModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/25.
//

import Foundation

//MARK: Rates Model

final class RatesModel {
    
    let errorHandler = ErrorHandler.instance
    
    init() {
        print("RatesModel initialized")
    }
    
    deinit {
        print("RatesModel deinitialized")
    }

}

//MARK: Rates Model networking

extension RatesModel {
    
    func downloadRates(timeStamp: Date? = nil) async throws -> Rates {
        
        do {
            let apiURLComponents = try getURLComponents()
            let apiKey = try getApiKey()
            var timeStampString: String?
            
            if let timeStamp = timeStamp {
                
                let formatter = ISO8601DateFormatter()
                        
                timeStampString = "\"" + formatter.string(from: timeStamp) + "\""
            }
            
            let urlComponents = apiURLComponents.createComponents(timestamp: timeStampString)
            
            guard let url: URL = urlComponents.url else {
                throw URLError(.badURL)
            }
            
            var request: URLRequest {
                var request = URLRequest(url: url)
                request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
                return request
            }

            let (data, response) = try await URLSession.shared.data(for: request)
            return try handleResponse(data: data, response: response)

        } catch {
            await MainActor.run {
                if let error = error as? InfoPlistError {
                    ErrorType(infoPlistError: error).publish()
                } else if let error = error as? URLError {
                    switch error {
                    case URLError.badServerResponse, URLError.badURL:
                        ErrorType(urlError: error).publish()
                    default:
                        ErrorType(
                            errorDescription: error.localizedDescription,
                            failureReason: error.localizedDescription,
                            recoverySuggestion: "Check your internet connection"
                        ).publish()
                    }
                }
            }
            throw error
        }
    }
    
    private func handleResponse(data: Data, response: URLResponse) throws -> Rates {
        
        guard let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
            throw URLError(.badServerResponse)
        }
        
        do {
            return try JSONDecoder().decode(Rates.self, from: data)
        } catch {
            throw error
        }
    }
}

//MARK: Info.plist

extension RatesModel {
    
    private func getURLComponents() throws -> APIURLComponents {
        
        guard 
            let filePath = Bundle.main.path(forResource: "Info", ofType: "plist")
        else {
            throw InfoPlistError.noInfoFound
        }
        
        let plist = NSDictionary(contentsOfFile: filePath)
        
        guard 
            let apiURLDict = plist?.object(forKey: "API_URL") as? Dictionary<String, String>
        else {
            throw InfoPlistError.noURLFound
        }
        
        guard
            let scheme = apiURLDict["scheme"],
            let host = apiURLDict["host"],
            let path = apiURLDict["path"]
        else {
            throw InfoPlistError.failedToReadURLComponents
        }
        
        var result: APIURLComponents {
            var result = APIURLComponents()
            result.scheme = scheme
            result.host = host
            result.path = path
            return result
        }
        
        return result
    }
    
    private func getApiKey() throws -> String {
        
        guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist") else {
            throw InfoPlistError.noInfoFound
        }
        
        let plist = NSDictionary(contentsOfFile: filePath)
        
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
            throw InfoPlistError.noAPIKeyFound
        }
        
        return value
    }
}
