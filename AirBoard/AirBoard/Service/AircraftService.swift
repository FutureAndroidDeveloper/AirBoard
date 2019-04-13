//
//  AircraftService.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 4/10/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import Foundation

struct ImageSize: Decodable {
    let full: String
    let regular: String
    let small: String
}

struct Image: Decodable {
    let id: String
    let width: Int
    let height: Int
    let color: String
    let urls: ImageSize
}

enum Orientation: String {
    case landscape = "landscape"
    case portrait = "portrait"
    case squarish = "squarish"
}

class AircraftService {

    // MARK: Properties
    private let imageAccessKey = "bf3baf99d295c0d9579ae6a40fc2147131015142e9cf5753731a61a0c181066d"
    private let imageBaseUrl = "https://api.unsplash.com"
    private let imagePath = "/photos/random"
    
    private let aircraftAccessKey = "e77dd9-351748"
    private let aicraftBaseUrl = "https://aviation-edge.com/v2/public"
    private let aircraftpath = "/airplaneDatabase"
    private let session = URLSession.shared
    
    func loadImage(success: @escaping (Data) -> Void, failure: @escaping (APIError) -> Void) {
        let paramPath = buildParamImagePath(query: "Airplane", orientation: .landscape)
        
        // create full URL
        guard let url = URL(string: imageBaseUrl + imagePath + paramPath) else {
            DispatchQueue.main.async {
                failure(.InvalidURL)
            }
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Client-ID \(imageAccessKey)", forHTTPHeaderField: "Authorization")
        
        session.dataTask(with: urlRequest) { (data, response, error) in
            
            guard let data = data else {
                DispatchQueue.main.async {
                    failure(.InvalidData)
                }
                return
            }
            
            // get image url
            guard let image = try? JSONDecoder().decode(Image.self, from: data) else {
                DispatchQueue.main.async {
                    failure(.ImageError)
                }
                return
            }
            
            // create image url from string
            guard let imageUrl = URL(string: image.urls.small) else {
                DispatchQueue.main.async {
                    failure(.InvalidURL)
                }
                return
            }
            
            if let data = try? Data(contentsOf: imageUrl) {
                DispatchQueue.main.async {
                    success(data)
                }
            }
        }.resume()
    }
    
    func loadAircraft(icao: String, success: @escaping (Aircraft) -> Void, failure: @escaping (APIError) -> Void) {
        let paramPath = buildParamAircraftPath(key: aircraftAccessKey, icao: icao)
        
        // create full URL
        guard let url = URL(string: aicraftBaseUrl + aircraftpath + paramPath) else {
            DispatchQueue.main.async {
                failure(.InvalidURL)
            }
            return
        }

        let urlRequest = URLRequest(url: url)
        
        session.dataTask(with: urlRequest) { (data, response, error) in
            
            guard let data = data else {
                DispatchQueue.main.async {
                    failure(.InvalidData)
                }
                return
            }
            
            // get aircraft info
            guard let aircraft = try? JSONDecoder().decode([Aircraft].self, from: data) else {
                DispatchQueue.main.async {
                    failure(.CodableError)
                }
                return
            }
            
            DispatchQueue.main.async {
                success(aircraft.first!)
            }
        }.resume()
    }
    
    // MARK: Private Methods
    
    private func buildParamImagePath(query: String, orientation: Orientation) -> String {
        var components = URLComponents()
        
        // build parameter path
        let queryItem = URLQueryItem(name: "query", value: query)
        let queryItemOrientation = URLQueryItem(name: "orientation", value: orientation.rawValue)
        
        components.queryItems = [queryItem, queryItemOrientation]
        
        guard let paramPath = components.url else {
            fatalError("Parameter generation error")
        }
        
        return paramPath.description
    }
    
    private func buildParamAircraftPath(key: String, icao: String) -> String {
        var components = URLComponents()
        
        // build parameter path
        let queryItemKey = URLQueryItem(name: "key", value: key)
        let queryItemIcao = URLQueryItem(name: "hexIcaoAirplane", value: icao.uppercased())
        
        components.queryItems = [queryItemKey, queryItemIcao]
        
        guard let paramPath = components.url else {
            fatalError("Parameter generation error")
        }
        
        return paramPath.description
    }
}
