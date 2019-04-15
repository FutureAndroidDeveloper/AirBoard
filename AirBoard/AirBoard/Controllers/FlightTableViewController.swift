//
//  FlightViewController.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 4/8/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import UIKit

class FlightTableViewController: UITableViewController {

    // MARK: Properties
    
    var activityIndicatorView = UIActivityIndicatorView(style: .gray)
    
    private let service = FlightService()
    private let dateService = DateService()
    private var flights = [Flight]()
    
    var flightType = FlightType.departure
    var airportCode = String()
    var beginUnix = Int()
    var endUnix = Int()
    
    // Sections data
    private var flightsDict = [String: [Flight]]()
    private var flightsSectionTitles = [String]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = activityIndicatorView
        loadFlights()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return flightsSectionTitles.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return flightsSectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let flightKey = flightsSectionTitles[section]
        guard let flightValues = flightsDict[flightKey] else { return 0 }
        
        return flightValues.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "FlightCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FlightTableViewCell else {
            fatalError("FlightCell cell error")
        }
        
        let flightKey = flightsSectionTitles[indexPath.section]
        cell.accessoryType = .disclosureIndicator

        if let flightValues = flightsDict[flightKey] {
            
            switch flightType {
            case .departure:
                cell.flightTimeLabel.text = Double(flightValues[indexPath.row].departureTime!).getDateFromUTC()
                cell.flightCityLabel.text = flightValues[indexPath.row].arrival ?? "Unkown"
                
            case .arrival:
                cell.flightTimeLabel.text = Double(flightValues[indexPath.row].arrivalTime!).getDateFromUTC()
                cell.flightCityLabel.text = flightValues[indexPath.row].departure ?? "Unkown"
            }
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        case "ShowDetail":
            guard let aircraftDetailViewController = segue.destination as? DetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedMealCell = sender as? FlightTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }

            let flightKey = flightsSectionTitles[indexPath.section]
            
            if let flightValues = flightsDict[flightKey] {
                aircraftDetailViewController.flight = flightValues[indexPath.row]
            }
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    // MARK: Private Methods
    
    private func loadFlights() {
        activityIndicatorView.startAnimating()
        tableView.separatorStyle = .none
        
        switch flightType {
        // if flight type is departure, request flight departures from the airport
        case .departure:
            service.getFlights(path: .departure, parameters: (icao: airportCode, begin: beginUnix, end: endUnix), complition: { [weak self] flights in
                self?.flights = flights.sorted(by: {$0.arrivalTime! < $1.arrivalTime!})
                self?.createFlightsDict()
                }, failure: { error in
                    NSLog(error.description)
            })
        // if flight type is arrivals, request flight arrivals to the airport
        case .arrival:
            service.getFlights(path: .arrival, parameters: (icao: airportCode, begin: beginUnix, end: endUnix), complition: { [weak self] flights in
                self?.flights = flights.sorted(by: {$0.arrivalTime! < $1.arrivalTime!})
                self?.createFlightsDict()
                }, failure: { error in
                    NSLog(error.description)
            })
        }
    }
    
    private func createSectionTitles() {
        let unixDay = 86400
        var currentUnixDay = beginUnix
        
        // Make a step one day in length and write this date in the dictionary.
        while currentUnixDay <= endUnix {
            flightsSectionTitles.append(dateService.convert(unix: currentUnixDay))
            
            currentUnixDay += unixDay
        }
    }
    
    private func createFlightsDict() {
        // Get the date and create dictionary
        for flight in flights {
            
            let flightKey = dateService.convert(unix: flight.arrivalTime ?? 0 )
            
            if var _ = flightsDict[flightKey] {
                flightsDict[flightKey]?.append(flight)
            } else {
                flightsDict[flightKey] = [flight]
            }
        }
        
        createSectionTitles()
        stopIndicator()
        tableView.reloadData()
    }
    
    private func stopIndicator () {
        self.activityIndicatorView.stopAnimating()
        self.tableView.separatorStyle = .singleLine
    }
}
