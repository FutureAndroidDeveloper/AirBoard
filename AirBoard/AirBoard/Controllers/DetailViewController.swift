//
//  DetailViewController.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 4/8/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var aircraftPhoto: UIImageView!
    @IBOutlet weak var departureIcaoLabel: UILabel!
    @IBOutlet weak var arrivalIcaoLabel: UILabel!
    @IBOutlet weak var departureCityLabel: UILabel!
    @IBOutlet weak var arrivalCityLabel: UILabel!
    @IBOutlet weak var registrationNumberLabel: UILabel!
    @IBOutlet weak var modelCodeLabel: UILabel!
    @IBOutlet weak var airplaneIcaoLabel: UILabel!
    @IBOutlet weak var engineLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    
    
    private var activityIndicatorView = UIActivityIndicatorView(style: .gray)
    private var aircraftService = AircraftService()
    private let coreDataManager = CoreDataManager(appDelegate: UIApplication.shared.delegate as! AppDelegate)

    var flight: Flight!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpIndicator()
        setDefaultInfo()
        loadAircraft()
        getCityNames()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is MapViewController
        {
            let detailViewController = segue.destination as? MapViewController
            detailViewController?.flight = self.flight
        }
    }
    
    // MARK: Private Methods
    
    private func loadAircraft() {
        aircraftService.loadAircraft(icao: flight.icao, success: { [weak self] aircraft in
            
            self?.registrationNumberLabel.text = aircraft.registration
            self?.modelCodeLabel.text = aircraft.model
            self?.airplaneIcaoLabel.text = aircraft.icaoAirplane
            self?.engineLabel.text = aircraft.enginesType + " x " + aircraft.enginesCount
            self?.ageLabel.text = aircraft.age.isEmpty ? "N/A" : aircraft.age
            self?.ownerLabel.text = aircraft.planeOwner.isEmpty ? "N/A" : aircraft.planeOwner
        }, failure: { error in
            NSLog(error.description)
        })
        
        loadAircraftImage()
    }
    
    private func loadAircraftImage() {
        activityIndicatorView.startAnimating()
        
        aircraftService.loadImage(with: flight.icao, success: { [weak self] imageData in
            self?.aircraftPhoto.image = UIImage(data: imageData)
            self?.activityIndicatorView.stopAnimating()
            }, failure: { error in
                NSLog(error.description)
        })
    }
    
    private func getCityNames() {
        coreDataManager.fetchCityNameFromDB(with: flight.departure, success: { [weak self] city in
            self?.departureCityLabel.text = city
            }, failure: { error in
                NSLog(error.description)
        })
        
        coreDataManager.fetchCityNameFromDB(with: flight.arrival, success: { [weak self] city in
            self?.arrivalCityLabel.text = city
            }, failure: { error in
                NSLog(error.description)
        })
    }
    
    private func setDefaultInfo() {
        departureIcaoLabel.text = "N/A"
        arrivalIcaoLabel.text = "N/A"
        departureCityLabel.text = "N/A"
        arrivalCityLabel.text = "N/A"
        registrationNumberLabel.text = "N/A"
        modelCodeLabel.text = "N/A"
        airplaneIcaoLabel.text = "N/A"
        engineLabel.text = "N/A"
        ageLabel.text = "N/A"
        ownerLabel.text = "N/A"
        departureIcaoLabel.text = flight.departure
        arrivalIcaoLabel.text = flight.arrival
    }
    
    private func setUpIndicator() {
        aircraftPhoto.addSubview(activityIndicatorView)
        
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = activityIndicatorView.centerXAnchor.constraint(equalTo: aircraftPhoto.centerXAnchor)
        let verticalConstraint = activityIndicatorView.centerYAnchor.constraint(equalTo: aircraftPhoto.centerYAnchor)
        let widthConstraint = activityIndicatorView.widthAnchor.constraint(equalToConstant: 40)
        let heightConstraint = activityIndicatorView.heightAnchor.constraint(equalToConstant: 40)
        view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }
}
