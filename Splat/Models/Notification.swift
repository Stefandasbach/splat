//
//  Notification.swift
//  Splat
//
//  Created by Aaron Tainter on 4/7/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation
import Parse

class Notification: NSObject {
    
    class func enableNotificationsForUser(user: User) {
        if let channels = PFInstallation.currentInstallation().objectForKey("channels") as? NSArray {
            //if the channel is set for the wrong user
            if ((channels[0] as? String) != ("profile\(user.getObject().objectId!)")) {
                let currentInstallation = PFInstallation.currentInstallation()
                currentInstallation.setObject(["profile\(user.getObject().objectId!)"], forKey: "channels")
                currentInstallation.saveInBackground()
            }
            //if a channel is not set
        } else {
            let currentInstallation = PFInstallation.currentInstallation()
            currentInstallation.setObject(["profile\(user.getObject().objectId!)"], forKey: "channels")
            currentInstallation.saveInBackground()
        }
        
    }
    
    class func resetIconBadgeNumber(application: UIApplication) {
        application.applicationIconBadgeNumber = 0;
        var currentInstallation = PFInstallation.currentInstallation()
        if (currentInstallation.badge != 0) {
            currentInstallation.badge = 0
            currentInstallation.saveEventually()
        }
    }
    
    class func getNumberOfNewNotifications() -> Int {
        var currentInstallation = PFInstallation.currentInstallation()
        return currentInstallation.badge
    }
    
    class func sendNotificationForReply(reply: Reply, parentPost: Post) {
        var notification = Notification()
        notification.setType("Reply")
        notification.setPost(parentPost.getObject())
        notification.setReply(reply.getObject())
        notification.setReceiver(parentPost.getCreator().objectId!)
        
        notification.getObject().saveInBackgroundWithBlock { (success, error) -> Void in
            if (error != nil) {
                println(error)
            } else {
                if (success) {
                    println("Sent notification for reply.")
                    let push = PFPush()
                    push.setChannel("profile\(parentPost.getCreator().objectId!)")
                    push.setData(["alert":"Someone replied to your post!", "badge":"Increment"])
                    push.sendPushInBackground()
                }
            }
        }
    }
    
    var object = PFObject(className: "Notification")
    
    class func parseClassName() -> String! {
        return "Notification"
    }

    override init() {
        super.init()
        
    }
    
    init(pfObject: PFObject) {
        if pfObject.parseClassName != "Notification" {
            println("Not correct class type.")
        } else {
            object = pfObject
        }
    }
    
    func getObject() -> PFObject {
        return object
    }
    
    func setType(type: String) {
        object["type"] = type
    }
    
    func getType() -> String? {
        return object["type"] as? String
    }
    
    func setReply(reply: PFObject) {
        object["reply"] = reply
    }
    
    func getReply() -> Reply? {
        if let pfObject = object["reply"] as? PFObject {
            var reply = Reply(pfObject: pfObject)
            return reply
        } else {
            return nil
        }
        
    }
    
    func setPost(post: PFObject) {
        object["post"] = post
    }
    
    func getPost() -> Post? {
        if let pfObject = object["post"] as? PFObject {
            var post = Post(pfObject: pfObject)
            return post
        } else {
            return nil
        }
        
    }
    
    func setReceiver(oID: String) {
        object["receiver"] = oID
    }
    
    func getReceiver() -> String? {
        return object["receiver"] as? String
    }
}