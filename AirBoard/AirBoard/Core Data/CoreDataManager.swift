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
    
    func loadAirportsFromDB(success: @escaping ([Airport]) -> Void,
                            failure: @escaping (Error) -> Void) {
        backContext.perform {
            NSLog("Load data from DB")
            do {
                let result = try self.backContext.fetch(CDAirport.fetchRequest())
                
                if let data = result as? [CDAirport] {
                    let airports = data.map { Airport(name: $0.name ?? "Unkown", city: $0.city, code: $0.code ?? "Unkown") }
                    
                    DispatchQueue.main.async {
                        success(airports)
                    }
                } else {
                    NSLog("Could not load airports")
                    failure(NSError(domain: "LoadAirportsFromDBDomain", code: 401) as Error)
                }
            } catch let error as NSError {
                NSLog("Could not load airports", error)
                failure(error)
            }
        }
    }
    
    func saveAirports(airports: [Airport]) {
        backContext.perform {
            NSLog("Start save data to DB")
            
            for airport in airports {
                let cdAirport = CDAirport(context:  self.backContext)
                
                cdAirport.setValue(airport.name, forKey: "name")
                cdAirport.setValue(airport.city, forKey: "city")
                cdAirport.setValue(airport.code, forKey: "code")
                
                do {
                    try self.backContext.save()
                } catch let error as NSError {
                    NSLog("Could not save", error)
                }
            }
            
            NSLog("Finish save data")
        }
    }
}
