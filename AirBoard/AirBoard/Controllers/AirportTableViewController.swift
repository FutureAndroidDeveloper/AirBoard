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
    private var listIndexBoxCounter = 0
    var boxTop : NSLayoutConstraint?
    var boxTrailing : NSLayoutConstraint?
    
    
    private let viewModel = AirportViewModel(appDelegate: UIApplication.shared.delegate as! AppDelegate)
    private let dataSource = AirportDataDisplayManager()
    private let activityIndicatorView = UIActivityIndicatorView(style: .gray)
    private let searchController = UISearchController(searchResultsController: nil)
    private var listIndexHelpBox = ListIndexBacklightView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        dataSource.delegate = self
        tableView.dataSource = dataSource
        tableView.backgroundView = activityIndicatorView
        setUpSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 110
        
        activityIndicatorView.startAnimating()
        tableView.separatorStyle = .none
        drawListIndexBox()
        viewModel.getData()
    }
    
    override func viewLayoutMarginsDidChange() {
        boxTop?.constant = self.view.frame.height / 6
        boxTrailing?.constant = -(self.view.frame.width / 5)
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let tabBarController = segue.destination as? ScheduleTabBarController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        guard let selectedAirportCell = sender as? AirportTableViewCell else {
            fatalError("Unexpected sender: \(String(describing: sender))")
        }
        
        //getting the airport code
        if let code = selectedAirportCell.icaoLabel.text?.split(separator: " ").last {
            tabBarController.airportCode = String(code)
        }
    }
    
    // MARK: Private Methods
    
    private func updateHelpBox(with label: String, index: Int) {
        listIndexHelpBox.letterLabel.text = label
        listIndexHelpBox.isHidden = false
        tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: true)
        listIndexBoxCounter += 1
        hideIndexListBoxAfter()
    }
    
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
    
    private func drawListIndexBox() {
        guard let view = self.navigationController?.view else {
            fatalError("Cant get navigation controller as view")
        }
        
        listIndexHelpBox.isHidden = true
        view.addSubview(listIndexHelpBox)
        listIndexHelpBox.translatesAutoresizingMaskIntoConstraints = false
        
        boxTop = listIndexHelpBox.topAnchor.constraint(equalTo: view.topAnchor, constant: self.view.frame.height / 6)
        boxTop?.isActive = true
        boxTrailing = listIndexHelpBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(self.view.frame.width / 5))
        boxTrailing?.isActive = true
        
        listIndexHelpBox.widthAnchor.constraint(equalToConstant: self.view.frame.width / 10).isActive = true
        listIndexHelpBox.heightAnchor.constraint(equalToConstant: self.view.frame.width / 10).isActive = true
        
        listIndexHelpBox.letterLabel.font = UIFont.systemFont(ofSize: self.view.frame.width / 11)
    }
}

extension AirportTableViewController: AirportsViewModelDelegate {
    func reciveData() {
        dataSource.data = viewModel.data
        tableView.reloadData()
        stopIndicator()
    }
}

extension AirportTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchAirports(cityName: searchController.searchBar.text!)
    }
}

extension AirportTableViewController: AirportDataSourceDelegate {
    func reciveHelpBox(label: String, index: Int) {
        updateHelpBox(with: label, index: index)
    }
}
