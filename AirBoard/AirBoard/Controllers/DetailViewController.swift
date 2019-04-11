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
    @IBOutlet weak var numberRegistrationLabel: UILabel!
    @IBOutlet weak var modelCodeLabel: UILabel!
    @IBOutlet weak var airplaceIcaoLabel: UILabel!
    @IBOutlet weak var engineLabel: UILabel!
    @IBOutlet weak var planeAgeLabel: UILabel!
    @IBOutlet weak var firstFlightLabel: UILabel!
    
    var activityIndicatorView: UIActivityIndicatorView!
    
    private let aircraftService = AircraftService()
    
    override func loadView() {
        super.loadView()
        
        activityIndicatorView = UIActivityIndicatorView(style: .gray)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
            activityIndicatorView.startAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadAircraft()
        
        aircraftPhoto.addSubview(activityIndicatorView)
        activityIndicatorView.center = aircraftPhoto.center
    }
    
    // MARK: Private Methods
    
    private func loadAircraft() {
        aircraftService.loadImage { [weak self] (imageData) in
            
            if let imageData = imageData {
                self?.aircraftPhoto.image = UIImage(data: imageData)
            }
        }
    }
}
