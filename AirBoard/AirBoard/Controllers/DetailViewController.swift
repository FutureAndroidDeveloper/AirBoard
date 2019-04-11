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
    
    private var activityIndicatorView = UIActivityIndicatorView(style: .gray)
    private let aircraftService = AircraftService()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadAircraft()
        
        aircraftPhoto.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: aircraftPhoto.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: aircraftPhoto.centerYAnchor).isActive = true
//        activityIndicatorView.center = aircraftPhoto.center
        
    }
    
    // MARK: Private Methods
    
    private func loadAircraft() {
        activityIndicatorView.startAnimating()
        
        aircraftService.loadImage(success: { [weak self] imageData in
            self?.aircraftPhoto.image = UIImage(data: imageData)
            self?.activityIndicatorView.stopAnimating()
            }, failure: { error in
                NSLog(error.description)
        })
    }
}
