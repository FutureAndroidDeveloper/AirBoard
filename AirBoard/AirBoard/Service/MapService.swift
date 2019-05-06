//
//  MapService.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 5/1/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import Foundation

class MapService {
    
    // MARK: Properties
    private let baseUrl = "https://dev.kirill.klimenkov:1029384756gexa@opensky-network.org/api/tracks/all"
    private let session = URLSession.shared
    
    func loadDirection(for flight: Flight, completion: @escaping (Result<[Path], APIError>) -> Void) {
        let paramPath = buildParamPath(with: (icao: flight.icao, departureTime: flight.departureTime ?? 0))
        
        // create full URL
        guard let url = URL(string: baseUrl + paramPath) else {
            completion(.failure(.InvalidURL))
            return
        }
        
        let urlRequest = URLRequest(url: url)
            
        session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.InvalidData))
                }
                return
            }
            
            guard let track = try? JSONDecoder().decode(Track.self, from: data) else {
                DispatchQueue.main.async {
                    completion(.failure(.CodableError))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(track.path))
            }
        }).resume()
    }
    
    // MARK: Private Methods
    
    private func buildParamPath(with parameters: (icao: String, departureTime: Int)) -> String {
        var components = URLComponents()
        
        // build parameter path
        let queryItemIcao = URLQueryItem(name: "icao24", value: parameters.icao)
        let queryItemTime = URLQueryItem(name: "time", value: parameters.departureTime.description)
        
        components.queryItems = [queryItemIcao, queryItemTime]
        
        guard let paramPath = components.url else {
            fatalError("Parameter generation error")
        }
        
        return paramPath.description
    }
}
