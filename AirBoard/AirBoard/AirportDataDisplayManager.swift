//
//  AirportDataDisplayManager.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 4/29/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import UIKit

class AirportDataDisplayManager: NSObject, UITableViewDataSource {
    
    // MARK: Properties
    
    private let viewModel: AirportViewModel
    weak var delegate: AirportDataSourceDelegate?
    
    init(viewModel: AirportViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let airportKey = viewModel.sectionTitles[section]
        guard let airportValues = viewModel.data[airportKey] else { return 0 }
        
        return airportValues.count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if viewModel.sectionTitles.count == 1 {
            return nil
        }
        
        return viewModel.sectionTitles
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AirportCell", for: indexPath) as! AirportTableViewCell
        
        let airportKey = viewModel.sectionTitles[indexPath.section]
        
        if let airportValues = viewModel.data[airportKey] {
            cell.airportNameLabel.text = airportValues[indexPath.row].name
            cell.cityLabel.text = "\(airportValues[indexPath.row].city ?? "Undefined")"
            cell.codeLabel.text = airportValues[indexPath.row].code
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        delegate?.reciveHelpBox(label: title, index: index)
        return -1
    }
}
