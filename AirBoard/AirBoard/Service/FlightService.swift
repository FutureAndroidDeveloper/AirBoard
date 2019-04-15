//
//  FlightService.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 3/25/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import Foundation

enum APIError: Error {
    case InvalidURL
    case InvalidData
    case ImageError
    case CodableError
    
    var description: String {
        switch self {
        case .InvalidURL:
            return "An invalid URL was received."
        case .InvalidData:
            return "Received wrong datа."
        case .ImageError:
            return "Couldn't decode image urls."
        case .CodableError:
            return "Couldn't decode received data."
        }
    }
}

class FlightService {
    
    enum Path: String {
        case departure = "flights/departure"
        case arrival = "flights/arrival"
    }
    
    // MARK: Properties
    
    private let baseUrl = "https://opensky-network.org/api/"
    private let session = URLSession.shared
    
    // TODO: you can make success block and failure like in CoreDataManager and refactor func.
    // FIXED
    func getFlights(path: Path, parameters: (icao: String, begin: Int, end: Int), complition: @escaping ([Flight]) -> Void,
                    failure: @escaping (APIError) -> Void) {
                
        let paramPath = buildParamPath(with: parameters)
        
        // create full URL
        guard let url = URL(string: baseUrl + path.rawValue + paramPath) else {
            failure(.InvalidURL)
            return
        }
        
        let urlRequest = URLRequest(url: url)
        
        // make the request
        session.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    failure(.InvalidData)
                }
                return
            }
            
            if let flights = try? JSONDecoder().decode([Flight].self, from: data) {
                DispatchQueue.main.async {
                    complition(flights)
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
