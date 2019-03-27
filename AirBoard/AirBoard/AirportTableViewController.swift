//
//  AirportTableViewController.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 3/27/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import UIKit

class AirportTableViewController: UITableViewController {
    
    
    // MARK: Properties
    
    private let service = FlightService()
    var airports = [Airport]()
    
    var airportDict = [String: [Airport]]()
    var airportSectionTitles = [String]()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadAirports()
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return airportSectionTitles.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return airportSectionTitles[section]
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let airportKey = airportSectionTitles[section]
        guard let airportValues = airportDict[airportKey] else { return 0 }
        
        return airportValues.count
    }
    
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return airportSectionTitles
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "AirportCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AirportTableViewCell else {
            fatalError("cell error")
        }

        let airportKey = airportSectionTitles[indexPath.section]
        
        if let airportValues = airportDict[airportKey] {
            cell.airportNameLabel.text = airportValues[indexPath.row].name
            cell.cityLabel.text = "\(airportValues[indexPath.row].city ?? "Undefined")"
            cell.codeLabel.text = airportValues[indexPath.row].code
        }

        return cell
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: Private Methods
    
    private func loadAirports() {
        service.getAirports { [weak self] (airports, error) in
            self?.airports = airports
            self?.createAirportsDict()
        }
    }

    private func createAirportsDict() {
        
        for airport in airports {
            
            // Get the first letter of airport name and build the dictionary
            let firstLetterIndex = airport.name.index(airport.name.startIndex, offsetBy: 1)
            let airportKey = String(airport.name[..<firstLetterIndex])
            
            if var airportValues = airportDict[airportKey] {
                airportValues.append(airport)
                airportDict[airportKey] = airportValues
            } else {
                airportDict[airportKey] = [airport]
            }
        }
        
        // Get the section titlesfrom the dictionary's keys and sort them in ascending order
        airportSectionTitles = [String](airportDict.keys)
        airportSectionTitles = airportSectionTitles.sorted(by: { $0 < $1 })
        
        tableView.reloadData()
    }
}
