//
//  ReportViewController.swift
//  SplatIt Review Tool
//
//  Created by Aaron Tainter on 5/11/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation
import UIKit
import Parse

class ReportViewController: UIViewController {
    var backButton: UIButton!
    
    var postImage: UIImageView!
    var postCaption:UITextView!
    var numberInappropriate: UILabel!
    var numberWithoutConsent: UILabel!
    
    var currentPost: PFObject!
    var numberOfNotifications = 0
    
    //sends a notification to the user and removes all the reports/post
    var removePostButton: UIButton!
    
    //ignores the reports by removing them and sending no notification to the post creator
    var ignoreReports: UIButton!
    
    init(obj: PFObject, number: Int) {
        super.init(nibName: nil, bundle: nil)
        
        currentPost = obj
        numberOfNotifications = number
    }
   
    internal required init(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }

    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        
        backButton = UIButton(frame: CGRect(x: 10, y: 10, width: 50, height: 50))
        backButton.setTitle("Back", forState: UIControlState.Normal)
        backButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        backButton.addTarget(self, action: "backButtonListener", forControlEvents: UIControlEvents.TouchUpInside)
        backButton.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        self.view.addSubview(backButton)
        
        postImage = UIImageView(frame: CGRect(x: 0, y: 60, width: self.view.frame.width, height: self.view.frame.width))
        postImage.contentMode = UIViewContentMode.ScaleAspectFill
        postImage.clipsToBounds = true
        if let picture = currentPost["pictureFile"] as? PFFile {
            picture.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if let pictureData = data {
                    self.postImage.image = UIImage(data: pictureData)
                }
            })
        }
        self.view.addSubview(postImage)
        
        postCaption = UITextView(frame: CGRect(x: 0, y: self.postImage.frame.maxY, width: self.view.frame.width, height: 100))
        postCaption.text = currentPost["comment"] as? String
        self.view.addSubview(postCaption)
        
        numberInappropriate = UILabel()
        
        numberWithoutConsent = UILabel()
        
        removePostButton = UIButton(frame: CGRect(x: self.view.frame.width/2 + 10, y: self.postCaption.frame.maxY, width: self.view.frame.width/2 - 20, height: 50))
        removePostButton.setTitle("Remove Post", forState: UIControlState.Normal)
        removePostButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        removePostButton.addTarget(self, action: "removeButtonListener", forControlEvents: UIControlEvents.TouchUpInside)
        removePostButton.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        self.view.addSubview(removePostButton)
        
        ignoreReports = UIButton(frame: CGRect(x: 10, y: self.postCaption.frame.maxY, width: self.view.frame.width/2 - 20, height: 50))
        ignoreReports.setTitle("Ignore Reports", forState: UIControlState.Normal)
        ignoreReports.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        ignoreReports.addTarget(self, action: "ignoreButtonListener", forControlEvents: UIControlEvents.TouchUpInside)
        ignoreReports.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        self.view.addSubview(ignoreReports)
        
    }
    
    func backButtonListener() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addUserToBannedList()->Int {
        if let creator = currentPost["creator"] as? PFUser {
            var query = PFQuery(className: "BannedUsers")
            query.whereKey("userId", equalTo: creator.objectId!)
            var bannedUser = query.getFirstObject()
            
            if bannedUser == nil {
                println("User not banned yet")
                var bannedUser = PFObject(className: "BannedUsers")
                bannedUser["warnings"] = 1
                bannedUser["userId"] = creator.objectId!
                bannedUser.save()
                return 1
            } else {
                println("Increment warnings for user")
                if let bannedUserNonNil = bannedUser {
                    if var warnings = bannedUserNonNil["warnings"] as? Int {
                        warnings++
                        bannedUserNonNil["warnings"] = warnings
                        bannedUser?.save()
                        return warnings
                    }
                }
            }
        }
        
        return -1
    }
    
    func sendNotificationForUser(numberOfViolations: Int) {
        if let creator = currentPost["creator"] as? PFUser {
            var notification = PFObject(className: "Notification")
            notification["receiver"] = creator.objectId!
            notification["type"] = "Warning"
            notification["warningNumber"] = numberOfViolations
            notification.save()
            
            //post push notification
            var push = PFPush()
            push.setChannel("profile\(creator.objectId!)")
            push.setData(["alert":"You received a warning for misconduct.", "badge":"Increment"])
            push.sendPushInBackgroundWithBlock({ (success, error) -> Void in
                println("Sent push")
            })
        }
    }
    
    func deletePost() {
        currentPost.delete()
    }
    
    func deleteAllReports() {
        var query = PFQuery(className: "Report")
        query.whereKey("post", equalTo: currentPost)
        var reports = query.findObjects()
        PFObject.deleteAll(reports)
    }
    
    func ignoreButtonListener() {
        deleteAllReports()
        NSNotificationCenter.defaultCenter().postNotificationName("refreshFeed", object: nil)
        removeNotificationsNumber()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func removeButtonListener() {
        var value = addUserToBannedList()
        if value != -1 {
            sendNotificationForUser(value)
        }
        deletePost()
        deleteAllReports()
        NSNotificationCenter.defaultCenter().postNotificationName("refreshFeed", object: nil)
        removeNotificationsNumber()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func removeNotificationsNumber() {
        if (PFInstallation.currentInstallation().badge > 0 && (PFInstallation.currentInstallation().badge - numberOfNotifications) >= 0) {
            PFInstallation.currentInstallation().badge -= numberOfNotifications
            PFInstallation.currentInstallation().saveEventually(nil)
        }
    }
}