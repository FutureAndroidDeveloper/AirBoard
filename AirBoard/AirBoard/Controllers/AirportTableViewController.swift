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
    private var airports = [Airport]()
    private let coreDataManager = CoreDataManager(appDelegate: UIApplication.shared.delegate as! AppDelegate)
    
    private var aiportCode = ""

    
    // Sections and index list
    private var airportDict = [String: [Airport]]()
    private var airportSectionTitles = [String]()
    private let indexList = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#"]
    
    // Search
    private var filteredAirports = [Airport]()
    private let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 100
        
        airports = coreDataManager.loadDataFromDB()
        createAirportsDict()
        
        if airports.isEmpty {
            loadAirports()
            tableView.reloadData()
        } else {
            tableView.reloadData()
        }

        filteredAirports = airports
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.reloadData()
        
//        test()
    }
//
//    func test() {
//        guard let view = self.navigationController?.view else {
//            fatalError("cant get nav controller as view")
//        }
//
//        let myCustomView = ListIndexBacklightView(frame: CGRect(x: 100, y: 100, width: 50, height: 50))
//
//
//        view.addSubview(myCustomView)
//    }

    
    func updateSearchResults(for searchController: UISearchController) {
        
        // If search bar is empty then do not filter the results
        if searchController.searchBar.text!.isEmpty {
            filteredAirports = airports
        } else {
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
        return indexList
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
            cell.accessoryType = .disclosureIndicator
            
            return cell
        }

        let airportKey = airportSectionTitles[indexPath.section]
        
        if let airportValues = airportDict[airportKey] {
            cell.airportNameLabel.text = airportValues[indexPath.row].name
            cell.cityLabel.text = "\(airportValues[indexPath.row].city ?? "Undefined")"
            cell.codeLabel.text = airportValues[indexPath.row].code
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        case "ShowFlights":
            
            guard let tabBarController = segue.destination as? ScheduleViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedAirportCell = sender as? AirportTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            //getting the airport code
            if let code = selectedAirportCell.codeLabel.text {
                tabBarController.airportCode = code
            }
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    
    // MARK: Private Methods
    
    private func loadAirports() {
        service.getAirports { [weak self] (airports, error) in
            self?.airports = airports.sorted(by: { $0.name < $1.name })
            self?.createAirportsDict()
            self?.coreDataManager.saveAirports(airports: self!.airports)
        }
    }

    private func createAirportsDict() {
        if airports.isEmpty {
            return
        }
        
        // Get the first letter in airport name and create dictionary
        for airport in airports {

            guard let firstChar = airport.name.first else {
                fatalError("cant get first char - \(airport.name)")
            }
            
            let airportKey = String(firstChar)
            
            if var _ = airportDict[airportKey] {
                airportDict[airportKey]?.append(airport)
            } else {
                airportDict[airportKey] = [airport]
            }
        }
        
        // Get the section titles from the dictionary's keys and sort them in ascending order
        airportSectionTitles = [String](airportDict.keys)
        airportSectionTitles = airportSectionTitles.sorted(by: { $0 < $1 })
        
        tableView.reloadData()
    }
}
