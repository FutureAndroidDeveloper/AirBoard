//
//  Path.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 5/1/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import Foundation

struct Path: Codable {
    let time: Int
    let latitude: Float?
    let longitude: Float?
    let baro: Float?
    let trueTrack: Float?
    let onGround: Bool
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.time = try container.decode(Int.self)
        self.latitude = try container.decode(Float.self)
        self.longitude = try container.decode(Float.self)
        self.baro = try container.decode(Float.self)
        self.trueTrack = try container.decode(Float.self)
        self.onGround = try container.decode(Bool.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(time)
        try container.encode(latitude)
        try container.encode(longitude)
        try container.encode(baro)
        try container.encode(trueTrack)
        try container.encode(onGround)
    }
}
