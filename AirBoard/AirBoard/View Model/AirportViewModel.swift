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
    
    private var airports: [Airport]
    var airportsToDisplay: [String: [Airport]]
    var sectionTitles: [String]
    
    private let airportService: AirportService
    private let coreDataManager: CoreDataManager
    
    init(appDelegate: AppDelegate) {
        coreDataManager = CoreDataManager(appDelegate: appDelegate)
        airportService = AirportService()
        airports = []
        airportsToDisplay = [:]
        sectionTitles = []
    }
    
    func getData() {
        if airports.isEmpty {
            loadDataFromDataBase()
        }
    }
    
    func searchAirports(cityName: String) {
        if cityName.isEmpty {
            airportsToDisplay.removeAll()
            prepareToDisplay()
        } else {
            let filteredAirports = airports.filter { $0.name.lowercased().contains(cityName.lowercased()) }
            airportsToDisplay = ["Founded": filteredAirports]
            sectionTitles = ["Founded"]
        }
        
        delegate?.reciveData()
    }
    
    // MARK: Private methods
    
    private func loadDataFromDataBase() {
        coreDataManager.loadAirportsFromDB(success: { [weak self] data in
            self?.airports = data
            self?.prepareToDisplay()
            self?.delegate?.reciveData()
            }, failure: { [weak self] error in
                NSLog(error.description)
                self?.loadAirports()
        })
    }

    private func loadAirports() {
        airportService.getAirports(success: { [weak self] airports in
            self?.airports = airports.sorted(by: { $0.name < $1.name })
            self?.coreDataManager.saveAirports(airports: self!.airports)
            self?.prepareToDisplay()
            self?.delegate?.reciveData()
            }, failure: { error in
                NSLog(error.description)
        })
    }
    
    private func prepareToDisplay() {
        if airports.isEmpty {
            return
        }
        
        // Get the first letter in airport name and create dictionary
        for airport in airports {
            guard let firstChar = airport.name.first else {
                fatalError("cant get first char - \(airport.name)")
            }
            
            let airportKey = String(firstChar)
            
            if var _ = airportsToDisplay[airportKey] {
                airportsToDisplay[airportKey]?.append(airport)
            } else {
                airportsToDisplay[airportKey] = [airport]
            }
        }
        
        // Get the section titles from the dictionary's keys and sort them in ascending order
        sectionTitles = airportsToDisplay.keys.sorted()
    }
}
