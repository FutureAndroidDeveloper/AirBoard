//
//  AirportService.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 4/6/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import Foundation

class AirportService {
    
    // MARK: Properties
    private let baseUrl = "https://raw.githubusercontent.com/ram-nadella/airport-codes/master/airports.json"
    private let session = URLSession.shared
    
    func getAirports(completion: @escaping (Result<[Airport], APIError>) -> Void) {
        
        guard let url = URL(string: baseUrl) else {
            completion(.failure(.InvalidURL))
            return
        }
        
        session.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.InvalidURL))
                }
                return
            }
            
            if let airports = try? JSONDecoder().decode([String: Airport].self, from: data) {
                DispatchQueue.main.async {
                    completion(.success(airports.compactMap{ $0.value }))
                }
            }
        }.resume()
    }
}
