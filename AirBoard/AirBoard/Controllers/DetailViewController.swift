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
    @IBOutlet weak var departureTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    @IBOutlet weak var registrationNumberLabel: UILabel!
    @IBOutlet weak var modelCodeLabel: UILabel!
    @IBOutlet weak var airplaneIcaoLabel: UILabel!
    @IBOutlet weak var engineLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    
    private var activityIndicatorView = UIActivityIndicatorView(style: .gray)
    private let viewModel = DetailViewModel(appDelegate: UIApplication.shared.delegate as! AppDelegate)
    
    var flight: Flight!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpIndicator()
        aircraftPhoto.layer.cornerRadius = self.view.frame.height / 10.0
        aircraftPhoto.layer.masksToBounds = true
        activityIndicatorView.startAnimating()
        viewModel.loadDetailInfo(for: flight)
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let mapViewController = segue.destination as? MapViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        mapViewController.flight = self.flight
    }
    
    // MARK: Private Methods
    
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

extension DetailViewController: DetailViewModelDelegate {
    func reciveData() {
        if let imageData = viewModel.data.imageData {
            aircraftPhoto.image = UIImage(data: imageData)
            activityIndicatorView.stopAnimating()
        }
        
        departureIcaoLabel.text = viewModel.data.departureIcao
        arrivalIcaoLabel.text = viewModel.data.arrivalIcao
        departureCityLabel.text = viewModel.data.departureCity
        arrivalCityLabel.text = viewModel.data.arrivalCity
        
        registrationNumberLabel.text = viewModel.data.registrationNumber
        modelCodeLabel.text = viewModel.data.model
        airplaneIcaoLabel.text = viewModel.data.icaoAirplane
        engineLabel.text = viewModel.data.engine
        ageLabel.text = viewModel.data.age
        ownerLabel.text = viewModel.data.owner
        
        departureTimeLabel.text = viewModel.data.departureTime
        durationLabel.text = viewModel.data.durationTime
        arrivalTimeLabel.text = viewModel.data.arrivalTime

    }
}
