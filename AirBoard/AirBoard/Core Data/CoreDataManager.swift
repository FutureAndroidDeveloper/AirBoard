//
//  CoreDataManager.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 3/29/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
    private let appDelegate: AppDelegate
    private let backContext: NSManagedObjectContext
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
        self.backContext = appDelegate.persistentContainer.newBackgroundContext()
    }
    
    func loadAirportsFromDB(callback: @escaping ([Airport]) -> Void) {
        
        backContext.perform {
            print("load Data from DB")
            
            var downloadedAirports = [Airport]()
            
            do {
                let result = try self.backContext.fetch(CDAirport.fetchRequest())
                
                guard let airports = result as? [CDAirport] else {
                    print("Can not load airports info from Core Data")
                    DispatchQueue.main.async {
                        callback(downloadedAirports)
                    }
                    
                    return
                }
                
                for airport in airports {
                    downloadedAirports.append(Airport(name: airport.name ?? "Unkown", city: airport.city, code: airport.code ?? "Unkown"))
                }
                
            } catch let error as NSError {
                print("Could not save \(error)")
            }
            
            DispatchQueue.main.async {
                callback(downloadedAirports)
            }
        }
    }
    
    func saveAirports(airports: [Airport]) {
        backContext.perform {
            print("Start save data to DB")
            
            for airport in airports {
                let cdAirport = CDAirport(context:  self.backContext)
                
                cdAirport.setValue(airport.name, forKey: "name")
                cdAirport.setValue(airport.city, forKey: "city")
                cdAirport.setValue(airport.code, forKey: "code")
                
                do {
                    try self.backContext.save()
                } catch let error as NSError {
                    print("Could not save \(error)")
                }
            }
            
            print("Finish save data")
        }
    }
}
