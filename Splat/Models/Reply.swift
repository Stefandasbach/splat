//
//  Comment.swift
//  Splat
//
//  Created by Aaron Tainter on 3/23/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

//TODO:
import Foundation
import Parse

class Reply : NSObject {
    
    var object = PFObject(className: "Reply")
    
    class func parseClassName() -> String! {
        return "Reply"
    }
    
    override init() {
        super.init()
        
        if object.objectId == nil {
            object["creator"] = PFUser.currentUser()
        }
    }
    
    init(pfObject: PFObject) {
        if pfObject.parseClassName != "Reply" {
            println("Not correct class type.")
        } else {
            object = pfObject
        }
    }
    
    func getObject() -> PFObject {
        return object
    }
    
    func getCreator()-> PFUser {
        return object["creator"] as PFUser
    }
    
    func setParentPost(post: PFObject) {
        object["parent"] = post
    }
    
    func getParentPost() -> PFObject! {
        return object["parent"] as PFObject!
    }
    
    func setPicture(pngImage: NSData) {
        var file = PFFile(data: pngImage)
        object["pictureFile"] = file
    }
    
    func getReplyPicture(completion: (imageData: NSData!) -> Void) {
        if object["pictureFile"] == nil {
            println("Reply picture not present")
            return
        }
        var file = object["pictureFile"] as PFFile!
        file.getDataInBackgroundWithBlock {
            (imageData: NSData!, error: NSError!) -> Void in
            if error == nil {
                completion(imageData: imageData)
            } else {
                println(error)
            }
        }
    }
    
    func cancelPictureGet() {
        if object["pictureFile"] == nil {
            println("Post picture not present")
            return
        }
        var file = object["pictureFile"] as PFFile!
        file.cancel()
    }
    
    func hasPicture() -> Bool {
        if object["pictureFile"] != nil {
            return true
        }
        return false
    }
    
    func setComment(comment: String!) {
        object["comment"] = comment
    }
    
    func getComment() -> String? {
        return object["comment"] as String?
    }
    
    func editComment(text: String, completion: ()->Void) {
        object.setObject(text, forKey: "comment")
        object.saveInBackgroundWithBlock { (success, error) -> Void in
            if (error != nil) {
                println(error)
            }
            if (success) {
                println("Edited Comment")
                self.object.fetchInBackgroundWithBlock { (object, error) -> Void in
                    //refresh
                }
                completion()
            }
        }
    }
    
    func saveObjectInBackground(completion: (success: Bool) -> Void) {
        object.saveInBackgroundWithBlock({
            (succeeded: Bool!, error: NSError!) -> Void in
            if(error == nil) {
                if (succeeded == true) {
                    completion(success: true)
                }
            } else {
                println(error)
                completion(success: false)
            }
        })
    }
    
    func saveObjectInBackgroundForCurrentUser(completion: (success: Bool) -> Void) {
        object.saveInBackgroundWithBlock({
            (succeeded: Bool!, error: NSError!) -> Void in
            if(error == nil) {
                if (succeeded == true) {
                    println("Added reply")
                    completion(success: true)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.addInverseRelationshipToCurrentUser(self.object)
                        self.addInverseRelationshipToPost()
                    })
                } else {
                    println("Could not create reply")
                    completion(success: false)
                }
            } else {
                println(error)
            }
        })
    }
    
    private func addInverseRelationshipToPost(){
        self.getParentPost().addUniqueObject(self.object.objectId, forKey: "replies")
        self.getParentPost().saveInBackground()
    }
    
    private func addInverseRelationshipToCurrentUser(reply: PFObject) -> Void {
        var user = PFUser.currentUser()
        user.addUniqueObject(reply, forKey: "Replies")
        user.saveInBackgroundWithBlock { (success, error) -> Void in
            if (error != nil) {
                println(error)
            }
            
            if success {
                println("Added relationship for user")
                
            } else {
                println("Saving eventually or relationship broken :/")
            }
        }
    }
    
    //still testing
    func deleteObjectInBackground(completion: (success: Bool) -> Void) {
        if (self.getCreator().objectId != PFUser.currentUser().objectId) {
            println("Error: cannot delete a post that is not yours.")
            return
        }
        
        object.deleteInBackgroundWithBlock({
            (succeeded: Bool!, error: NSError!) -> Void in
            if(error == nil) {
                if (succeeded == true) {
                    println("Removed reply")
                    completion(success: true)
                    self.removeInverseRelationshipToCurrentUser(self.object)
                } else {
                    println("Could not remove reply")
                    completion(success: false)
                }
            } else {
                println(error)
            }
        })
        
    }
    
    private func removeInverseRelationshipToCurrentUser(reply: PFObject) -> Void {
        
        var user = PFUser.currentUser()
        user.removeObject(reply, forKey: "Replies")
        user.saveInBackgroundWithBlock { (success, error) -> Void in
            if (error != nil) {
                println(error)
            }
            
            if success {
                println("Removed relationship for user")
                
            } else {
                println("Saving eventually or relationship broken :/")
            }
        }
        
    }
    
    func setScore(score: Int) {
        object["score"] = score
    }
    
    func getScore() -> Int! {
        return object["score"] as Int!
    }
    
    func addUpvote() {
        var pointer = PFObject(withoutDataWithClassName: "Reply", objectId: object.objectId)

        pointer.incrementKey("score", byAmount: 1)
        pointer.saveInBackgroundWithBlock { (success, error) -> Void in
            if (error != nil) {
                println(error)
            }
            if (success) {
                println("Added Upvote")
                self.object.fetchInBackgroundWithBlock { (object, error) -> Void in
                    //refresh
                }
            }
        }
        
    }
    
    func removeUpvote() {
        var pointer = PFObject(withoutDataWithClassName: "Reply", objectId: object.objectId)
        
        pointer.incrementKey("score", byAmount: -1)
        pointer.saveInBackgroundWithBlock { (success, error) -> Void in
            if (error != nil) {
                println(error)
            }
            if (success) {
                println("removed Upvote")
                self.object.fetchInBackgroundWithBlock { (object, error) -> Void in
                    //refresh
                }
                
            }
        }
        
        
    }
    
    
    
    func addDownvote() {
        var pointer = PFObject(withoutDataWithClassName: "Reply", objectId: object.objectId)
        
        pointer.incrementKey("score", byAmount: -1)
        pointer.saveInBackgroundWithBlock { (success, error) -> Void in
            if (error != nil) {
                println(error)
            }
            if (success) {
                println("Added Downvote")
                self.object.fetchInBackgroundWithBlock { (object, error) -> Void in
                    //refresh
                }
                
            }
            
        }
    }
    
    func removeDownvote() {
        var pointer = PFObject(withoutDataWithClassName: "Reply", objectId: object.objectId)
        
        pointer.incrementKey("score", byAmount: 1)
        pointer.saveInBackgroundWithBlock { (success, error) -> Void in
            if (error != nil) {
                println(error)
            }
            if (success) {
                println("Removed Downvote")
                self.object.fetchInBackgroundWithBlock { (object, error) -> Void in
                    //refresh
                }

            }
        }
    }
    
}

