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

    // Properties
    private let accessKey = "bf3baf99d295c0d9579ae6a40fc2147131015142e9cf5753731a61a0c181066d"
    private let baseUrl = "https://api.unsplash.com/"
    private let path = "/photos/random"
    private let session = URLSession.shared
    
    func loadImage(callback: @escaping (Data?) -> Void) {
        let paramPath = buildParamPath(query: "Airplane", orientation: .landscape)
        
        // create full URL
        guard let url = URL(string: baseUrl + path + paramPath) else {
            DispatchQueue.main.async {
                callback(nil)
            }
            print("url creating error")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        
        session.dataTask(with: urlRequest) { (data, response, error) in
            
            guard let data = data else {
                DispatchQueue.main.async {
                    callback(nil)
                }
                print("invalid data")
                return
            }
            
            // get image url
            guard let image = try? JSONDecoder().decode(Image.self, from: data) else {
                DispatchQueue.main.async {
                    callback(nil)
                }
                print("cant decode image urls")
                return
            }
            
            // create image url from string
            guard let imageUrl = URL(string: image.urls.small) else {
                DispatchQueue.main.async {
                    callback(nil)
                }
                print("can't create URL from String")
                return
            }
            
            if let data = try? Data(contentsOf: imageUrl) {
                DispatchQueue.main.async {
                    callback(data)
                }
            }
        }.resume()
    }
    
    // MARK: Private Methods
    
    private func buildParamPath(query: String, orientation: Orientation) -> String {
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
}
