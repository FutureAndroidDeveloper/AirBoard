//
//  FlightViewModel.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 4/24/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import Foundation

protocol FlightsViewModelDelegate: AnyObject {
    func reciveData()
}

class FlightViewModel {
    
    // MARK: Properties
    weak var delegate: FlightsViewModelDelegate?
    
    private var flights = [Flight]()
    private var beginUnix = 0
    private var endUnix = 0
    private var flightType: FlightType!
    private var airportCode: String!
    
    var data = [String: [Flight]]() {
        didSet {
            delegate?.reciveData()
        }
    }
    var flightsSectionTitles: [String] {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, MMMM d"
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            dateFormatter.defaultDate = Date()
            
            var dateArray = [Date]()
            
            for date in data.keys {
                dateArray.append(dateFormatter.date(from: date)!)
            }
            
            return dateArray.sorted(by: { $0 > $1 }).map { dateFormatter.string(from: $0) }
        }
    }
    
    private let flightService = FlightService()
    private let coreDataManager: CoreDataManager
    
    init(appDeleagte: AppDelegate) {
        coreDataManager = CoreDataManager(appDelegate: appDeleagte)
    }
    
    func getFlights(flightType: FlightType, airportCode: String) {
        self.flightType = flightType
        self.airportCode = airportCode
        
        if data.isEmpty {
            setTimeFrames()
            loadFlights()
        } else {
            delegate?.reciveData()
        }
    }
    
    // MARK: Private Methods
    
    private func setTimeFrames() {
        // get current Date
        let currentDate = Date().getCurrentDate()
        
        // get start and end Date
        let beginDate = currentDate.subtract(days: 2)
        let endDate = currentDate.addingTimeInterval(24 * 60 * 60 - 1)
        
        // set Unix timestamp
        beginUnix = Int(beginDate.timeIntervalSince1970)
        endUnix = Int(endDate.timeIntervalSince1970)
    }
    
    private func loadFlights() {
        
        switch flightType! {
        // if flight type is departure, request flight departures from the airport
        case .departure:
            flightService.getFlights(path: .departure, parameters: (icao: airportCode, begin: beginUnix, end: endUnix)) { [weak self] result in
                guard let self = self else {
                    return
                }
                
                switch result {
                case .success(let flights):
                    self.flights = flights
                    self.setCityNames()
                    self.data = self.convertToData(flights: self.flights)
                case .failure(let error):
                    NSLog(error.description)
                }
            }
        // if flight type is arrivals, request flight arrivals to the airport
        case .arrival:
            flightService.getFlights(path: .departure, parameters: (icao: airportCode, begin: beginUnix, end: endUnix)) { [weak self] result in
                guard let self = self else {
                    return
                }
                
                switch result {
                case .success(let flights):
                    self.flights = flights
                    self.setCityNames()
                    self.data = self.convertToData(flights: self.flights)
                case .failure(let error):
                    NSLog(error.description)
                }
            }
        }
    }
    
    private func convertToData(flights: [Flight]) -> [String: [Flight]] {
        var data = [String: [Flight]]()
        createSectionTitles(for: &data)
        
        // Get the date and create dictionary
        for flight in flights {
            var flightKey = ""
        
            switch flightType! {
            case .departure:
                if let departureTime = flight.departureTime {
                    flightKey = departureTime.unixTimestampToString()
                }
            case .arrival:
                if let arrivalTime = flight.arrivalTime {
                    flightKey = arrivalTime.unixTimestampToString()
                }
            }
            
            // grouping flights by sections
            if let _ = data[flightKey] {
                data[flightKey]?.append(flight)
            } else {
                data[flightKey] = [flight]
            }
        }
        
        return data
    }
    
    private func createSectionTitles(for flight: inout [String: [Flight]]) {
        let unixDay = 86400
        var currentUnixDay = beginUnix
        
        // Make a step one day in length and write this date in the array.
        while currentUnixDay <= endUnix {
            let title = currentUnixDay.unixTimestampToString()
            flight[title] = []
            currentUnixDay += unixDay
        }
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
            
            coreDataManager.syncFetchCityNameFromDB(with: icao) { [weak self] result in
                guard let self = self else {
                    return
                }
                
                switch result {
                case .success(let city):
                    self.flights[flightIndex].city = city
                case .failure(let error):
                    NSLog(error.description)
                }
            }
        }
    }
}
