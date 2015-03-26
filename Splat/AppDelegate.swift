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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        PFQuery.clearAllCachedResults()
        Parse.enableLocalDatastore()
        
        Parse.setApplicationId("bPx47th2SCzPkhTnnbWuoYQ3X2oeB6nq5aK007T8", clientKey: "bBMvgqmIMqsAHESMqZfk2GdRfv4WTsYZcBB7YUXj")
        
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        Location().getUserLocation()
        
        //login
        if (PFAnonymousUtils.isLinkedWithUser(PFUser.currentUser())) {
            println("logged in")
        }
        else {
            PFAnonymousUtils.logInWithBlock { (user, error) -> Void in
                var test = PFUser.currentUser()
                println(test.objectId)
                
                //set acl
                var defaultACL = PFACL()
                defaultACL.setPublicReadAccess(true)
                defaultACL.setPublicWriteAccess(true)
                PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)
                
                //remove old user defaults
                if let appDomain = NSBundle.mainBundle().bundleIdentifier {
                    NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain)
                    println(NSUserDefaults.standardUserDefaults().objectForKey("SplatUpvotes"))
                }
                
            }
        }
        
        //set acl
        var defaultACL = PFACL()
        defaultACL.setPublicReadAccess(true)
        defaultACL.setPublicWriteAccess(true)
        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)
        
        var feedView = FeedViewController(style: UITableViewStyle.Plain)
        var navView = RootNavViewController(rootViewController: feedView)
        self.window?.rootViewController = navView
        
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
        
        NSNotificationCenter.defaultCenter().postNotificationName("ReloadFeed", object: nil)
        Location().getUserLocation()
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

