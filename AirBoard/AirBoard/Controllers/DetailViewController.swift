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
        activityIndicatorView.centerXAnchor.constraint(equalTo: aircraftPhoto.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: aircraftPhoto.centerYAnchor).isActive = true
//        activityIndicatorView.center = aircraftPhoto.center
        
        
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
