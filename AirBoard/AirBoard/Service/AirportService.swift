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
    
    func getAirports(callback: @escaping ([Airport], Error?) -> Void) {
        
        guard let url = URL(string: baseUrl) else {
            callback([], nil)
            return
        }
        
        session.dataTask(with: url) { (data, response, error) in
            
            guard response != nil else {
                DispatchQueue.main.async {
                    callback([], nil)
                }
                print("nil response")
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    callback([], nil)
                }
                print("invalid data")
                return
            }
            
            if let airports = try? JSONDecoder().decode([String: Airport].self, from: data) {
                DispatchQueue.main.async {
                    callback(airports.compactMap{ $0.value }, nil)
                }
            }
        }.resume()
    }
}
