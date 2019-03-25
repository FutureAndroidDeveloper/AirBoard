//
//  FlightService.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 3/25/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import Foundation

class FlightService {
    
    var flights: [Flight]?
    
    
    init() {
        flights = []
    }
    
    func getFlights(jsonFlights: [[String: Any]]) {
        
        for flight in jsonFlights {
            guard let departure = flight["estDepartureAirport"] as? String  else {
                print("Could not get departure from JSON")
                return
            }
            
            guard let arrival = flight["estArrivalAirport"] as? String  else {
                print("Could not get arrival from JSON")
                return
            }
            
            guard let departureTime = flight["firstSeen"] as? Int?  else {
                print("Could not get firstSeen from JSON")
                return
            }
            
            guard let arrivalTime = flight["lastSeen"] as? Int?  else {
                print("Could not get lastSeen from JSON")
                return
            }
            
            flights?.append(Flight(departure: departure, arrival: arrival, departureTime: departureTime, arrivalTime: arrivalTime))
        }
    }
}
