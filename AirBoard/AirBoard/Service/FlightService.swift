//
//  FlightService.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 3/25/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import Foundation

class FlightService {
    enum Path: String {
        case departure = "flights/departure"
        case arrival = "flights/arrival"
    }
    
    // MARK: Properties
    
    private let baseUrl: String = "https://opensky-network.org/api/"
    private let session = URLSession.shared
    
    
    func getDepartureFlights(parameters: (icao: String, begin: Int, end: Int), callback: @escaping (_ flights: [Flight], Error?) -> Void) {
        
        let paramPath = buildParamPath(with: parameters)
        
        // create full URL
        guard let url = URL(string: baseUrl + Path.departure.rawValue + paramPath) else {
            callback([], nil)
            return
        }
        
        let urlRequest = URLRequest(url: url)
        
        // make the request
        session.dataTask(with: urlRequest) { (data, response, error) in
            
            guard let data = data else {
                DispatchQueue.main.async {
                    callback([], nil)
                }
                return
            }
            
            if let flights = try? JSONDecoder().decode([Flight].self, from: data) {
                DispatchQueue.main.async {
                    callback(flights, nil)
                }
            }
        }.resume()
    }
    
    func getArrivalFlights(parameters: (icao: String, begin: Int, end: Int), callback: @escaping ([Flight], Error?) -> Void) {
        
        let paramPath = buildParamPath(with: parameters)
        
        // create full URL
        guard let url = URL(string: baseUrl + Path.arrival.rawValue + paramPath) else {
            callback([], nil)
            return
        }
        
        let urlRequest = URLRequest(url: url)
        
        session.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    callback([], nil)
                }
                return
            }
            
            if let flights = try? JSONDecoder().decode([Flight].self, from: data) {
                DispatchQueue.main.async {
                    callback(flights, nil)
                }
            }
        }.resume()
    }
    
    
    func getAirports(callback: @escaping ([Airport], Error?) -> Void) {
        
        guard let url = URL(string: "https://raw.githubusercontent.com/ram-nadella/airport-codes/master/airports.json") else {
            callback([], nil)
            return
        }
        
        session.dataTask(with: url) { (data, response, error) in
            
            guard response != nil else {
                DispatchQueue.main.async {
                    callback([], nil)
                }
                print("NIL RESPONSE")
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    callback([], nil)
                }
                print("INVALID  DATA")
                return
            }
            
            if let airports = try? JSONDecoder().decode([String: Airport].self, from: data) {
                DispatchQueue.main.async {
                    callback(airports.compactMap{ $0.value }, nil)
                }
            }
        }.resume()
    }
    
    
    // MARK: Private Methods
    
    private func buildParamPath(with parameters: (icao: String, begin: Int, end: Int)) -> String {
        var components = URLComponents()
        
        // build parameter path
        let queryItemArport = URLQueryItem(name: "airport", value: parameters.icao)
        let queryItemBegin = URLQueryItem(name: "begin", value: parameters.begin.description)
        let queryItemEnd = URLQueryItem(name: "end", value: parameters.end.description)
        
        components.queryItems = [queryItemArport, queryItemBegin, queryItemEnd]
        
        guard let paramPath = components.url else {
            fatalError("Parameter generation error")
        }
        
        return paramPath.description
    }
}
