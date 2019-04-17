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
    private var listIndexBoxCounter = 0
    private var activityIndicatorView = UIActivityIndicatorView(style: .gray)
    
    private let service = AirportService()
    private let coreDataManager = CoreDataManager(appDelegate: UIApplication.shared.delegate as! AppDelegate)
    
    private var aiportCode = String()
    private var airports = [Airport]() {
        didSet {
            createAirportsDict()
            tableView.reloadData()
        }
    }

    // Sections and index list
    private var airportDict = [String: [Airport]]()
    private var airportSectionTitles = [String]()
    
    // TODO: you can calculate index List by data that you received, it will be a best solution
    // FIXED
    private var indexList = [String]()
    
    // Search
    private var filteredAirports = [Airport]()
    private let searchController = UISearchController(searchResultsController: nil)

    private var myCustomView: ListIndexBacklightView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 126
        tableView.backgroundView = activityIndicatorView
        setUpSearchController()
        loadDataFromDB()
        
        drawListIndexBox()
    }
    
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
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        myCustomView.letterLabel.text = title
        
        myCustomView.isHidden = false
        tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: true)
        
        listIndexBoxCounter += 1
        hideIndexListBoxAfter()
        
        return -1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        case "ShowFlights":
            
            guard let tabBarController = segue.destination as? ScheduleTabBarController else {
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
        service.getAirports(success: { [weak self] airports in
            self?.airports = airports.sorted(by: { $0.name < $1.name })
            self?.coreDataManager.saveAirports(airports: self!.airports)
            self?.stopIndicator()
            }, failure: { error in
                NSLog(error.description)
        })
    }
    
    private func loadDataFromDB() {
        activityIndicatorView.startAnimating()
        tableView.separatorStyle = .none
        
        // TODO: you can create Enum with errors that you want to handle, and pass Enum to failure block.
        // FIXED
        coreDataManager.loadAirportsFromDB(success: { [weak self] data in
            self?.airports = data
            self?.stopIndicator()
            }, failure: { [weak self] error in
                NSLog(error.description)
                self?.loadAirports()
        })
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
        
        indexList = airportSectionTitles
        
        tableView.reloadData()
    }
    
    private func stopIndicator () {
        self.activityIndicatorView.stopAnimating()
        self.tableView.separatorStyle = .singleLine
    }
    
    private func setUpSearchController() {
        filteredAirports = airports
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    private func hideIndexListBoxAfter() {
        // Hide list index box after scrolling to section
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.listIndexBoxCounter -= 1
            
            //If several asynchronous calls are made for the block, then after the last asynchronous call, the block will be hidden.
            if self.listIndexBoxCounter == 0 {
                self.myCustomView.isHidden = true
            }
        }
    }
    
    private func drawListIndexBox() {
        guard let view = self.navigationController?.view else {
            fatalError("cant get nav controller as view")
        }
        
        myCustomView = ListIndexBacklightView(frame: CGRect(origin: CGPoint(x: self.view.frame.width - 70, y: 120), size: CGSize(width: 40, height: 40)))
        view.addSubview(myCustomView)
        myCustomView.isHidden = true
    }
}
