//
//  Aircraft.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 4/10/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import Foundation

struct Aircraft {
    let image: Data
    let departureIcao: String
    let arrivalIcao: String
    let departureCity: String
    let arrivalCity: String
    let registration: String
    let model: String
    let modelCode: String
    let engines: String
    let age: Int
    let firstFlight: String
    
    init(image: Data, departureIcao: String, arrivalIcao: String, departureCity: String, arrivalCity: String, registration: String, model: String, modelCode: String, engines: String, age: Int, firstFlight: String) {
        self.image = image
        self.departureIcao = departureIcao
        self.arrivalIcao = arrivalIcao
        self.departureCity = departureCity
        self.arrivalCity = arrivalCity
        self.registration = registration
        self.model = model
        self.modelCode = modelCode
        self.engines = engines
        self.age = age
        self.firstFlight = firstFlight
    }
}
