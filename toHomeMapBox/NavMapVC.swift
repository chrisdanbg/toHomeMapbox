//
//  ViewController.swift
//  toHomeMapBox
//
//  Created by Kristyan Danailov on 13.05.18 г..
//  Copyright © 2018 г. Kristyan Danailov. All rights reserved.
//

import UIKit
import Mapbox
import MapboxCoreNavigation
import MapboxDirections
import MapboxNavigation

class NavMapVC: UIViewController, MGLMapViewDelegate {
    var mapView: NavigationMapView!
    var directionsRoute: Route?
    
    var homeLocation = CLLocationCoordinate2D()
    var newHomeLocation = CLLocationCoordinate2D()
    var disneyLocation = CLLocationCoordinate2DMake(37.8014548, -122.4586558)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = NavigationMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
        mapView.delegate = self
        
        mapView.setUserTrackingMode(.follow
            , animated: true)
        view.addSubview(mapView)
        mapView.showsUserLocation = true
        
        addbutton()
    }
    
    func addbutton() {
        let toHomeButton: UIButton = {
            let button = UIButton(frame: CGRect(x: (view.frame.width/2) - 100, y: view.frame.height - 75, width:200, height: 50))
            button.setTitle("To Home", for: .normal)
            button.layer.cornerRadius = 20.0
            button.clipsToBounds = true
            button.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            button.layer.shadowOffset = CGSize(width: 0, height: 10)
            button.layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            button.layer.shadowRadius = 5
            button.layer.shadowOpacity = 0.3
            button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 18)
            button.showsTouchWhenHighlighted = true
            button.addTarget(self, action: #selector(takeMeHome), for: .touchUpInside)
            return button
        }()
        
        view.addSubview(toHomeButton)
    }
  
    
    func calculateRoute(from originCoor:CLLocationCoordinate2D, to destinationCoor: CLLocationCoordinate2D, completion: @escaping (Route?, Error?) -> Void) {
        let origin = Waypoint(coordinate: originCoor, coordinateAccuracy: -1, name: "Start")
        let destination = Waypoint(coordinate: destinationCoor, coordinateAccuracy: -1, name: "Finish")
        let options = NavigationRouteOptions(waypoints: [origin,destination], profileIdentifier: .automobileAvoidingTraffic )
        
        _ = Directions.shared.calculate(options, completionHandler: { (waypoints, route, error) in
            self.directionsRoute = route?.first
            self.drawLine(route: self.directionsRoute!)
            
            let coordinateBounds = MGLCoordinateBounds(sw: destinationCoor, ne: originCoor)
            let insets = UIEdgeInsetsMake(50, 50, 50, 50)
            let followCamera = self.mapView.cameraThatFitsCoordinateBounds(coordinateBounds, edgePadding: insets)
            self.mapView.setCamera(followCamera, animated: true)
        })
    }
    
    func drawLine(route: Route) {
        guard route.coordinateCount > 0 else {return}
        var routeCoordinates = route.coordinates!
        var polyLine = MGLPolylineFeature(coordinates: &routeCoordinates, count: route.coordinateCount)
        
        if let source = mapView.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
            source.shape = polyLine
        } else {
            let source = MGLShapeSource(identifier: "route-source", features: [polyLine], options: nil)
            
            let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
            lineStyle.lineColor = NSExpression(forConstantValue: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
            lineStyle.lineWidth = NSExpression(forConstantValue: 7.0)
            
            mapView.style?.addSource(source)
            mapView.style?.addLayer(lineStyle)
        }
    }
    
  //  @objc func setNewHome(sender: UIButton!) {
   //     newHomeLocation = homeLocation
     //   storeCoordinates([newHomeLocation])
 //   }
    
    @objc func buttonAction(sender: UIButton!) {
        UIView.animate(withDuration: 0.6,
                       animations: {
                  //      self.toHomeButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.6) {
                       //     self.toHomeButton.transform = CGAffineTransform.identity
                        }
        })
    }
    
    func storeCoordinates(_ coordinates: [CLLocationCoordinate2D]) {
        let locations = coordinates.map { coordinate -> CLLocation in
            return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
        let archived = NSKeyedArchiver.archivedData(withRootObject: locations)
        UserDefaults.standard.set(archived, forKey: "coordinates")
        UserDefaults.standard.synchronize()
    }
    
    func loadCoordinates() -> [CLLocationCoordinate2D]? {
        guard let archived = UserDefaults.standard.object(forKey: "coordinates") as? Data,
            let locations = NSKeyedUnarchiver.unarchiveObject(with: archived) as? [CLLocation] else {
                return nil
        }
        
        let coordinates = locations.map { location -> CLLocationCoordinate2D in
            return location.coordinate
        }
        
        return coordinates
}
    
    @objc func takeMeHome(sender: UIButton!) {
        let myHomeDestination = loadCoordinates()
        let currentLocation = mapView.userLocation!.coordinate
        calculateRoute(from: currentLocation, to: disneyLocation) { (route, error) in
            if error != nil {
                print("Error occured")
            }
        }
    }

}
