//
//  MapViewController.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 4/17/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var plusZoomButton: UIButton!
    @IBOutlet weak var minusZoomButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    
    var flight: Flight!
    var detailInfo: DetailInfo!
    let mapService = MapService()
    let dateService = DateService()
    var airplaneMarker = GMSMarker()
    
    var path = [Path]() {
        didSet {
            buildDirection()
            setMarkers()
            focusCamera()
            setUpSlider()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        plusZoomButton.layer.cornerRadius = plusZoomButton.bounds.width / 2
        minusZoomButton.layer.cornerRadius = minusZoomButton.bounds.width / 2
        
        mapView.bringSubviewToFront(plusZoomButton)
        mapView.bringSubviewToFront(minusZoomButton)
        mapView.bringSubviewToFront(slider)
        
        loadAircraftDirection()
    }
    
    // MARK: Private Methods
    
    private func replaceAirplaneMarker(pathIndex: Int) {
        let airplanePoint = path[pathIndex]
        
        guard let latitude = airplanePoint.latitude, let longitude = airplanePoint.longitude else {
            return
        }
        
        let date = dateService.convert(unix: airplanePoint.time)
        let time = Double(airplanePoint.time).getDateFromUTC()
        airplaneMarker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        airplaneMarker.snippet = "Date: \(date)\nTime: \(time)\nLatitude: \(latitude)\nLongitude: \(longitude)"
        
        airplaneMarker.map = mapView
    }
    
    private func setUpSlider() {
        slider.maximumValue = Float(path.count - 1)
        slider.minimumValueImage = #imageLiteral(resourceName: "departure")
        slider.maximumValueImage = #imageLiteral(resourceName: "arrival")
    }
    
    private func loadAircraftDirection() {
        mapService.loadDirection(for: flight) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let path):
                self.path = path
            case .failure(let error):
                NSLog(error.description)
            }
        }
    }
    
    private func buildDirection() {
        let googlePath = GMSMutablePath()
        
        for point in path {
            if let latitude = point.latitude, let longitude = point.longitude {
                googlePath.add(CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude)))
            }
        }
        
        let polyline = GMSPolyline(path: googlePath)
        polyline.geodesic = true
        polyline.strokeColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        polyline.strokeWidth = 4
        polyline.map = self.mapView
    }
    
    private func createMarker(point: Path, icon: UIImage?, title: String?, snippet: String?) -> GMSMarker {
        guard let latitude = point.latitude, let longitude = point.longitude else {
            fatalError("Couldn't set marker without any coordinates")
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        
        let marker = GMSMarker(position: coordinate)
        marker.icon = icon
        marker.title = title
        marker.snippet = snippet
        marker.appearAnimation = GMSMarkerAnimation.pop
        
        return marker
    }
    
    private func setMarkers() {
        guard let firstPoint = path.first, let lastPoint = path.last else {
            return
        }
        
        createMarker(point: firstPoint, icon: nil, title: detailInfo.departureCity!, snippet: "Icao code: \(detailInfo.departureIcao!)\nDeparture: \(detailInfo.departureTime!)").map = mapView
        createMarker(point: lastPoint, icon: nil, title: detailInfo.arrivalCity!, snippet: "Icao code: \(detailInfo.arrivalIcao!)\nArrival: \(detailInfo.arrivalTime!)").map = mapView
        
        let date = dateService.convert(unix: firstPoint.time)
        let time = Double(firstPoint.time).getDateFromUTC()
        airplaneMarker = createMarker(point: firstPoint, icon: #imageLiteral(resourceName: "airplanePosition"), title: flight.icao, snippet: "Date: \(date)\nTime: \(time)\nLatitude: X\nLongitude: Y")
        airplaneMarker.map = mapView
    }
    
    private func focusCamera() {
        guard let latitude = path.first?.latitude, let longitude = path.first?.longitude else {
            return
        }
        
        let camera = GMSCameraPosition(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude), zoom: 6.0)
        self.mapView.camera = camera
    }
    
    @IBAction func plusTapped(_ sender: UIButton) {
        mapView.animate(toZoom: mapView.camera.zoom + 1.0)
    }
    
    @IBAction func minusTapped(_ sender: UIButton) {
        mapView.animate(toZoom: mapView.camera.zoom - 1.0)
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentValue = Int(slider.value)
        replaceAirplaneMarker(pathIndex: currentValue)
    }
}
