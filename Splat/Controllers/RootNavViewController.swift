//
//  ViewController.swift
//  Splat
//
//  Created by Aaron Tainter on 3/3/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import UIKit
import Foundation
import Parse

class RootNavViewController: UINavigationController, CLLocationManagerDelegate {
    var bottomToolbar: UITabBar!
    let locationManager = CLLocationManager()
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    override init() {
        super.init()
    }
    
    override init(navigationBarClass: AnyClass!, toolbarClass: AnyClass!) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //login
        if (PFAnonymousUtils.isLinkedWithUser(PFUser.currentUser())) {
            println("logged in")
        }
        else {
            PFAnonymousUtils.logInWithBlock { (user, error) -> Void in
                var test = PFUser.currentUser()
                println(test.objectId)
                
                //remove old user defaults
                if let appDomain = NSBundle.mainBundle().bundleIdentifier {
                    NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain)
                    println(NSUserDefaults.standardUserDefaults().objectForKey("SplatUpvotes"))
                }
                
            }
        }
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationBar.barTintColor = UIColorFromRGB(PURPLE_SELECTED)

        /* Get user location */
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        getUserLocation()
        // Do any additional setup after loading the view, typically from a nib.
        renderElements()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getUserLocation() {
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
    
    func renderElements() {
        //may re-add this in the future
        
       /* bottomToolbar = UITabBar(frame: CGRectMake(0, self.view.frame.height-49, self.view.frame.width, 49))
        bottomToolbar.translucent = false
        bottomToolbar.barTintColor = UIColorFromRGB(TOOLBAR_GREY)
        bottomToolbar.shadowImage = UIImage()
        bottomToolbar.backgroundImage = UIImage()
        
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(0, 0))
        path.addLineToPoint(CGPointMake(self.view.frame.width, 0))
        
        //create shape from path
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.CGPath
        shapeLayer.strokeColor = UIColorFromRGB(PURPLE_SELECTED).CGColor
        shapeLayer.lineWidth = 0.8
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        
        bottomToolbar.layer.addSublayer(shapeLayer)
        
        self.view.addSubview(bottomToolbar) */
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func disableBottomToolbar() {
        if (bottomToolbar != nil) {
            bottomToolbar.removeFromSuperview()
        }
    }
    
    func enableBottomToolbar() {
        if (bottomToolbar != nil) {
            self.view.addSubview(bottomToolbar)
        }
    }
}

