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
    let networkMonitor = NetworkMonitor.shared
    
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
            let apiKey = try await getApiKey(apiURLComponents.host)
            var timestampString: String?
            
            if let timestamp = timestamp {
                let timeZone: TimeZone = {
                    if #available(iOS 16, *) {
                        return .gmt
                    } else {
                        return .init(secondsFromGMT: 0) ?? .current // Cannot fail
                    }
                }()
                
                let calendar: Calendar = .gmt
                let formatter = ISO8601DateFormatter()
                formatter.timeZone = timeZone
                let startOfDay = calendar.startOfDay(for: timestamp)
                        
//                print(startOfDay.description)
                timestampString = "\"" + formatter.string(from: startOfDay) + "\""
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
//                    throw URLError(.timedOut)
                    let (data, response) = try await URLSession.shared.data(for: request)
                    return try handleResponse(data: data, response: response)
                } catch URLError.timedOut {
                    if !NetworkMonitor.shared.isConnected {
                        throw URLError(.notConnectedToInternet)
                    }
                    
                    if count == 2 {
                        throw URLError(.timedOut)
                    } else {
                        continue
                    }
                } catch {
                    throw error
                }
            }
            
            throw URLError(.unknown)
        } catch let error {
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
    
    private func getApiKey(_ serverURL: String) async throws -> String {
//        guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist") else {
//            throw InfoPlistError.noInfoFound
//        }
//        
//        let plist = NSDictionary(contentsOfFile: filePath)
//        
//        guard let value = plist?.object(forKey: "API_KEY") as? String else {
//            throw InfoPlistError.noAPIKeyFound
//        }
//        
//        return value
        let keychain = Keychain(serverURL)
        
        if let existing = try keychain.getPassword() {
            return existing
        }
        
        let ckManager = CloudKitManager()
        
        do {
            let result = try await ckManager.fetchAPIKey()
            try keychain.setPassword(result)
            return result
        } catch {
            throw error
        }
    }
}
