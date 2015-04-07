//
//  User.swift
//  Splat
//
//  Created by Aaron Tainter on 3/20/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation
import Parse

class User: NSObject {
    
    var object: PFObject!
    
    class func parseClassName() -> String! {
        return "User"
    }
    
    ///Inits the user with a current user
    override init() {
        super.init()
        
        object = PFUser.currentUser()
    }
    
    init(pfObject: PFObject) {
        super.init()
        
        if pfObject.parseClassName != "_User" {
            println("Not correct class type.")
        } else {
            object = pfObject
        }
    }
    
    func getObject() -> PFObject {
        return object
    }
    
    func getPosts() -> NSArray! {
        return object["Posts"] as NSArray!
    }
    
    func getReplies() -> NSArray! {
        return object["Replies"] as NSArray!
    }

}

//functions used for saving things in the user defaults
func archiveDownvote(oID: String, downvotes: NSArray!) {
    var newDownvotes:NSMutableArray
    if (downvotes == nil) {
        newDownvotes = NSMutableArray()
    } else {
        newDownvotes = NSMutableArray(array: downvotes)
    }
    newDownvotes.addObject(oID)
    NSUserDefaults.standardUserDefaults().setObject(newDownvotes, forKey: "SplatDownvotes")
}

func archiveUpvote(oID: String, upvotes: NSArray!) {
    var newUpvotes:NSMutableArray
    if (upvotes == nil) {
        newUpvotes = NSMutableArray()
    } else {
        newUpvotes = NSMutableArray(array: upvotes)
    }
    newUpvotes.addObject(oID)
    NSUserDefaults.standardUserDefaults().setObject(newUpvotes, forKey: "SplatUpvotes")
}

func removeArchivedDownvote(oID: String, downvotes: NSArray!) {
    var newDownvotes = NSMutableArray(array: downvotes)
    newDownvotes.removeObject(oID)
    NSUserDefaults.standardUserDefaults().setObject(newDownvotes, forKey: "SplatDownvotes")
}

func removeArchivedUpvote(oID: String, upvotes: NSArray!) {
    var newUpvotes = NSMutableArray(array: upvotes)
    newUpvotes.removeObject(oID)
    NSUserDefaults.standardUserDefaults().setObject(newUpvotes, forKey: "SplatUpvotes")
}

func archiveFlag(flags: NSArray!, oID: String) {
    var newFlags:NSMutableArray
    if (flags == nil) {
        newFlags = NSMutableArray()
    } else {
        newFlags = NSMutableArray(array: flags)
    }
    newFlags.addObject(oID)
    NSUserDefaults.standardUserDefaults().setObject(newFlags, forKey: "SplatFlags")
}

func removeArchivedFlag(flags: NSArray!, oID: String) {
    var newFlags = NSMutableArray(array: flags)
    newFlags.removeObject(oID)
    NSUserDefaults.standardUserDefaults().setObject(newFlags, forKey: "SplatFlags")
}


//functions used for saving things in the user defaults
func archiveDownvoteReply(oID: String, downvotes: NSArray!) {
    var newDownvotes:NSMutableArray
    if (downvotes == nil) {
        newDownvotes = NSMutableArray()
    } else {
        newDownvotes = NSMutableArray(array: downvotes)
    }
    newDownvotes.addObject(oID)
    NSUserDefaults.standardUserDefaults().setObject(newDownvotes, forKey: "SplatReplyDownvotes")
}

func archiveUpvoteReply(oID: String, upvotes: NSArray!) {
    var newUpvotes:NSMutableArray
    if (upvotes == nil) {
        newUpvotes = NSMutableArray()
    } else {
        newUpvotes = NSMutableArray(array: upvotes)
    }
    newUpvotes.addObject(oID)
    NSUserDefaults.standardUserDefaults().setObject(newUpvotes, forKey: "SplatReplyUpvotes")
}

func removeArchivedDownvoteReply(oID: String, downvotes: NSArray!) {
    var newDownvotes = NSMutableArray(array: downvotes)
    newDownvotes.removeObject(oID)
    NSUserDefaults.standardUserDefaults().setObject(newDownvotes, forKey: "SplatReplyDownvotes")
}

func removeArchivedUpvoteReply(oID: String, upvotes: NSArray!) {
    var newUpvotes = NSMutableArray(array: upvotes)
    newUpvotes.removeObject(oID)
    NSUserDefaults.standardUserDefaults().setObject(newUpvotes, forKey: "SplatReplyUpvotes")
}

