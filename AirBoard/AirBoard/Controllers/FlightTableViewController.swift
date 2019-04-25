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
    private var activityIndicatorView = UIActivityIndicatorView(style: .gray)
    private let viewModel = FlightViewModel(appDeleagte: UIApplication.shared.delegate as! AppDelegate)
    
    var flightType = FlightType.departure
    var airportCode = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        tableView.backgroundView = activityIndicatorView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicatorView.startAnimating()
        tableView.separatorStyle = .none
        viewModel.getFlights(flightType: flightType, airportCode: airportCode)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.flightsSectionTitles.count //3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.flightsSectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let flightKey = viewModel.flightsSectionTitles[section]
        guard let flightValues = viewModel.data[flightKey] else { return 0 }
        
        return flightValues.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "FlightCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FlightTableViewCell else {
            fatalError("FlightCell cell error")
        }
        
        let flightKey = viewModel.flightsSectionTitles[indexPath.section]
        cell.accessoryType = .disclosureIndicator

        if let flightValues = viewModel.data[flightKey] {
            switch flightType {
            case .departure:
                cell.flightTimeLabel.text = Double(flightValues[indexPath.row].departureTime!).getDateFromUTC()
            case .arrival:
                cell.flightTimeLabel.text = Double(flightValues[indexPath.row].arrivalTime!).getDateFromUTC()
            }
            
            cell.flightCityLabel.text = flightValues[indexPath.row].city ?? "N/A"
        }
        
        return cell
    }
    
    // MARK: Navigation
    
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

            let flightKey = viewModel.flightsSectionTitles[indexPath.section]
            
            if let flightValues = viewModel.data[flightKey] {
                aircraftDetailViewController.flight = flightValues[indexPath.row]
            }
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    // MARK: Private Methods
    
    private func stopIndicator () {
        self.activityIndicatorView.stopAnimating()
        self.tableView.separatorStyle = .singleLine
    }
}

extension FlightTableViewController: FlightsViewModelDelegate {
    func reciveData() {
        tableView.reloadData()
        stopIndicator()
    }
}
