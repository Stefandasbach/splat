//
//  SplatLocation.swift
//  Splat
//
//  Created by Aaron Tainter on 3/25/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation
import CoreLocation

class Location: NSObject, CLLocationManagerDelegate {
    class func getStates()->[String] {
        return ["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"]
    }
    
    override init() {
        super.init()
    }
    
    func getUserLocation() {
        let locationManager = CLLocationManager()
        
        /* Get user location */
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        /* Is user's location available? */
        if let userLocation = locationManager.location {
            saveUserLocation(userLocation)
        }
        else {
            /* Calls didUpdateLocations when user's location is available */
            locationManager.startUpdatingLocation()
        }
    }
    /* Waits for user's location to become available */
    func locationManager(manager: CLLocationManager!, didUpdateLocations
        locations: [AnyObject]!) {
            if let userLocation = manager.location {
                saveUserLocation(userLocation)
            }
            manager.stopUpdatingLocation()
    }
    func saveUserLocation(userLocation: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler: { (placemarks: [AnyObject]!, error: NSError!) in
            if error == nil && placemarks.count > 0 {
                let geoLocation = placemarks[0] as CLPlacemark
                let country = geoLocation.country
                let state = geoLocation.administrativeArea
                let defaults = NSUserDefaults.standardUserDefaults()
                if country == "United States" {
                    defaults.setObject(state, forKey: "state")
                }
                else {
                    defaults.setObject(state, forKey: "foreign")
                }
            }
        })
    }

}