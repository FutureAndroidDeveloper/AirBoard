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
    private let noDataImageView = UIImageView()
    private let viewModel = FlightViewModel(appDeleagte: UIApplication.shared.delegate as! AppDelegate)
    private var dataSource: FlightDataDisplayManager!
    
    var flightType = FlightType.departure
    var airportCode = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        dataSource = FlightDataDisplayManager(flightType: flightType)
        dataSource.delegate = self
        tableView.dataSource = dataSource
        tableView.backgroundView = activityIndicatorView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicatorView.startAnimating()
        tableView.separatorStyle = .none
        viewModel.getFlights(flightType: flightType, airportCode: airportCode)
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
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
    }
    
    // MARK: Private Methods
    
    private func stopIndicator () {
        self.activityIndicatorView.stopAnimating()
        
        if viewModel.data.values.flatMap({ $0 }).isEmpty {
            tableView.backgroundView = noDataImageView
        } else {
            self.tableView.separatorStyle = .singleLine
        }
    }
    
    private func setBackgroundImage() {
        noDataImageView.image = #imageLiteral(resourceName: "noInfo")
        noDataImageView.contentMode = .scaleAspectFit
        noDataImageView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height)
        tableView.separatorStyle = .none
    }
}

extension FlightTableViewController: FlightsViewModelDelegate {
    func reciveData() {
        dataSource.data = viewModel.data
        dataSource.flightsSectionTitles = viewModel.flightsSectionTitles
        tableView.reloadData()
        stopIndicator()
    }
}

extension FlightTableViewController: FlightDataSourceDelegate {
    func reciveEmptyData() {
        setBackgroundImage()
    }
}
