//
//  ViewController.swift
//  GoogleRoutDirections
//
//  Created by vishal on 23/12/17.
//  Copyright © 2017 vishal. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import CoreLocation
import Alamofire
enum Location {
    case startLocation
    case destinationLocation
}

class ViewController: UIViewController ,GMSMapViewDelegate , CLLocationManagerDelegate {
  
    var locationManager = CLLocationManager()
    var locationSelected = Location.startLocation
    
    @IBOutlet weak var googleMapview: GMSMapView!
    @IBOutlet weak var startLocation: UITextField!
    @IBOutlet weak var destinationLocation: UITextField!
    
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
       
        let camera = GMSCameraPosition.camera(withLatitude: -7.9293122, longitude: 112.5879156, zoom: 15.0)
        self.googleMapview.camera = camera
        self.googleMapview.delegate = self
        self.googleMapview.isMyLocationEnabled = true
        self.googleMapview.settings.myLocationButton = true
        self.googleMapview.settings.zoomGestures = true
        self.googleMapview.settings.compassButton = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- Button Click Events
    @IBAction func startLocationButtonClick(_ sender: UIButton) {
        let autoCompleteConntroller = GMSAutocompleteViewController()
        autoCompleteConntroller.delegate = self
        locationSelected = .startLocation
        
        UISearchBar.appearance().tintColor = UIColor.black
        self.locationManager.stopUpdatingLocation()
        self.present(autoCompleteConntroller, animated: true, completion: nil)
        
    }
    
    @IBAction func destinationLocationButtonCLick(_ sender: UIButton) {
        let autoCompleteConntroller = GMSAutocompleteViewController()
        autoCompleteConntroller.delegate = self
        locationSelected = .destinationLocation
        
        UISearchBar.appearance().tintColor = UIColor.black
        self.locationManager.stopUpdatingLocation()
        self.present(autoCompleteConntroller, animated: true, completion: nil)
    }
    
    @IBAction func showDirectionButtonClick(_ sender: UIButton) {
        if startLocation.text != "" && destinationLocation.text != "" {
            self.googleMapview.clear()
            createMarker(titleMarker: "My Location", iconMarker: UIImage(named: "CurruntPlace")!, latitude: locationStart.coordinate.latitude, longitude: (locationStart.coordinate.longitude))
            createMarker(titleMarker: "Destination Location", iconMarker: UIImage(named: "DestinationPlace")!, latitude: (locationEnd.coordinate.latitude), longitude: (locationEnd.coordinate.longitude))
            self.drowPath(startLocation: locationStart, endLocation: locationEnd)
        }
        else{
            let alert = UIAlertController(title: "Alert", message: "Please Select Location", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK:- Create Marker
    func createMarker(titleMarker:String, iconMarker:UIImage , latitude:CLLocationDegrees , longitude:CLLocationDegrees){
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.title = titleMarker
        marker.icon = iconMarker
        marker.map = googleMapview
    }
    
    //MARK:- Location Manager Delegate Method
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error To Failed Location \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last
//        let location = CLLocation(latitude: 21.2299611, longitude: 72.8127235)
        createMarker(titleMarker: "My Location", iconMarker: UIImage(named: "pin")!, latitude: (lastLocation?.coordinate.latitude)!, longitude: (lastLocation?.coordinate.longitude)!)
//        createMarker(titleMarker: "Destination Location", iconMarker: UIImage(named: "DestinationPlace")!, latitude: (lastLocation?.coordinate.latitude)!, longitude: (lastLocation?.coordinate.longitude)!)
//        drowPath(startLocation: location, endLocation: lastLocation!)
//        locationStart = locations.last!
        self.locationManager.stopUpdatingLocation()

    }
    
    //MARK:- GMSMapview Delegate Method
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        googleMapview.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        mapView.isMyLocationEnabled = true
        if (gesture) {
            googleMapview.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        googleMapview.isMyLocationEnabled = true
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
//        self.googleMapview.clear()
//        let point = mapView.center
//        let centerCoordinator = mapView.projection.coordinate(for: point)
//        createMarker(titleMarker: "My Location", iconMarker: UIImage(named: "pin")!, latitude: centerCoordinator.latitude, longitude: centerCoordinator.longitude)
//        let location = CLLocation(latitude: centerCoordinator.latitude, longitude: centerCoordinator.longitude)
//        drowPath(startLocation: location, endLocation: locationEnd)
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("COORDINATE \(coordinate)")
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        googleMapview.isMyLocationEnabled = true
        googleMapview.selectedMarker = nil
        return false
    }
    
    func drowPath(startLocation: CLLocation , endLocation: CLLocation){
        let origin = "\(startLocation.coordinate.latitude), \(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude), \(endLocation.coordinate.longitude)"

        let url = "http://maps.googleapis.com/maps/api/directions/json?origin=\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)&destination=\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)&sensor=false&mode=driving"
        
        Alamofire.request(url).responseJSON { (response) in
            if response.result.value != nil {
                let json:NSDictionary = response.result.value as! NSDictionary
                let routes:NSArray = json.value(forKey: "routes") as! NSArray
                for route in routes {
                    let dic:NSDictionary = route as! NSDictionary
                    let routPollyline:NSDictionary = dic.value(forKey: "overview_polyline") as! NSDictionary
                    let points:String = routPollyline.value(forKey: "points") as! String
                    let path = GMSPath.init(fromEncodedPath: points)
                    let polyline = GMSPolyline.init(path: path)
                    polyline.strokeWidth = 4.0
                    polyline.strokeColor = UIColor.red
                    polyline.map = self.googleMapview
                }
            }
        }
    }
}

extension ViewController:GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // Change Camera Location
        let camera = GMSCameraPosition.camera(withLatitude:place.coordinate.latitude , longitude: place.coordinate.longitude, zoom: 16.0)
        if locationSelected == .startLocation {
            startLocation.text = "\(place.coordinate.latitude), \(place.coordinate.longitude)"
            locationStart = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            createMarker(titleMarker: "Location Start", iconMarker: UIImage(named: "CurruntPlace")!, latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        }
        else{
            destinationLocation.text = "\(place.coordinate.latitude), \(place.coordinate.longitude)"
            locationEnd = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            createMarker(titleMarker: "Location End", iconMarker: UIImage(named: "DestinationPlace")!, latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        }
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didSelect prediction: GMSAutocompletePrediction) -> Bool {
        self.dismiss(animated: true, completion: nil)
        return true
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error:- \(error.localizedDescription)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

//public extension UISearchBar{
//    public func setTextColor(color:UIColor){
//        let svs = subviews.flatMap { $0.subview }
//        guard let tf =
//    }
//}

