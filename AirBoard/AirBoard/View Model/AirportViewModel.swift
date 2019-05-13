//
//  AirportViewModel.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 4/18/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import Foundation

protocol AirportsViewModelDelegate: AnyObject {
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
            self.data = self.convertToData(airports: airports)
        } else {
            let filteredAirports = airports.filter { $0.name.lowercased().contains(cityName.lowercased()) }
            data = ["Founded": filteredAirports]
        }
    }
    
    // MARK: Private methods
    
    private func loadDataFromDataBase() {
        coreDataManager.loadAirportsFromDB { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let data):
                self.airports = data
                self.data = self.convertToData(airports: data)
            case .failure(let error):
                NSLog(error.description)
                self.loadAirports()
            }
        }
    }
    
    private func loadAirports() {
        airportService.getAirports { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let airports):
                self.coreDataManager.saveAirports(airports: airports)
                self.airports = airports.sorted(by: { $0.name < $1.name })
                self.data = self.convertToData(airports: airports.sorted(by: { $0.name < $1.name }))
            case .failure(let error):
                NSLog(error.description)
            }
        }
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
