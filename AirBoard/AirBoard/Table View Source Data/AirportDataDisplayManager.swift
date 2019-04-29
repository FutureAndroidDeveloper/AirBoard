//
//  AirportDataDisplayManager.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 4/29/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import UIKit

protocol AirportDataSourceDelegate: class {
    func reciveHelpBox(label: String, index: Int)
}

class AirportDataDisplayManager: NSObject, UITableViewDataSource {
    
    // MARK: Properties
    weak var delegate: AirportDataSourceDelegate?
    
    var data = [String: [Airport]]()
    private var sectionTitles: [String] {
        get {
            return data.keys.sorted()
        }
    }

    // MARK: Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let airportKey = sectionTitles[section]
        guard let airportValues = data[airportKey] else { return 0 }
        
        return airportValues.count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if sectionTitles.count == 1 {
            return nil
        }
        
        return sectionTitles
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AirportCell", for: indexPath) as! AirportTableViewCell
        
        let airportKey = sectionTitles[indexPath.section]
        
        if let airportValues = data[airportKey] {
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
