//
//  FlightTableViewController.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 3/25/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import UIKit

extension Double {
    func getDateFromUTC() -> String {
        let date = Date(timeIntervalSince1970: self)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date)
    }
}

class DepartureTableViewController: UITableViewController {
    
    // MARK: Properties
    
    private let service = FlightService()
    var airportCode = String()
    var beginUnix = Int()
    var endUnix = Int()
    
    // Sections and index list
    private var flightsDict = [String: [Flight]]()
    private var flightsSectionTitles = [String]()
    private var indexList = [String]()
    
    var flights = [Flight]() {
        didSet {
            print("массив загружен")
            if !flights.isEmpty {
                print(flights[0])
            } else {
                print("Массив пуст")
            }
            tableView.reloadData()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 44
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
        guard let airportValues = flightsDict[flightKey] else { return 1 }
        
        return airportValues.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "DepartureCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DepartureTableViewCell else {
            fatalError("cell error")
        }
        
        let flightKey = flightsSectionTitles[indexPath.section]
        
        if let flightValues = flightsDict[flightKey] {
            cell.arrivalCityLabel.text = flightValues[indexPath.row].arrival ?? "Unkown"
            cell.departureTimeLabel.text = Double(flightValues[indexPath.row].departureTime!).getDateFromUTC()
            cell.accessoryType = .disclosureIndicator
        } else {
            let noInfoLabel = UILabel()
            noInfoLabel.text = "NO INFO"
            noInfoLabel.tag = indexPath.row
            
            let subViews = cell.contentView.subviews
            
            for subView in subViews {
                subView.isHidden = true
            }
            
            cell.contentView.addSubview(noInfoLabel)
            
            noInfoLabel.translatesAutoresizingMaskIntoConstraints = false
            let horizontalConstraint = noInfoLabel.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor)
            let verticalConstraint = noInfoLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            let widthConstraint = noInfoLabel.widthAnchor.constraint(equalToConstant: 90)
            let heightConstraint = noInfoLabel.heightAnchor.constraint(equalToConstant: 22)
            
            cell.contentView.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
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
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let currentCell = tableView.cellForRow(at: indexPath) as? DepartureTableViewCell else {
            fatalError("I AM BATMAN")
        }
        
        print(currentCell.departureTimeLabel.text!)
    }
    
    
    // MARK: Private Methods
    
    private func loadFlights() {
        
        print("departure начал загрузку")
        
        service.getDepartureFlights(parameters: (icao: airportCode, begin: beginUnix, end: endUnix)) { [weak self] (flights, error) in
            
            self?.flights = flights.sorted(by: {$0.departureTime! < $1.departureTime!})
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
            
            let flightKey = convert(unix: flight.departureTime ?? 0 )
            
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
