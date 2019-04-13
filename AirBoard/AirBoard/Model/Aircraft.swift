//
//  Aircraft.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 4/10/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import Foundation

struct Aircraft {
    let registration: String
    let model: String
    let enginesType: String
    let enginesCount: String
    let age: String
    let icaoAirplane: String
    let planeOwner: String
}

extension Aircraft: Codable {
    
    enum CodingKeys: String, CodingKey {
        case registration = "numberRegistration"
        case model = "productionLine"
        case age = "planeAge"
        case icaoAirplane = "hexIcaoAirplane"
        case enginesType
        case enginesCount
        case planeOwner
    }
}
