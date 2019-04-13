//
//  Flights.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 3/25/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import Foundation

struct Flight {
    let departure: String?
    let arrival: String?
    let departureTime: Int?
    let arrivalTime: Int?
    let icao: String
}

extension Flight: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case departure = "estDepartureAirport"
        case arrival = "estArrivalAirport"
        case departureTime = "firstSeen"
        case arrivalTime = "lastSeen"
        case icao = "icao24"
    }
}
