//
//  AirportDataDisplayManager.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 4/29/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import UIKit

protocol AirportDataSourceDelegate: AnyObject {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: AirportTableViewCell.reuseIdentifier, for: indexPath) as! AirportTableViewCell
        
        let airportKey = sectionTitles[indexPath.section]
        
        if let airportValues = data[airportKey] {
            cell.airportLabel.attributedText = createMultipleFontText(header: "Airport", text: airportValues[indexPath.row].name)
            cell.cityLabel.attributedText = createMultipleFontText(header: "City", text: airportValues[indexPath.row].city ?? "Undefined")
            cell.icaoLabel.attributedText = createMultipleFontText(header: "ICAO", text: airportValues[indexPath.row].code)
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        delegate?.reciveHelpBox(label: title, index: index)
        return -1
    }
    
    // Private Methods
    
    private func createMultipleFontText(header: String, text: String) -> NSMutableAttributedString {
        let headerFont = UIFont.systemFont(ofSize: 17)
        let textFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        let labelText = "\(header): \(text)"
        
        let attributedText = NSMutableAttributedString(string: labelText, attributes: [.font: headerFont])
        attributedText.addAttributes([.font: textFont, .foregroundColor: UIColor.gray], range: NSRange(location: header.count + 1, length: text.count + 1))
        
        return attributedText
    }
}
