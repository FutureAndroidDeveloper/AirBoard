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
    
//    private var zoom
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 15
        plusZoomButton.layer.cornerRadius = 15
        minusZoomButton.layer.cornerRadius = 15

        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition(latitude: -33.86, longitude: 151.20, zoom: 6.0)
        mapView.camera = camera
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        
        mapView.bringSubviewToFront(plusZoomButton)
        mapView.bringSubviewToFront(minusZoomButton)
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker(position: camera.target)
        marker.isDraggable = true
        marker.title = "PASHA"
        marker.snippet = "Postavi"
        marker.map = mapView
    }
    
    @IBAction func plusTapped(_ sender: UIButton) {
        mapView.animate(toZoom: mapView.camera.zoom + 1.0)
    }
    
    @IBAction func minusTapped(_ sender: UIButton) {
        mapView.animate(toZoom: mapView.camera.zoom - 1.0)
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


