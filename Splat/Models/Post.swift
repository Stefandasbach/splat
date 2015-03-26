//
//  Post.swift
//  Splat
//
//  Created by Aaron Tainter on 3/14/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//


//todo -> redo voting to do everything in the background. Im getting weird errors with deadlock
import Foundation
import Parse

class Post : NSObject {
    
    var object = PFObject(className: "Post")
    
    class func parseClassName() -> String! {
        return "Post"
    }
    
    override init() {
        super.init()
        
        if object.objectId == nil {
            object["creator"] = PFUser.currentUser()
        }
    }
    
    init(pfObject: PFObject) {
        if pfObject.parseClassName != "Post" {
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
    
    func setPicture(pngImage: NSData) {
        var file = PFFile(data: pngImage)
        object["pictureFile"] = file
    }
    
    func getEventPicture(completion: (imageData: NSData!) -> Void) {
        if object["pictureFile"] == nil {
            println("Post picture not present")
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
                    println("Added post")
                    completion(success: true)
                    self.addInverseRelationshipToCurrentUser(self.object)
                } else {
                    println("Could not create post")
                    completion(success: false)
                }
            } else {
                println(error)
            }
        })
    }
    
    private func addInverseRelationshipToCurrentUser(post: PFObject) -> Void {
        var user = PFUser.currentUser()
        user.addUniqueObject(post, forKey: "Posts")
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
                    println("Removed post")
                    completion(success: true)
                    self.removeInverseRelationshipToCurrentUser(self.object)
                } else {
                    println("Could not remove post")
                    completion(success: false)
                }
            } else {
                println(error)
            }
        })
        
    }
    
    private func removeInverseRelationshipToCurrentUser(post: PFObject) -> Void {
            
        var user = PFUser.currentUser()
        user.removeObject(post, forKey: "Posts")
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
    
    func setGeopoint(geopoint: PFGeoPoint) {
        object["geopoint"] = geopoint
    }
    
    func getGeopoint() -> PFGeoPoint! {
        return object["geopoint"] as PFGeoPoint!
    }

    func setState(state: String!) {
        object["state"] = state
    }
    
    func getState() -> String! {
        return object["state"] as String!
    }
    
    func setScore(score: Int) {
        object["score"] = score
    }
    
    func getScore() -> Int! {
        return object["score"] as Int!
    }
    
    func addUpvote() {
        

            object.incrementKey("score", byAmount: 1)
            object.saveInBackgroundWithBlock { (success, error) -> Void in
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
        
            object.incrementKey("score", byAmount: -1)
            object.saveInBackgroundWithBlock { (success, error) -> Void in
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
        
        object.incrementKey("score", byAmount: -1)
            object.saveInBackgroundWithBlock { (success, error) -> Void in
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
       
            
            object.incrementKey("score", byAmount: 1)
            object.saveInBackgroundWithBlock { (success, error) -> Void in
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
    
    func getFlags()->Int! {
        return object["flags"] as Int!
    }
    
    func setFlags(value: Int) {
        object["flags"] = value
    }
    
    func addFlag() {
        object.incrementKey("flags", byAmount: 1)
        object.saveInBackgroundWithBlock { (success, error) -> Void in
            if (error != nil) {
                println(error)
            }
            if (success) {
                println("Added Flag")
                self.object.fetchInBackgroundWithBlock { (object, error) -> Void in
                    //refresh
                }
            }
        }
    }
    
    func removeFlag() {
        object.incrementKey("flags", byAmount: -1)
        object.saveInBackgroundWithBlock { (success, error) -> Void in
            if (error != nil) {
                println(error)
            }
            if (success) {
                println("Removed Flag")
                self.object.fetchInBackgroundWithBlock { (object, error) -> Void in
                    //refresh
                }
            }
        }

    }
    
}