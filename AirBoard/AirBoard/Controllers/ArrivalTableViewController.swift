//
//  ArrivalTableViewController.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 4/1/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import UIKit

class ArrivalTableViewController: UITableViewController {
    
    // MARK: Properties
    
    private let service = FlightService()
    private var flights = [Flight]() {
        didSet {
            tableView.reloadData()
        }
    }
    var airportCode = String()
    var beginUnix = Int()
    var endUnix = Int()
    
    // Sections and index list
    private var flightsDict = [String: [Flight]]()
    private var flightsSectionTitles = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        loadArrivals()
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
        
        let cellIdentifier = "ArrivalCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ArrivalTableViewCell else {
            fatalError("arrival cell error")
        }
        
        let flightKey = flightsSectionTitles[indexPath.section]
        
        if let flightValues = flightsDict[flightKey] {
            cell.departureCityLabel.text = flightValues[indexPath.row].departure ?? "Unkown"
            cell.arrivalTimeLabel.text = Double(flightValues[indexPath.row].arrivalTime!).getDateFromUTC()
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Private Methods
    
    private func loadArrivals() {
        
        print("arrival начал загрузку")
        
        service.getArrivalFlights(parameters: (icao: airportCode, begin: beginUnix, end: endUnix)) { [weak self] (flights, error) in
            
            self?.flights = flights.sorted(by: {$0.arrivalTime! < $1.arrivalTime!})
            self?.createFlightsDict()
        }
    }
    
    private func convert(unix timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: Double(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        
        return formatter.string(from: date)
    }
    
    private func createSectionTitles() {
        let unixDay = 86400
        var currentUnixDay = beginUnix
        
        while currentUnixDay <= endUnix {
            flightsSectionTitles.append(convert(unix: currentUnixDay))
            
            currentUnixDay += unixDay
        }
    }
    
    private func createFlightsDict() {
        // Get the date and create dictionary
        for flight in flights {
            
            let flightKey = convert(unix: flight.arrivalTime ?? 0 )
            
            if var _ = flightsDict[flightKey] {
                flightsDict[flightKey]?.append(flight)
            } else {
                flightsDict[flightKey] = [flight]
            }
        }
        
        createSectionTitles()
        tableView.reloadData()
    }
}
