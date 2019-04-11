//
//  AirportService.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 4/6/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import Foundation

class AirportService {
    
    // Properties
    private let baseUrl = "https://raw.githubusercontent.com/ram-nadella/airport-codes/master/airports.json"
    private let session = URLSession.shared
    
    func getAirports(success: @escaping ([Airport]) -> Void, failure: @escaping (APIError) -> Void) {
        
        guard let url = URL(string: baseUrl) else {
            failure(.InvalidURL)
            return
        }
        
        session.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    failure(.InvalidData)
                }
                return
            }
            
            if let airports = try? JSONDecoder().decode([String: Airport].self, from: data) {
                DispatchQueue.main.async {
                    success(airports.compactMap{ $0.value })
                }
            }
        }.resume()
    }
}
