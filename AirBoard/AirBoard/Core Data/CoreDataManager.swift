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
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
    }
    
    func loadDataFromDB() -> [Airport] {
        
        print("load Data from DB")
        
        var downloadedAirports = [Airport]()
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            let result = try context.fetch(CDAirport.fetchRequest())
            
            guard let airports = result as? [CDAirport] else {
                print("Can not load airports info from Core Data")
                return downloadedAirports
            }
            
            for airport in airports {
                downloadedAirports.append(Airport(name: airport.name ?? "Unkown", city: airport.city, code: airport.code ?? "Unkown"))
            }
            
        } catch let error as NSError {
            print("Could not save \(error)")
        }
        
        return downloadedAirports
    }
    
    
    func saveAirports(airports: [Airport]) {
        let backContext = appDelegate.persistentContainer.newBackgroundContext()
        
        appDelegate.persistentContainer.performBackgroundTask { (context) in
            self.backgroundSaveAirports(airports: airports, context: backContext)
        }
    }
    
    
    // MARK: Private Methods
    
    private func backgroundSaveAirports(airports: [Airport], context: NSManagedObjectContext) {
        
        context.perform {
            print("Start save data to DB")
            
            for airport in airports {
                let cdAirport = CDAirport(context:  context)
                
                cdAirport.setValue(airport.name, forKey: "name")
                cdAirport.setValue(airport.city, forKey: "city")
                cdAirport.setValue(airport.code, forKey: "code")
                
                do {
                    try context.save()
                } catch let error as NSError {
                    print("Could not save \(error)")
                }
            }
            
            print("Finish save data")
        }
    }
}
