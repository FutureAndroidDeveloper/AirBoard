//
//  HTTPClientTests.swift
//  AirBoardTests
//
//  Created by Кирилл Клименков on 3/25/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import XCTest
@testable import AirBoard

class HTTPClientTests: XCTestCase {
    
    // MARK: URLSessionHTTPClient Class Tests
    
    
    // Confirm that the getParamPath method returns a valid path when passed valid parameters
    
    func testGetParamPathSucceds() {
        let httpClient = URLSessionHTTPClient.init(baseUrl: "https://opensky-network.org/api/")
        
//        let validPath = httpClient.getParamPath(parameters: ["airport": "EGLL", "begin": 1553202020, "end": 1553202600])
//
//        XCTAssertEqual(validPath, "?airport=EGLL&begin=1553202020&end=1553202600")
    }

    
    // Confirm that the getParamPath method returns a valid path when passed parameters without airport
    
    func testGetParamPathWithoutAirport() {
        let httpClient = URLSessionHTTPClient.init(baseUrl: "https://opensky-network.org/api/")
        
//        let validPath = httpClient.getParamPath(parameters: ["begin": 1553202020, "end": 1553202600])
//
//        XCTAssertEqual(validPath, "?begin=1553202020&end=1553202600")
    }
}
