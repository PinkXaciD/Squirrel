//
//  RatesModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/25.
//

import Foundation
#if DEBUG
import OSLog
#endif

// MARK: Rates Model

final class RatesModel {
    let errorHandler = ErrorHandler.shared
    
    init() {
        #if DEBUG
        let logger = Logger(subsystem: Vars.appIdentifier, category: "\(#fileID) state")
        logger.debug("RatesModel initialized")
        #endif
    }
    
    #if DEBUG
    deinit {
        let logger = Logger(subsystem: Vars.appIdentifier, category: "\(#fileID) state")
        logger.debug("RatesModel deinitialized")
    }
    #endif
}

// MARK: Rates Model networking

extension RatesModel {
    func downloadRates(timestamp: Date? = nil) async throws -> Rates {
        do {
            let apiURLComponents = try getURLComponents()
            let apiKey = try getApiKey()
            var timestampString: String?
            
            if let timestamp = timestamp {
                let formatter = ISO8601DateFormatter()
                formatter.timeZone = .init(secondsFromGMT: 0)
                        
                timestampString = "\"" + formatter.string(from: timestamp) + "\""
            }
            
            let urlComponents = apiURLComponents.createComponents(timestamp: timestampString)
            
            guard let url: URL = urlComponents.url else {
                throw URLError(.badURL)
            }
            
            var request: URLRequest {
                var request = URLRequest(url: url)
                request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
                request.timeoutInterval = TimeInterval(10)
                return request
            }

            for count in 0 ..< 3 {
                do {
                    let (data, response) = try await URLSession.shared.data(for: request)
                    return try handleResponse(data: data, response: response)
                } catch URLError.timedOut {
                    if count == 2 {
                        throw URLError(.timedOut)
                    } else {
                        continue
                    }
                } catch {
                    throw error
                }
            }
            
            throw URLError(.timedOut)
            
        } catch {
            await MainActor.run {
                if let error = error as? InfoPlistError {
                    ErrorType(error).publish()
                } else if let error = error as? URLError {
                    switch error {
                    case URLError.badServerResponse, URLError.badURL:
                        ErrorType(error).publish()
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
        guard
            let response = response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300
        else {
            throw URLError(.badServerResponse)
        }
        
        do {
            return try JSONDecoder().decode(Rates.self, from: data)
        } catch {
            throw error
        }
    }
}

// MARK: Info.plist

extension RatesModel {
    private func getURLComponents() throws -> APIURLComponents {
        guard
            let filePath = Bundle.main.path(forResource: "Info", ofType: "plist")
        else {
            throw InfoPlistError.noInfoFound
        }
        
        let plist = NSDictionary(contentsOfFile: filePath)
        
        guard
            let apiURLDict = plist?.object(forKey: "API_URL") as? [String: String]
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
        
        var result = APIURLComponents()
        result.scheme = scheme
        result.host = host
        result.path = path
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
