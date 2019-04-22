//
//  MapViewController.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 4/17/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import UIKit
import GoogleMaps

struct Track: Codable {
    let startTime: Int
    let endTime: Int
    let path: [PathSky]
}

struct PathSky: Codable {
    let time: Int
    let latitude: Float?
    let longitude: Float?
    let baro: Float?
    let trueTrack: Float?
    let onGround: Bool
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.time = try container.decode(Int.self)
        self.latitude = try container.decode(Float.self)
        self.longitude = try container.decode(Float.self)
        self.baro = try container.decode(Float.self)
        self.trueTrack = try container.decode(Float.self)
        self.onGround = try container.decode(Bool.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(time)
        try container.encode(latitude)
        try container.encode(longitude)
        try container.encode(baro)
        try container.encode(trueTrack)
        try container.encode(onGround)
    }
}

extension Track {
    enum CodingKeys: String, CodingKey {
        case startTime
        case endTime
        case path
    }
}


class MapViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var plusZoomButton: UIButton!
    @IBOutlet weak var minusZoomButton: UIButton!
    @IBOutlet weak var directionButton: UIButton!
    
    var flight: Flight!
    
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
        mapView.bringSubviewToFront(directionButton)
        
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
    
    @IBAction func createDirection(_ sender: UIButton) {
//        getDirection()
//        drawLine()
        openSkyDirection()
        let camera = GMSCameraPosition(latitude: 50.1055522, longitude: 8.661708000000001, zoom: 6.0)
        mapView.camera = camera
    }
    
    
    func openSkyDirection() {
//        let url = URL(string: "https://dev.kirill.klimenkov:1029384756gexa@opensky-network.org/api/tracks/all?icao24=44001c&time=0")
        
        guard let time = flight.departureTime else {
            print("Invalid Time")
            return
        }
        
        let url = URL(string: "https://dev.kirill.klimenkov:1029384756gexa@opensky-network.org/api/tracks/all?icao24=\(flight.icao)&time=\(time)")
        
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) in
            
            guard let data = data else {
                print("NO DATA")
                return
            }
            
            guard let dict = try? JSONDecoder().decode(Track.self, from: data) else {
                fatalError("Track error")
            }
            
            let path = GMSMutablePath()
            let points = dict.path

            for point in points {
                if let latitude = point.latitude, let longitude = point.longitude {
                    path.add(CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude)))
                }
            }

            DispatchQueue.main.async {
                let polyline = GMSPolyline(path: path)
                polyline.geodesic = true
                polyline.strokeColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                polyline.strokeWidth = 4
                polyline.map = self.mapView
                
                let pointIndex = points.count / 3
                let point = points[pointIndex]
                if let latitude = point.latitude, let longitude = point.longitude {
                    let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
                    
                    let airplaneMarker = GMSMarker(position: coordinate)
                    airplaneMarker.icon = #imageLiteral(resourceName: "miniEmpty-2")
                    airplaneMarker.title = self.flight.icao
                    airplaneMarker.map = self.mapView
                }
                
                let startMarker = GMSMarker()
                startMarker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees((points.first?.latitude!)!), longitude: CLLocationDegrees((points.first?.longitude!)!))
                startMarker.title = self.flight.departure
                
                let lastMarker = GMSMarker()
                lastMarker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees((points.last?.latitude!)!), longitude: CLLocationDegrees((points.last?.longitude!)!))
                lastMarker.title = self.flight.arrival
                
                startMarker.map = self.mapView
                lastMarker.map = self.mapView
            }
        }
        
        task.resume()
    }
    
    
    func getDirection() {
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=Frankfurt&destination=Madrid&departure_time=1555869600&mode=transit&key=AIzaSyDa8maJ9otae3IQgOLqRH7uA7HQQ-995ZY")
        
        
        //e77dd9-351748 depIcao=EDDF&arrIcao=LEMD

        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            do {
                if data != nil {
                    let dic = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! [String:AnyObject]
//                    print(dic)
                    
                    let status = dic["status"] as! String
                    var routesArray:String!
                    if status == "OK" {
                        
                        let routes = dic["routes"]! as! [Any]
                        print("routes = \(routes[0])")
                        
                        routesArray = (((dic["routes"]!as! [Any])[0] as! [String:Any])["overview_polyline"] as! [String:Any])["points"] as! String
//                    print("routesArray: \(String(describing: routesArray))")
                    }
                    
                    DispatchQueue.main.async {
                        let path = GMSPath.init(fromEncodedPath: routesArray!)
                        let singleLine = GMSPolyline.init(path: path)
                        singleLine.strokeWidth = 6.0
                        singleLine.strokeColor = .blue
                        singleLine.map = self.mapView
                    }
                    
                }
            } catch {
                print("Error")
            }
        }
        
        task.resume()
    }
    
    func drawLine() {
        mapView.clear()
        
        let path = GMSMutablePath()
        path.add(CLLocationCoordinate2D(latitude: 50.1055522, longitude: 8.661708000000001))
        path.add(CLLocationCoordinate2D(latitude: 53.0282, longitude: 27.3137))
        
        let startMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: 50.1055522, longitude: 8.661708000000001))
        startMarker.title = "Frankfurt"
        let animation = GMSMarkerAnimation.pop
        startMarker.snippet = "My airport info in future"
        startMarker.appearAnimation = animation
        
        let endMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: 53.0282, longitude: 27.3137))
        endMarker.title = "Belarus"
        
        
        let airplaneMarker = GMSMarker()
        let airplaneImage = #imageLiteral(resourceName: "miniEmpty-2").withRenderingMode(.alwaysTemplate)
        
        let markerView = UIImageView(image: airplaneImage)
        
        markerView.tintColor = .red
        airplaneMarker.iconView = markerView
        
//        print(airplaneMarker.icon?.size)
        airplaneMarker.position = CLLocationCoordinate2D(latitude: 53.0282, longitude: 27.3137)
        airplaneMarker.title = "THIS IS AIRPLANE"
//        airplaneMarker.isFlat = true
        
        
        startMarker.map = mapView
//        endMarker.map = mapView
        airplaneMarker.map = mapView
        
        let polyline = GMSPolyline(path: path)
        polyline.geodesic = true
        polyline.strokeColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        polyline.strokeWidth = 4
        polyline.map = mapView
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


