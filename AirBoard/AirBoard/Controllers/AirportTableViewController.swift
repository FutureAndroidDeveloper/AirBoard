//
//  AirportTableViewController.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 3/27/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import UIKit

class AirportTableViewController: UITableViewController {
    
    //MARK: Properties
    private var listIndexBoxCounter = 0
    
    private let viewModel = AirportViewModel(appDelegate: UIApplication.shared.delegate as! AppDelegate)
    private var activityIndicatorView = UIActivityIndicatorView(style: .gray)
    private let searchController = UISearchController(searchResultsController: nil)
    private var listIndexHelpBox: ListIndexBacklightView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        tableView.backgroundView = activityIndicatorView
        setUpSearchController()
        drawListIndexBox()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.rowHeight = 126
        activityIndicatorView.startAnimating()
        tableView.separatorStyle = .none
        drawListIndexBox()
        viewModel.getData()
    }
    
    //MARK: Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionTitles.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let airportKey = viewModel.sectionTitles[section]
        guard let airportValues = viewModel.data[airportKey] else { return 0 }

        return airportValues.count
    }
        
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if viewModel.sectionTitles.count == 1 {
            return nil
        }
        
        return viewModel.sectionTitles
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        listIndexHelpBox.letterLabel.text = title
        listIndexHelpBox.isHidden = false
        tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: true)
        listIndexBoxCounter += 1
        hideIndexListBoxAfter()
        
        return -1
    }
    
    //MARK: Navigation
    
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
    
    
    //MARK: Private Methods
    
    private func stopIndicator () {
        self.activityIndicatorView.stopAnimating()
        self.tableView.separatorStyle = .singleLine
    }
    
    private func setUpSearchController() {
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
                self.listIndexHelpBox.isHidden = true
            }
        }
    }
    
    // TODO: Make flexible size and space
    private func drawListIndexBox() {
        guard let view = self.navigationController?.view else {
            fatalError("cant get nav controller as view")
        }
        
        listIndexHelpBox = ListIndexBacklightView(frame: CGRect(origin: CGPoint(x: self.view.frame.width - 70, y: 100), size: CGSize(width: 40, height: 40)))
        view.addSubview(listIndexHelpBox)
        listIndexHelpBox.isHidden = true
    }
}

extension AirportTableViewController: AirportsViewModelDelegate {
    func reciveData() {
        tableView.reloadData()
        stopIndicator()
    }
}

extension AirportTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchAirports(cityName: searchController.searchBar.text!)
    }
}
