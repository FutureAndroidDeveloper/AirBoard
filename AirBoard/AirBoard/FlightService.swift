//
//  FlightService.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 3/25/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import Foundation

class FlightService {
    
    // MARK: Properties
    
    private let baseUrl: String = "https://opensky-network.org/api/"
    private let session = URLSession.shared
    
    
    func getDepartureFlights(parameters: [String: Any], callback: @escaping (_ flights: [Flight], Error?) -> Void) {
        
        let path = "flights/departure"
        
        guard let url = URL(string: baseUrl + path + getParamPath(parameters: parameters)) else {
            callback([], nil)
            return
        }
        
        let urlRequest = URLRequest(url: url)
        
        // make the request
        session.dataTask(with: urlRequest) { (data, response, error) in
            
            guard let data = data else {
                DispatchQueue.main.async {
                    callback([], nil)
                }
                return
            }
            
            if let flights = try? JSONDecoder().decode([Flight].self, from: data) {
                DispatchQueue.main.async {
                    callback(flights, nil)
                }
            }
        }.resume()
    }
    
    
    // MARK: Private Methods
    
    private func getParamPath(parameters: [String: Any]) -> String {
        var resultString = "?"
        
        if parameters.isEmpty {
            resultString = ""
        }
        
        if let airportICAO = parameters["airport"] as? String {
            resultString += "airport=" + airportICAO + "&"
        } else {
            print("Can not get ICAO")
        }
        
        if let begin = parameters["begin"] as? Int {
            resultString += "begin=" + String(begin) + "&"
        } else {
            print("Can not get begin time")
        }
        
        if let end = parameters["end"] as? Int {
            resultString += "end=" + String(end)
        } else {
            print("Can not get end time")
        }
        
        return resultString
    }
}
