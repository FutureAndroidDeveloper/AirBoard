//
//  FlightService.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 3/25/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import Foundation

class FlightService {
    
    init() {}
    
    func getFlights(callback: @escaping ([Flight]?, Error?) -> Void) {
        
        let client = URLSessionHTTPClient(baseUrl: "https://opensky-network.org/api/")
        var flights: [Flight]?
        
        client.get(path: "flights/departure", parameters: ["airport": "EGLL", "begin": 1553202020, "end": 1553202600]) { (jsonFlights, error) in
            
            guard let jsonFlights = jsonFlights as? [[String: Any]] else {
                return
            }
            
            for flight in jsonFlights {
                
                guard let departure = flight["estDepartureAirport"] as? String  else {
                    print("Could not get departure from JSON")
                    print(flight)
                    return
                }
                
                guard let arrival = flight["estArrivalAirport"] as? String  else {
                    print("Could not get arrival from JSON")
                    print(flight)
                    return
                }
                
                guard let departureTime = flight["firstSeen"] as? Int?  else {
                    print("Could not get firstSeen from JSON")
                    print(flight)
                    return
                }
                
                guard let arrivalTime = flight["lastSeen"] as? Int?  else {
                    print("Could not get lastSeen from JSON")
                    print(flight)
                    return
                    
                }
                
                flights?.append(Flight(departure: departure, arrival: arrival, departureTime: departureTime, arrivalTime: arrivalTime))
            }
        }
        
        callback(flights, nil)
    }
}
