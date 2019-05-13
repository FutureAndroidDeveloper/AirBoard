//
//  CoreDataManager.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 3/29/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import Foundation
import CoreData

enum DataBaseError: Error {
    case LoadDataError
    case SaveDataError
    case EmptyDataBase
    case FilteringError
    case NilFileld
    
    var description: String {
        switch self {
        case .LoadDataError:
            return "Could not load airports."
        case .SaveDataError:
            return "Could not save data."
        case .EmptyDataBase:
            return "Database is empty."
        case .FilteringError:
            return "Could not find the requested field"
        case .NilFileld:
            return "Requested field is nil"
        }
    }
}

class CoreDataManager {
    
    private let appDelegate: AppDelegate
    private let backContext: NSManagedObjectContext
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
        self.backContext = appDelegate.persistentContainer.newBackgroundContext()
    }
    
    func loadAirportsFromDB(completion: @escaping (Result<[Airport], DataBaseError>) -> Void) {
        backContext.perform {
            NSLog("Load data from DB")
            do {
                let result = try self.backContext.fetch(CDAirport.fetchRequest())
                
                if let data = result as? [CDAirport] {
                    let airports = data.map { Airport(name: $0.name ?? "Unkown", city: $0.city, code: $0.code ?? "Unkown") }
                    
                    if airports.isEmpty {
                        DispatchQueue.main.async {
                            completion(.failure(.EmptyDataBase))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.success(airports.sorted(by: { $0.name < $1.name })))
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(.LoadDataError))
                    }
                }
            } catch {
                completion(.failure(.LoadDataError))
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
            }
            
            do {
                try self.backContext.save()
            } catch {
                NSLog(DataBaseError.SaveDataError.description)
            }
            NSLog("Finish save data")
        }
    }
    
    func syncFetchCityNameFromDB(with cityIcao: String?, completion: @escaping (Result<String, DataBaseError>) -> Void) {
        guard let cityIcao = cityIcao else {
            completion(.failure(.NilFileld))
            return
        }
        
        guard let airport = filteredFetch(icao: cityIcao, context: appDelegate.persistentContainer.viewContext) else {
            completion(.failure(.FilteringError))
            return
        }
        
        completion(.success(airport.city!))
    }
    
    func fetchCityNameFromDB(with cityIcao: String?, completion: @escaping (Result<String, DataBaseError>) -> Void) {
        guard let cityIcao = cityIcao else {
            completion(.failure(.NilFileld))
            return
        }
        
        backContext.perform {
            guard let airport = self.filteredFetch(icao: cityIcao, context: self.backContext) else {
                DispatchQueue.main.async {
                    completion(.failure(.FilteringError))
                }
                return
            }
            DispatchQueue.main.async {
                completion(.success(airport.city!))
            }
        }
    }
    
    private func filteredFetch(icao: String, context: NSManagedObjectContext) -> CDAirport? {
        var resultAirport: CDAirport?
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CDAirport")
        request.predicate = NSPredicate(format: "code = %@", icao)
        
        do {
            let result = try context.fetch(request)
            
            if !result.isEmpty {
                if let airport = result[0] as? CDAirport {
                    resultAirport = airport
                }
            }
        } catch { }
        
        return resultAirport
    }
}
