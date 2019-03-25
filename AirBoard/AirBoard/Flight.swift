//
//  Flights.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 3/25/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import Foundation
class Flight {
    
    // MARK: Properties
    
    var departure: String?
    var arrival: String?
    var departureTime: Int?
    var arrivalTime: Int?
    
    init(departure: String?, arrival: String?, departureTime: Int?, arrivalTime: Int?) {
        self.departure = departure
        self.arrival = arrival
        self.departureTime = departureTime
        self.arrivalTime = arrivalTime
    }
}


struct AirportModel: Decodable {
    let name: String
    let city: String?
    let code: String
    
}
