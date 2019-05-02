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
    
    var flight: Flight!
    var detailInfo: DetailInfo!
    let mapService = MapService()
    let dateService = DateService()
    var path = [Path]() {
        didSet {
            buildDirection()
            setMarkers()
            focusCamera()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 15
        plusZoomButton.layer.cornerRadius = plusZoomButton.bounds.width / 2
        minusZoomButton.layer.cornerRadius = minusZoomButton.bounds.width / 2
        
        mapView.bringSubviewToFront(plusZoomButton)
        mapView.bringSubviewToFront(minusZoomButton)
        
        loadAircraftDirection()
    }
    
    @IBAction func plusTapped(_ sender: UIButton) {
        mapView.animate(toZoom: mapView.camera.zoom + 1.0)
    }
    
    @IBAction func minusTapped(_ sender: UIButton) {
        mapView.animate(toZoom: mapView.camera.zoom - 1.0)
    }
    
    private func loadAircraftDirection() {
        mapService.loadDirection(for: flight, success: { [weak self] path in
            guard let self = self else {
                return
            }
            self.path = path
            
        }, failure: { error in
            NSLog(error.description)
        })
    }
    
    private func buildDirection() {                                 // ---------------
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
    
    private func createMarker(point: Path, icon: UIImage?, title: String?, snippet: String?) {  // -------------
        guard let latitude = point.latitude, let longitude = point.longitude else {
            return
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        
        let marker = GMSMarker(position: coordinate)
        marker.icon = icon
        marker.title = title
        marker.snippet = snippet
        marker.appearAnimation = GMSMarkerAnimation.pop
        
        marker.map = mapView
    }
    
    private func setMarkers() {                                                             // если прокидывать делегатом или колбэком
        guard let firstPoint = path.first, let lastPoint = path.last else {
            return
        }
        
        createMarker(point: firstPoint, icon: nil, title: detailInfo.departureCity!, snippet: "Icao code: \(detailInfo.departureIcao!)\nDeparture: \(detailInfo.departureTime!)")
        createMarker(point: lastPoint, icon: nil, title: detailInfo.arrivalCity!, snippet: "Icao code: \(detailInfo.arrivalIcao!)\nArrival: \(detailInfo.arrivalTime!)")
        
        let date = dateService.convert(unix: firstPoint.time)
        let time = Double(firstPoint.time).getDateFromUTC()
        createMarker(point: firstPoint, icon: #imageLiteral(resourceName: "airplanePosition"), title: flight.icao, snippet: "Date: \(date)\nTime: \(time)\nLatitude: X\nLongitude: Y")
    }
    
    private func focusCamera() {                                                                        // --------
        guard let latitude = path.first?.latitude, let longitude = path.first?.longitude else {
            return
        }
        
        let camera = GMSCameraPosition(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude), zoom: 6.0)
        self.mapView.camera = camera
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        print("didBeginDragging")
    }
    
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        print("didDrag")
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        print("didEndDragging")
    }
}


