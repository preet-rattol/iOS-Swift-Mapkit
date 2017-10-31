//
//  ViewController.swift
//  Assignment1
//
//  Created by Preet Kanwal Singh on 2017-10-11.
//  Copyright © 2017 Preet Kanwal Singh. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
class ViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
   
    let locationManager = CLLocationManager()
    let initialLocation = CLLocation(latitude: 43.655787, longitude: -79.739534)
    let regionRadius: CLLocationDistance = 2000
    
    @IBOutlet var myMapView : MKMapView!
    @IBOutlet var tbLocEntered : UITextField!
    @IBOutlet var waypoint1 : UITextField!
    @IBOutlet var waypoint2 : UITextField!
    @IBOutlet var myTableView : UITableView!
    @IBOutlet var lblMessage : UILabel!
    
    var routeSteps = ["Enter a destination to see steps"]
    var boundary: [CLLocationCoordinate2D] = []
    var message : String = ""

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func centerMapOnLocation(location : CLLocation){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        myMapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centerMapOnLocation(location: initialLocation)
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = initialLocation.coordinate
        dropPin.title = "Starting at Sheridan College"
        self.myMapView.addAnnotation(dropPin)
        self.myMapView.selectAnnotation(dropPin, animated: true)
        self.myMapView.isZoomEnabled = true
        
        let p1 = CLLocationCoordinate2DMake(43.646899,-79.7500995)
        boundary.append(p1)
        
        let p2 = CLLocationCoordinate2DMake(43.666119,-79.733288)
        boundary.append(p2)
        
        let p3 = CLLocationCoordinate2DMake(43.646040,-79.706297)
        boundary.append(p3)
        
        let p4 = CLLocationCoordinate2DMake(43.632933,-79.722488)
        boundary.append(p4)
        
        let p5 = CLLocationCoordinate2DMake(43.646899,-79.7500995)
        boundary.append(p5)
        
        self.myMapView.add(MKPolyline(coordinates: boundary, count: boundary.count))
        
    }
    
    @IBAction func findNewLocation(){
        
        let geocoder = CLGeocoder()
        var waypoint1Location : CLLocation?
        var waypoint2Location : CLLocation?
        
        let waypoint1Text = waypoint1.text
        geocoder.geocodeAddressString(waypoint1Text!, completionHandler:
            {
                (placemarks, error) -> Void in
                if(error != nil){
                    print("Error", error as Any)
                }
                if let placemark = placemarks?.first{
                    let coordinates : CLLocationCoordinate2D = placemark.location!.coordinate
                    
                    let newLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                    self.centerMapOnLocation(location: newLocation)
                    waypoint1Location = newLocation
                    
                    let dropPin = MKPointAnnotation()
                    dropPin.coordinate = coordinates
                    dropPin.title = placemark.name
                    self.myMapView.addAnnotation(dropPin)
                    self.myMapView.selectAnnotation(dropPin, animated: true)
                    
                    let request = MKDirectionsRequest()
                    request.source = MKMapItem(placemark: MKPlacemark(coordinate: self.initialLocation.coordinate, addressDictionary: nil))
                    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinates, addressDictionary: nil))
                    request.requestsAlternateRoutes = false
                    request.transportType = .automobile
                    
                    let directions = MKDirections(request: request)
                    directions.calculate(completionHandler:
                        {[unowned self] response, error in
                            
                            for route in (response?.routes)!{
                                self.myMapView.add(route.polyline, level: MKOverlayLevel.aboveRoads)
                                self.myMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                                
                                self.routeSteps.removeAll()
                                for step in route.steps {
                                    self.routeSteps.append(step.instructions)
                                    self.myTableView.reloadData()
                                }
                            }
                        }
                    )
                }
                
 
                let waypoint2Text = self.waypoint2.text
                geocoder.geocodeAddressString(waypoint2Text!, completionHandler:
                    {
                        (placemarks, error) -> Void in
                        if(error != nil){
                            print("Error", error as Any)
                        }
                        if let placemark = placemarks?.first{
                            let coordinates : CLLocationCoordinate2D = placemark.location!.coordinate
                            
                            let newLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                            self.centerMapOnLocation(location: newLocation)
                            waypoint2Location = newLocation
                            
                            let dropPin = MKPointAnnotation()
                            dropPin.coordinate = coordinates
                            dropPin.title = placemark.name
                            self.myMapView.addAnnotation(dropPin)
                            self.myMapView.selectAnnotation(dropPin, animated: true)
                            
                            let request = MKDirectionsRequest()
                            request.source = MKMapItem(placemark: MKPlacemark(coordinate: (waypoint1Location?.coordinate)!, addressDictionary: nil))
                            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinates, addressDictionary: nil))
                            request.requestsAlternateRoutes = false
                            request.transportType = .automobile
                            
                            let directions = MKDirections(request: request)
                            directions.calculate(completionHandler:
                                {[unowned self] response, error in
                                    
                                    for route in (response?.routes)!{
                                        self.myMapView.add(route.polyline, level: MKOverlayLevel.aboveRoads)
                                        self.myMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                                        
                                        for step in route.steps {
                                            self.routeSteps.append(step.instructions)
                                            self.myTableView.reloadData()
                                        }
                                    }
                                }
                            )
                        }

                        
                        
                        let locEnteredText = self.tbLocEntered.text
                        geocoder.geocodeAddressString(locEnteredText!, completionHandler:
                            {
                                (placemarks, error) -> Void in
                                if(error != nil){
                                    print("Error", error as Any)
                                }
                                if let placemark = placemarks?.first{
                                    let coordinates : CLLocationCoordinate2D = placemark.location!.coordinate
                                    
                                    if coordinates.latitude < self.boundary[0].latitude && coordinates.longitude < self.boundary[0].longitude{
                                        self.message = "Ouside the Boundary"
                                    }
                                    else if coordinates.latitude > self.boundary[1].latitude && coordinates.longitude < self.boundary[1].longitude{
                                        self.message = "Ouside the Boundary"
                                    }
                                    else if coordinates.latitude > self.boundary[1].latitude && coordinates.longitude > self.boundary[1].longitude{
                                        self.message = "Ouside the Boundary"
                                    }
                                    else if coordinates.latitude < self.boundary[1].latitude && coordinates.longitude > self.boundary[1].longitude{
                                        self.message = "Ouside the Boundary"
                                    }
                                    else{
                                        self.message = "Inside the Boundary"
                                    }
                                    
                                    self.lblMessage.text = self.message
                                    
                                    let newLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                                    self.centerMapOnLocation(location: newLocation)
                                    
                                    let dropPin = MKPointAnnotation()
                                    dropPin.coordinate = coordinates
                                    dropPin.title = placemark.name
                                    self.myMapView.addAnnotation(dropPin)
                                    self.myMapView.selectAnnotation(dropPin, animated: true)
                                    
                                    let request = MKDirectionsRequest()
                                    request.source = MKMapItem(placemark: MKPlacemark(coordinate: (waypoint2Location?.coordinate)!, addressDictionary: nil))
                                    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinates, addressDictionary: nil))
                                    request.requestsAlternateRoutes = false
                                    request.transportType = .automobile
                                    
                                    let directions = MKDirections(request: request)
                                    directions.calculate(completionHandler:
                                        {[unowned self] response, error in
                                            
                                            for route in (response?.routes)!{
                                                self.myMapView.add(route.polyline, level: MKOverlayLevel.aboveRoads)
                                                self.myMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                                                
                                                for step in route.steps {
                                                    self.routeSteps.append(step.instructions)
                                                    self.myTableView.reloadData()
                                                }
                                            }
                                        }
                                    )
                                }
                            }
                        )
                        
                    }
                )

        
            }
        )
    
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 3.0
        return renderer
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeSteps.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
        
        tableCell.textLabel?.text = routeSteps[indexPath.row]
        
        return tableCell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

