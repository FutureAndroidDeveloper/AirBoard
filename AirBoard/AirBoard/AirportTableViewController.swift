//
//  AirportTableViewController.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 3/27/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import UIKit

class AirportTableViewController: UITableViewController, UISearchResultsUpdating {
    
    
    // MARK: Properties
    
    private let service = FlightService()
    var airports = [Airport]()
    
    var airportDict = [String: [Airport]]()
    var airportSectionTitles = [String]()
    
    var filteredAirports = [Airport]()
    let searchController = UISearchController(searchResultsController: nil)
    
    let IndexList = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 100
        
        loadAirports()

        
        filteredAirports = airports
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

//        loadAirports()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        // If we haven't typed anything into the search bar then do not filter the results
        if searchController.searchBar.text! == "" {
            filteredAirports = airports
        } else {
            // Filter the results
            filteredAirports = airports.filter { $0.name.lowercased().contains(searchController.searchBar.text!.lowercased()) }
        }
        
        tableView.reloadData()
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive {
            return 1
        }
        
        return airportSectionTitles.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive {
            return "Found airports"
        }
        
        return airportSectionTitles[section]
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive {
            return self.filteredAirports.count
        }
        
        let airportKey = airportSectionTitles[section]
        guard let airportValues = airportDict[airportKey] else { return 0 }

        return airportValues.count
    }
    
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        return airportSectionTitles
        return IndexList
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "AirportCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AirportTableViewCell else {
            fatalError("cell error")
        }
        
        if searchController.isActive {
            cell.airportNameLabel.text = filteredAirports[indexPath.row].name
            cell.cityLabel.text = "\(filteredAirports[indexPath.row].city ?? "Undefined")"
            cell.codeLabel.text = filteredAirports[indexPath.row].code
            
            return cell
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
            self?.airports = airports.sorted(by: { $0.name < $1.name })
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
