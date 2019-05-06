//
//  Track.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 5/1/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import Foundation

struct Track: Codable {
    let startTime: Int
    let endTime: Int
    let path: [Path]
}

extension Track {
    enum CodingKeys: String, CodingKey {
        case startTime
        case endTime
        case path
    }
}
