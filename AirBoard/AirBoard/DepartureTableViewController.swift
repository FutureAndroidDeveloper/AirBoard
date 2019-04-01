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
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter.string(from: date)
    }
}

class DepartureTableViewController: UITableViewController {
    
    // MARK: Properties
    
    private let service = FlightService()
    var airportCode = String() {
        didSet {
            print("Departure get code = \(airportCode)")
        }
    }
    var flights = [Flight]() {
        didSet {
            tableView.reloadData()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 100
        loadFlights()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flights.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "DepartureCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DepartureTableViewCell else {
            fatalError("cell error")
        }
        
        let fligth = flights[indexPath.row]
        
        cell.arrivalCityLabel.text = fligth.arrival ?? "Unkown"
        cell.departureTimeLabel.text = Double(fligth.departureTime!).getDateFromUTC() 

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
        
        service.getDepartureFlights(parameters: (icao: airportCode, begin: 1553990400, end: 1554076800)) { [weak self] (flights, error) in
            
            self?.flights = flights.sorted(by: {$0.departureTime! < $1.departureTime!})
        }
    }
}
