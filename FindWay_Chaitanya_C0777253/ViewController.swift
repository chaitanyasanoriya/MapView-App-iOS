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
        // Do any additional setup after loading the view.
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
}

extension ViewController: CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: self.REGION_IN_METERS, longitudinalMeters: self.REGION_IN_METERS)
        mMapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
