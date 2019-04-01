//
//  ScheduleViewController.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 4/1/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import UIKit

class ScheduleViewController: UITabBarController {
    
    // MARK: Properties
    var airportCode = String() {
        didSet {
            print("Tab bar получил код = \(airportCode)")
            passCode()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        
        guard let departureViewController = segue.destination as? FlightTableViewController else {
            print("I dont know that VC!")
            return
        }
        
        
        // Pass the selected object to the new view controller.
        departureViewController.airportCode = self.airportCode
        
    }
    
    */
    
    // MARK: Private Methods
    
    private func passCode() {
        guard let firstNavController = self.viewControllers?[0] as? UINavigationController else {
            fatalError("Unexpected navController: \(self.description)")
        }
        
        guard let secondNavController = self.viewControllers?[1] as? UINavigationController else {
            fatalError("Unexpected navController: \(self.description)")
        }
        
        
        guard let departureViewController = firstNavController.topViewController as? DepartureTableViewController else {
            print("cant find controller departure")
            return
        }
        
        guard let arrivalViewController = secondNavController.topViewController as?ArrivalTableViewController else {
            print("cant find controller arrival")
            return
        }
        
        // sending the airport code
        departureViewController.airportCode = self.airportCode
        arrivalViewController.airportCode = self.airportCode
    }
}
