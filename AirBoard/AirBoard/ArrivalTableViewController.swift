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
    var airportCode = String() {
        didSet {
            print("Arrival get code = \(airportCode)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loadArrivals()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flights.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "ArrivalCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ArrivalTableViewCell else {
            fatalError("arrival cell error")
        }
        
        let fligth = flights[indexPath.row]
        
        cell.departureCityLabel.text = fligth.departure ?? "Unkown"
        cell.arrivalTimeLabel.text = Double(fligth.arrivalTime!).getDateFromUTC()
        
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
        
        service.getArrivalFlights(parameters: (icao: airportCode, begin: 1553990400, end: 1554076500)) { [weak self] (flights, error) in
            
            self?.flights = flights.sorted(by: {$0.arrivalTime! < $1.arrivalTime!})
        }
    }

}
