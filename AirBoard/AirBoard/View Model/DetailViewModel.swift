//
//  DetailViewModel.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 4/25/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import Foundation

protocol DetailViewModelDelegate: AnyObject {
    func reciveData()
}

class DetailViewModel {
    
    // MARK: Properties
    
    weak var delegate: DetailViewModelDelegate?
    
    private let aircraftService = AircraftService()
    private let coreDataManager: CoreDataManager
    
    private var flight: Flight? {
        didSet {
            setDefaultValues()
        }
    }
    var data = DetailInfo() {
        didSet {
            delegate?.reciveData()
        }
    }
    
    init(appDelegate: AppDelegate) {
        coreDataManager = CoreDataManager(appDelegate: appDelegate)
    }
    
    func loadDetailInfo(for flight: Flight) {
        self.flight = flight
        
        loadAircraft()
        loadAircraftImage()
        getFlightTime()
        getCityNames()
    }
    
    // MARK: Private methods
    
    private func loadAircraft() {
        guard let flight = self.flight else {
            NSLog("Flight is nil!")
            return
        }
        
        aircraftService.loadAircraft(icao: flight.icao) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let aircraft):
                self.data.registrationNumber = aircraft.registration.isEmpty ? "N/A" : aircraft.registration
                self.data.model = aircraft.model.isEmpty ? "N/A" : aircraft.model
                self.data.icaoAirplane = aircraft.icaoAirplane.isEmpty ? "N/A" : aircraft.icaoAirplane
                
                if !aircraft.enginesType.isEmpty && !aircraft.enginesCount.isEmpty {
                    self.data.engine = aircraft.enginesType + " x " + aircraft.enginesCount
                } else {
                    self.data.engine = "N/A"
                }
                
                self.data.age = aircraft.age.isEmpty ? "N/A" : aircraft.age
                self.data.owner = aircraft.planeOwner.isEmpty ? "N/A" : aircraft.planeOwner
            case .failure(let error):
                NSLog(error.description)
            }
        }
    }
    
    private func loadAircraftImage() {
        aircraftService.loadImage(with: flight!.icao) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let imageData):
                self.data.imageData = imageData
            case .failure(let error):
                NSLog(error.description)
            }
        }
    }
    
    private func getFlightTime() {
        if let departureTime = flight!.departureTime, let arrivalTime = flight!.arrivalTime {
            data.departureTime = Double(departureTime).getDateFromUTC()
            data.arrivalTime = Double(arrivalTime).getDateFromUTC()
            
            let difference = arrivalTime - departureTime
            let hours = difference / (60 * 60)
            let minutes = difference % (60 * 60) / 60
            
            data.durationTime = String(format: "%02d", hours) + ":" + String(format: "%02d", minutes)
        }
    }
    
    private func getCityNames() {
        coreDataManager.fetchCityNameFromDB(with: flight!.departure) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let city):
                self.data.departureCity = city
            case .failure(let error):
                NSLog(error.description)
            }
        }
        
        coreDataManager.fetchCityNameFromDB(with: flight!.arrival) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let city):
                self.data.arrivalCity = city
            case .failure(let error):
                NSLog(error.description)
            }
        }
    }
    
    private func setDefaultValues() {
        data.departureCity = "N/A"
        data.arrivalCity = "N/A"
        data.registrationNumber = "N/A"
        data.model = "N/A"
        data.icaoAirplane = "N/A"
        data.engine = "N/A"
        data.age = "N/A"
        data.owner = "N/A"
        data.departureTime = "N/A"
        data.durationTime = "N/A"
        data.arrivalTime = "N/A"
        data.departureIcao = flight?.departure ?? "N/A"
        data.arrivalIcao = flight?.arrival ?? "N/A"
    }
}
