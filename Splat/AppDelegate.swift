//
//  AppDelegate.swift
//  Splat
//
//  Created by Aaron Tainter on 3/3/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Parse.enableLocalDatastore()
        
        Parse.setApplicationId("bPx47th2SCzPkhTnnbWuoYQ3X2oeB6nq5aK007T8", clientKey: "bBMvgqmIMqsAHESMqZfk2GdRfv4WTsYZcBB7YUXj")
        
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        //MARK: Push notifications
        initPushNotifications(application, launchOptions: launchOptions)
        
        //MARK: Login
        login()
        
        /* View controllers rendered from this function call- see function saveUserLocation */
        getUserLocation()
        
        //reset the selected location
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue("", forKey: "SelectedLocation")
        
        /* === Uncomment for simulator testing === */
        self.window?.rootViewController?.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        var feedView = FeedViewController(style: UITableViewStyle.Plain)
        var navView = RootNavViewController(rootViewController: feedView)
        self.window?.rootViewController = navView
        /* === Uncomment for simulator testing === */
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        
        //make sure that our keyboard is removed so our view will not be offset
        NSNotificationCenter.defaultCenter().postNotificationName("RemoveKeyboard", object: nil)
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
       /* NSNotificationCenter.defaultCenter().postNotificationName("ReloadFeed", object: nil) */
        getUserLocation()
        login()
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //--------------------------------------
    // MARK: Push Notifications
    //--------------------------------------
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
        
        PFPush.subscribeToChannelInBackground("", block: { (succeeded: Bool, error: NSError!) -> Void in
            if succeeded {
                println("SplatIt successfully subscribed to push notifications on the broadcast channel.");
            } else {
                println("SplatIt failed to subscribe to push notifications on the broadcast channel with error = %@.", error)
            }
        })
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            println("Push notifications are not supported in the iOS Simulator.")
        } else {
            println("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }

    //MARK: login functions
    func login() {
        
        //PFUser.enableAutomaticUser()
        /* Login */
        if (PFAnonymousUtils.isLinkedWithUser(PFUser.currentUser())) {
            Notification.enableNotificationsForUser(User(pfObject: PFUser.currentUser()))
        }
        else {
            PFAnonymousUtils.logInWithBlock { (user, error) -> Void in
                var test = PFUser.currentUser()
                
                //set acl
                var defaultACL = PFACL()
                defaultACL.setPublicReadAccess(true)
                defaultACL.setPublicWriteAccess(true)
                PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)
                
                Notification.enableNotificationsForUser(User(pfObject: PFUser.currentUser()))
                
                //remove old user defaults
                if let appDomain = NSBundle.mainBundle().bundleIdentifier {
                    NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain)
                }
            }
        }
    }
    
    func getUserLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()

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
        /* Just need their location once */
        manager.stopUpdatingLocation()
    }
    func saveUserLocation(userLocation: CLLocation) {
        println("Saved Location")
        CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler: {
                                           (placemarks: [AnyObject]!, error: NSError!) in
            if error == nil && placemarks.count > 0 {
                let geoLocation = placemarks[0] as CLPlacemark
                let country = geoLocation.country
                let state = geoLocation.administrativeArea
                let defaults = NSUserDefaults.standardUserDefaults()
                if country == "United States" {
                    defaults.setObject(state, forKey: "state")
                    /* Only show user's state at the top of the list */
                   Location.getStates(state)
                }
                else {
                    defaults.setObject(state, forKey: "foreign")
                }
                self.window?.rootViewController?.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
                var feedView = FeedViewController(style: UITableViewStyle.Plain)
                var navView = RootNavViewController(rootViewController: feedView)
                self.window?.rootViewController = navView
            }
        })
    }
    func locationManager(manager: CLLocationManager!,
         didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            
        if (status == CLAuthorizationStatus.NotDetermined ||
            status == CLAuthorizationStatus.AuthorizedWhenInUse ||
            status == CLAuthorizationStatus.AuthorizedAlways) {
            return
        } else {
            let alertController = UIAlertController(
                title: "Location Access Disabled",
                message: "To contribute to the fun, we need your location. All your data will be kept private",
                preferredStyle: .Alert)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            self.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func initPushNotifications(application: UIApplication, launchOptions: [NSObject: AnyObject]?) {
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var noPushPayload = false;
            if let options = launchOptions {
                noPushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil;
            }
            if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            let types = UIRemoteNotificationType.Badge | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Sound
            application.registerForRemoteNotificationTypes(types)
        }

    }

}

