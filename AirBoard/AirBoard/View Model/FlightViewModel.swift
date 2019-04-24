//
//  FlightViewModel.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 4/24/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import Foundation

protocol FlightsViewModelDelegate: class {
    func reciveData()
}

class FlightViewModel {
    
    // MARK: Properties
    weak var delegate: FlightsViewModelDelegate?
    
    private var flights = [Flight]()
    private var beginUnix: Int
    private var endUnix: Int
    private var flightType: FlightType!
    private var airportCode: String!
    
    var flightsToDisplay: [String: [Flight]]
    var flightsSectionTitles: [String]
    
    private let flightService: FlightService
    private let dateService: DateService
    private let coreDataManager: CoreDataManager
    
    init(appDeleagte: AppDelegate) {
        flightService = FlightService()
        dateService = DateService()
        coreDataManager = CoreDataManager(appDelegate: appDeleagte)
        
        beginUnix = 0
        endUnix = 0
        flightsToDisplay = [:]
        flightsSectionTitles = []
    }
    
    func getFlights(flightType: FlightType, airportCode: String) {
        self.flightType = flightType
        self.airportCode = airportCode
        
        if flightsToDisplay.isEmpty {
            setTimeFrames()
            loadFlights()
        } else {
            delegate?.reciveData()
        }
    }
    
    // MARK: Private Methods
    
    private func setTimeFrames() {
        // get current Date
        let currentDate = dateService.getCurrentDate()
        
        // get start and end Date
        let beginDate = dateService.subract(from: currentDate, days: 2)
        let endDate = currentDate.addingTimeInterval(24 * 60 * 60 - 1)
        
        // set Unix timestamp
        beginUnix = Int(beginDate.timeIntervalSince1970)
        endUnix = Int(endDate.timeIntervalSince1970)
    }
    
    private func loadFlights() {
        
        switch flightType! {
        // if flight type is departure, request flight departures from the airport
        case .departure:
            flightService.getFlights(path: .departure, parameters: (icao: airportCode, begin: beginUnix, end: endUnix), complition: { [weak self] flights in
                self?.flights = flights
                self?.prepareToDisplay()
                self?.delegate?.reciveData()
                }, failure: { error in
                    NSLog(error.description)
            })
        // if flight type is arrivals, request flight arrivals to the airport
        case .arrival:
            flightService.getFlights(path: .arrival, parameters: (icao: airportCode, begin: beginUnix, end: endUnix), complition: { [weak self] flights in
                self?.flights = flights
                self?.prepareToDisplay()
                self?.delegate?.reciveData()
                }, failure: { error in
                    NSLog(error.description)
            })
        }
    }
    
    private func prepareToDisplay() {
        setCityNames()
        
        // Get the date and create dictionary
        for flight in flights {
            
            // grouping flights by sections
            let flightKey = dateService.convert(unix: flight.arrivalTime ?? 0 )
            
            if let _ = flightsToDisplay[flightKey] {
                flightsToDisplay[flightKey]?.append(flight)
            } else {
                flightsToDisplay[flightKey] = [flight]
            }
        }
        
        createSectionTitles()
    }
    
    private func createSectionTitles() {
        let unixDay = 86400
        var currentUnixDay = beginUnix
        
        // Make a step one day in length and write this date in the array.
        while currentUnixDay <= endUnix {
            flightsSectionTitles.append(dateService.convert(unix: currentUnixDay))
            currentUnixDay += unixDay
        }
        
        flightsSectionTitles.reverse()
    }
    
    private func setCityNames() {
        var icao = Optional(String())
        
        for flightIndex in 0..<flights.count {
            switch flightType! {
            case .departure:
                icao = flights[flightIndex].arrival
            case .arrival:
                icao = flights[flightIndex].departure
            }
            
            coreDataManager.syncFetchCityNameFromDB(with: icao, success: { [weak self] city in
                self?.flights[flightIndex].city = city
                }, failure: { error in
                    // pass
            })
        }
    }
}
