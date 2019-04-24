//
//  AirportViewModel.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 4/18/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import Foundation

protocol AirportsViewModelDelegate: class {
    func reciveData()
}

class AirportViewModel {
    
    // MARK: Properties
    weak var delegate: AirportsViewModelDelegate?
    
    var data = [String: [Airport]]() {
        didSet {
            delegate?.reciveData()
        }
    }
    var sectionTitles: [String] {
        get {
            return data.keys.sorted()
        }
    }
    
    private var airports = [Airport]()
    private let airportService = AirportService()
    private let coreDataManager: CoreDataManager
    
    init(appDelegate: AppDelegate) {
        coreDataManager = CoreDataManager(appDelegate: appDelegate)
    }
    
    func getData() {
        if data.isEmpty {
            loadDataFromDataBase()
        }
    }
    
    func searchAirports(cityName: String) {
        if cityName.isEmpty {
            data.removeAll()
        } else {
            let filteredAirports = airports.filter { $0.name.lowercased().contains(cityName.lowercased()) }
            data = ["Founded": filteredAirports]
        }
    }
    
    // MARK: Private methods
    
    private func loadDataFromDataBase() {
        coreDataManager.loadAirportsFromDB(success: { [weak self] data in
            guard let self = self else {
                return
            }
            
            self.data = self.convertToData(airports: data)
            
            }, failure: { [weak self] error in
                NSLog(error.description)
                self?.loadAirports()
            })
    }

    private func loadAirports() {
        airportService.getAirports(success: { [weak self] airports in
            guard let self = self else {
                return
            }
            
            self.coreDataManager.saveAirports(airports: self.airports)
            self.data = self.convertToData(airports: airports.sorted(by: { $0.name < $1.name }))
            
            }, failure: { error in
                NSLog(error.description)
            })
    }
    
    private func convertToData(airports: [Airport]) -> [String: [Airport]] {
        // Get the first letter in airport name and create dictionary
        var data = [String: [Airport]]()
        
        for airport in airports {
            guard let firstChar = airport.name.first else {
                fatalError("cant get first char - \(airport.name)")
            }
            
            let airportKey = String(firstChar)
            
            if var _ = data[airportKey] {
                data[airportKey]?.append(airport)
            } else {
                data[airportKey] = [airport]
            }
        }
        
        return data
    }
}
