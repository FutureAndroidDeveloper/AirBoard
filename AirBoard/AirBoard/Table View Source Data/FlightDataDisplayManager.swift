//
//  FlightDataDisplayManager.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 4/29/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import UIKit

protocol FlightDataSourceDelegate: class {
    func reciveEmptyData()
}

class FlightDataDisplayManager: NSObject, UITableViewDataSource {
    
    // MARK: Properties
    private let flightType: FlightType
    private let viewModel: FlightViewModel
    weak var delegate: FlightDataSourceDelegate?
    
    init(viewModel: FlightViewModel, flightType: FlightType) {
        self.flightType = flightType
        self.viewModel = viewModel
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if viewModel.data.values.flatMap({ $0 }).isEmpty {
            delegate?.reciveEmptyData()
            return 0
        }
        
        return viewModel.flightsSectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.flightsSectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let flightKey = viewModel.flightsSectionTitles[section]
        guard let flightValues = viewModel.data[flightKey] else { return 0 }
        
        if flightValues.isEmpty {
            return 1
        }
        
        return flightValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FlightCell", for: indexPath) as! FlightTableViewCell
        
        let flightKey = viewModel.flightsSectionTitles[indexPath.section]
        guard let flightValues = viewModel.data[flightKey] else {
            NSLog("Cell error")
            fatalError()
        }
        
        if !flightValues.isEmpty  {
            switch flightType {
            case .departure:
                cell.flightTimeLabel.text = Double(flightValues[indexPath.row].departureTime!).getDateFromUTC()
            case .arrival:
                cell.flightTimeLabel.text = Double(flightValues[indexPath.row].arrivalTime!).getDateFromUTC()
            }
            
            cell.flightCityLabel.text = flightValues[indexPath.row].city ?? "N/A"
            cell.accessoryType = .disclosureIndicator
        } else {
            let label = createNoInfoLabel()
            cell.addSubview(label)
            
            label.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            label.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
            label.widthAnchor.constraint(equalToConstant: cell.bounds.width).isActive = true
            label.heightAnchor.constraint(equalToConstant: cell.bounds.height).isActive = true
            
            cell.isUserInteractionEnabled = false
            cell.flightTimeLabel.text = nil
            cell.flightCityLabel.text = nil
        }
        
        return cell
    }
    
    // MARK: Private Methods
    
    private func createNoInfoLabel() -> UILabel {
        let noInfoLabel = UILabel()
        
        switch flightType {
        case .departure:
            noInfoLabel.text = "For this date no departures"
        case .arrival:
            noInfoLabel.text = "For this date no arrivals"
        }
        
        noInfoLabel.textAlignment = .center
        noInfoLabel.font = UIFont(name: "System Italic", size: 20.0)
        noInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return noInfoLabel
    }
}
