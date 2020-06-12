//
//  ViewController.swift
//  FindWay_Chaitanya_C0777253
//
//  Created by Chaitanya Sanoriya on 11/06/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var mMapView: MKMapView!
    
    let mLocationManager = CLLocationManager()
    let REGION_IN_METERS: Double = 10000
    var mDestination: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        removeTapGestures()
        let tap = UITapGestureRecognizer(target: self, action: #selector(addAnnotation))
        tap.numberOfTapsRequired = 2
        //        mMapView.add(tap as! MKOverlay)
        //IOS 9
        mMapView.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    func removeTapGestures()
    {
        if (mMapView.subviews[0].gestureRecognizers != nil){
            for gesture in mMapView.subviews[0].gestureRecognizers!{
                if (gesture is UITapGestureRecognizer){
                    mMapView.subviews[0].removeGestureRecognizer(gesture)
                }
            }
        }
    }
    
    func setupLocationManager()
    {
        mLocationManager.delegate = self
        mLocationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices()
    {
        if CLLocationManager.locationServicesEnabled()
        {
            setupLocationManager()
            checkLocationAuthorization()
        }
        else
        {
            // Code Add Alert
        }
    }
    
    func checkLocationAuthorization()
    {
        switch CLLocationManager.authorizationStatus()
        {
        case .authorizedWhenInUse:
            mMapView.showsUserLocation = true
            centerViewOnUserLocation()
            mLocationManager.startUpdatingLocation()
            break
        case .denied:
            // Code Add Alert
            break
        case .notDetermined:
            mLocationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Code Add alert
            break
        case .authorizedAlways:
            break
        @unknown default:
            // Code
            break
        }
    }
    
    func centerViewOnUserLocation()
    {
        if let location = mLocationManager.location?.coordinate
        {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: self.REGION_IN_METERS, longitudinalMeters: self.REGION_IN_METERS)
            mMapView.setRegion(region, animated: true)
        }
    }
    
    @IBAction func centerLocation(_ sender: Any) {
        centerViewOnUserLocation()
    }
    
    
    @objc func addAnnotation(gestureRecognizer:UITapGestureRecognizer){
        removeOverlaysAndAnnotations()
        let touchPoint = gestureRecognizer.location(in: mMapView)
        let newCoordinates = mMapView.convert(touchPoint, toCoordinateFrom: mMapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        mDestination = CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude)
        CLGeocoder().reverseGeocodeLocation(self.mDestination!, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription )
                return
            }
            
            if placemarks?.count ?? 0 > 0 {
                let pm = placemarks?[0] as! CLPlacemark
                
                // not all places have thoroughfare & subThoroughfare so validate those values
                annotation.title = pm.thoroughfare ?? "nil" + ", " + pm.subThoroughfare!
                annotation.subtitle = pm.subLocality
                self.mMapView.addAnnotation(annotation)
                print(pm)
            }
            else
            {
                annotation.title = "Unknown Place"
                self.mMapView.addAnnotation(annotation)
                print("Problem with the data received from geocoder")
            }
            //            places.append(["name":annotation.title,"latitude":"\(newCoordinates.latitude)","longitude":"\(newCoordinates.longitude)"])
        })
    }
    
        func getDirections()
        {
            guard let location = mLocationManager.location?.coordinate else
            {
                //TODO: Alert User
                return
            }
            if mDestination != nil
            {
                let request = createDirectionRequest(from: location)
                let directions = MKDirections(request: request)
                
                directions.calculate { [unowned self] (response, error) in
                    //TODO: Handle error if needed
                    
                    guard let response = response else
                    {
                        //TODO: show response not available in an alert
                        return
                    }
                    
                    for route in response.routes
                    {
                        self.mMapView.addOverlay(route.polyline)
                        self.mMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                    }
                }
            }
            else
            {
                //TODO: Alert User
            }
        }
    
        func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request
        {
            let destination_coordinate = mDestination!.coordinate
            let starting_location = MKPlacemark(coordinate: coordinate)
            let destination = MKPlacemark(coordinate: destination_coordinate)
    
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: starting_location)
            request.destination = MKMapItem(placemark: destination)
            request.transportType = .automobile
            request.requestsAlternateRoutes = false
            return request
        }
    
    @IBAction func findWayButtonClicked(_ sender: Any) {
                getDirections()
    }
    
    func removeOverlaysAndAnnotations()
    {
        mMapView.removeOverlays(mMapView.overlays)
        mMapView.removeAnnotations(mMapView.annotations)
    }
}

extension ViewController: CLLocationManagerDelegate
{
    //    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //        guard let location = locations.last else {return}
    //        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    //        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: self.REGION_IN_METERS, longitudinalMeters: self.REGION_IN_METERS)
    //        mMapView.setRegion(region, animated: true)
    //    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension ViewController: MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
}
