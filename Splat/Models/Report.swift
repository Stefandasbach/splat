//
//  Report.swift
//  Splat
//
//  Created by Aaron Tainter on 4/14/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation
import Parse

enum SplatReportType {
    case Inappropriate
    case WithoutConsent
}

class Report: NSObject {
    
    class func sendReport(post: Post, type: SplatReportType, completion: (success: Bool) -> Void) {
        var report = Report()
        report.setPost(post.getObject())
        report.setSender(User())
        
        if type == .Inappropriate {
            report.setType("Inappropriate")
        } else if type == .WithoutConsent {
            report.setType("Without Consent")
        }
        
        report.getObject().saveInBackgroundWithBlock { (success, error) -> Void in
            if error != nil {
                println(error)
            } else {
                if success {
                    println("successfully saved report!")
                    report.addInverseRelationToUser({ (success) -> Void in
                        if (success) {
                            
                            //get main queue
                            dispatch_async(dispatch_get_main_queue(), {
                                completion(success: true)
                            })
                        }
                    })
                } else {
                    println("could not post reply :(")
                }
            }
        }
        
    }
    
    
    var object = PFObject(className: "Report")
    
    class func parseClassName() -> String! {
        return "Report"
    }
    
    override init() {
        super.init()
        
    }
    
    init(pfObject: PFObject) {
        if pfObject.parseClassName != "Report" {
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
    
    func setSender(user: User) {
        object["sender"] = user.getObject()
    }
    
    func getSender() -> User? {
        if let user = object["sender"] as? PFUser {
            return User(pfObject: user)
        } else {
            return nil
        }
    }
    
    func addInverseRelationToUser(completion: (success: Bool) -> Void) {
        var user = User().getObject()
        if let post = getPost() {
            user.addUniqueObject(post.getObject().objectId!, forKey: "Reports")
            user.saveInBackgroundWithBlock { (success, error) -> Void in
                if error != nil {
                    println(error)
                } else {
                    if success {
                        println("successfully added user relation!")
                        completion(success: true)
                    } else {
                        println("relationship broken!")
                    }
                }

            }
        }
    }

}