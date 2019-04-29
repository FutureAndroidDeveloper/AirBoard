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
    private let dateService = DateService()
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
                guard let self = self else {
                    return
                }
                
                self.flights = flights
                self.setCityNames()
                self.data = self.convertToData(flights: self.flights)
                
                }, failure: { error in
                    NSLog(error.description)
            })
        // if flight type is arrivals, request flight arrivals to the airport
        case .arrival:
            flightService.getFlights(path: .arrival, parameters: (icao: airportCode, begin: beginUnix, end: endUnix), complition: { [weak self] flights in
                guard let self = self else {
                    return
                }
                
                self.flights = flights
                self.setCityNames()
                self.data = self.convertToData(flights: self.flights)
                
                }, failure: { error in
                    NSLog(error.description)
            })
        }
    }
    
    private func convertToData(flights: [Flight]) -> [String: [Flight]] {
        var data = [String: [Flight]]()
        createSectionTitles(for: &data)
        
        // Get the date and create dictionary
        for flight in flights {
            
            // grouping flights by sections
            let flightKey = dateService.convert(unix: flight.arrivalTime ?? 0 )
            
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
            let title = dateService.convert(unix: currentUnixDay)
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
            
            coreDataManager.syncFetchCityNameFromDB(with: icao, success: { [weak self] city in
                guard let self = self else {
                    return
                }
                
                self.flights[flightIndex].city = city
                
            }, failure: { error in
                // pass
            })
        }
    }
}
