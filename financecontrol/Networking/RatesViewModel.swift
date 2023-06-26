//
//  RatesViewModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/18.
//

import Foundation

struct Rates: Codable {
    let date: String
    let usd: [String: Double]
}

final class RatesViewModel: ObservableObject {
    
    @Published var rates: [String:Double] = [:]
    
    init(update: Bool) {
        if update {
            Task {
                let unsafeRates = await getRates()
                if let safeRates = unsafeRates {
                    await MainActor.run {
                        rates = safeRates
                    }
                } else {
                    rates = [:]
                    print("No rates provided")
                    #warning("Fallback rates")
                }
            }
        }
    }
    
    private func getRates() async -> [String:Double]? {
        do {
            return try await RatesModel().downloadRates()
        } catch {
            print(error)
        }
        
        return nil
    }
}

final class RatesModel {
    
    init() {
        print("RatesModel initialized")
    }
    
    deinit {
        print("RatesModel deinitialized")
    }
    
}

extension RatesModel {
    
    enum RatesError: Error {
        case wrongURL
        case JSONDecodeFailed
    }
    
    func downloadRates() async throws -> [String:Double] {
        
        guard let url: URL = URL(string: "https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/latest/currencies/usd.json") else {
            throw RatesError.wrongURL
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
