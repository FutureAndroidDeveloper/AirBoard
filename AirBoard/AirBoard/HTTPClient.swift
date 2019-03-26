//
//  HTTPClient.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 3/22/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import Foundation

protocol HTTPClient {
    init(baseUrl: String)
    func get(path: String, parameters: [String: Any], callback: @escaping (Any?, Error?) -> Void)
}


class URLSessionHTTPClient: HTTPClient {
    public static let SEC_TO_DAYS = 86400
    
    let baseUrl: String
    
    required init(baseUrl: String) {
        self.baseUrl = baseUrl
    }
    
    func get(path: String, parameters: [String: Any], callback: @escaping (Any?, Error?) -> Void) {
        
        // Set up the URL request
        guard let url = URL(string: baseUrl + path + getParamPath(parameters: parameters)) else {
            return
        }
        
        let urlRequest = URLRequest(url: url)
        
        // set up the session
        let session = URLSession.shared
        
        // make the request
        session.dataTask(with: urlRequest) { (data, response, error) in
            
            if let response = response {
                print(response)
            }
            
            // make sure we got data
            guard let responseData = data else {
                return
            }
            
//            do {
//                let posts = try JSONDecoder().decode([Flight].self, from: responseData)
//                print(posts)
//            } catch {
//                print(error)
//                //prints "No value associated with key title (\"title\")."
//            }
            
    
            
            
            // parse the result as Array of [String: Any]
            do {
                guard let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [[String: Any]] else {
                    return
                }
                
                print(json)
                
                callback(json, nil)
                
            } catch {
                print(error)
            }
        }.resume()
    }
    
    
    // MARK: Private Methods
    
    private func getParamPath(parameters: [String: Any]) -> String {
        var resultString = "?"
        
        if parameters.isEmpty {
            resultString = ""
        }
        
        if let airportICAO = parameters["airport"] as? String {
            resultString += "airport=" + airportICAO + "&"
        } else {
            print("Can not get ICAO")
        }
        
        if let begin = parameters["begin"] as? Int {
            resultString += "begin=" + String(begin) + "&"
        } else {
            print("Can not get begin time")
        }
        
        if let end = parameters["end"] as? Int {
            resultString += "end=" + String(end)
        } else {
            print("Can not get end time")
        }
        
        
        return resultString
    }
    
    private func isCorrectTime(parameters: [String: Any]) -> Bool {
        var isCorrect = false
        
        guard let begin = parameters["begin"] as? Int else {
            fatalError("Can not get begin time")
        }
        
        guard let end = parameters["end"] as? Int else {
            fatalError("Can not get end time")
        }
        
        if (end - begin) / URLSessionHTTPClient.SEC_TO_DAYS < 7 {
            isCorrect = true
        } else {
            print("The given time interval must not be larger than seven days!")
        }
        
        return isCorrect
    }
}


