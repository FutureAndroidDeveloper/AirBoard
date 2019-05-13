//
//  Airport.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 3/27/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import Foundation

struct Airport {
    let name: String
    let city: String?
    let code: String
}

extension Airport: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case city
        case code = "icao"
    }
}
