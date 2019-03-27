//
//  FlightTableViewController.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 3/25/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import UIKit

class FlightTableViewController: UITableViewController {
    
    // MARK: Properties
    
    private let service = FlightService()
    var flights = [Flight]()
    

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
        return self.flights.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "FlightCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FlightTableViewCell else {
            fatalError("cell error")
        }
        
        let fligth = flights[indexPath.row]
        
        cell.arrivalICAOLabel.text = fligth.arrival
        cell.departureICAOLabel.text = fligth.departure
        cell.arrivalTimeLabel.text = "\(fligth.arrivalTime ?? 0)"
        cell.departureTimeLabel.text = "\(fligth.departureTime ?? 0)"

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
    
    private func loadFlights() {
        
        service.getDepartureFlights(parameters: (icao: "EGLL", begin: 1553202020, end: 1553202600)) { [weak self] (flights, error) in
            
            self?.flights = flights
            self?.tableView.reloadData()
        }
    }
}
