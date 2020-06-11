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
        print("hello")
        //if gestureRecognizer.state == .began {
            var touchPoint = gestureRecognizer.location(in: mMapView)
            var newCoordinates = mMapView.convert(touchPoint, toCoordinateFrom: mMapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates

            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Reverse geocoder failed with error" + error!.localizedDescription ?? "nil" ?? "nil")
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
            else {
                annotation.title = "Unknown Place"
                self.mMapView.addAnnotation(annotation)
                print("Problem with the data received from geocoder")
            }
//            places.append(["name":annotation.title,"latitude":"\(newCoordinates.latitude)","longitude":"\(newCoordinates.longitude)"])
        })
    //}
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
