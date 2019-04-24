//
//  ScheduleViewController.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 4/1/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import UIKit

enum FlightType: CaseIterable {
    case departure
    case arrival
}

class ScheduleTabBarController: UITabBarController {
    
    // MARK: Properties
    var airportCode = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var controllers = [UIViewController]()
        
        FlightType.allCases.forEach { type in
            if let controller = prepareViewController(type) {
                controllers.append(controller)
            }
        }

        self.viewControllers = controllers
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = selectedViewController?.title
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // change navigation item title to the selected tab bar item title
        self.navigationItem.title = item.title
    }
    
    // MARK: Private Methods
    
    private func prepareViewController(_ flightType: FlightType) -> FlightTableViewController? {
        guard let controller = self.navigationController?.storyboard?.instantiateViewController(withIdentifier: "FlightTableViewController") as? FlightTableViewController else {
            return nil
        }
        
        // set title and tabBarItem
        switch flightType {
        case .departure:
            controller.title = "Departures"
            controller.tabBarItem = UITabBarItem(title: "Departures", image: #imageLiteral(resourceName: "departure"), tag: 0)
        case .arrival:
            controller.title = "Arrivals"
            controller.tabBarItem = UITabBarItem(title: "Arrivals", image: #imageLiteral(resourceName: "arrival"), tag: 1)
        }

        // sending the necessary information
        controller.airportCode = self.airportCode
        controller.flightType = flightType
        
        return controller
    }
}
