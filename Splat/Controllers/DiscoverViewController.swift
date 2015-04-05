//
//  DiscoverViewController.swift
//  Splat
//
//  Created by Aaron Tainter on 3/20/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation
import UIKit
import Parse
import MapKit

class DiscoverViewController: UIViewController, UIScrollViewDelegate {
    
    var statusBarStyle = UIStatusBarStyle.LightContent
    
    //score weighting
    let postScoreWeighting = 2
    let replyScoreWeighting = 1
    
    //Main views
    var mainScrollView: UIScrollView!
    var gradient: CAGradientLayer!
    
    //Navigation
    var backButton: UIButton!
    var shareButton: UIButton!
    var caretButton:UIButton!
    var caretButtonUp:UIButton!
    
    //User score
    var circleView:UIView!
    var scoreLabel:UILabel!
    
    //Profile
    var currentUser: User!
    var userPosts: NSMutableArray!
    var userReplies: NSMutableArray!
    var ratedPosts:NSMutableArray!
    var ratedReplies:NSMutableArray!
    
    var numberPostsButton:UIButton!
    var numberRepliesButton: UIButton!
    var ratedPostsButton:UIButton!
    var ratedRepliesButton:UIButton!
    
    var map: MKMapView!
    
    var screen = "Score"
    
    override init() {
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        self.view.backgroundColor = UIColorFromRGB(PURPLE_SELECTED)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        renderElements()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        PFGeoPoint.geoPointForCurrentLocationInBackground { (geopoint, error) -> Void in
            if (error == nil){
                let location = CLLocationCoordinate2D(
                    latitude: geopoint.latitude,
                    longitude: geopoint.longitude
                )
                
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let region = MKCoordinateRegion(center: location, span: span)
                self.map.setRegion(region, animated: true)
                
               
                let annotation = MKPointAnnotation()
                annotation.setCoordinate(location)
                self.map.addAnnotation(annotation)
            }
        }
    }
    
    ///Adds the programmatic elements to the screen
    func renderElements() {
        //SCROLL VIEW used for transitioning
        mainScrollView = UIScrollView(frame: self.view.frame)
        mainScrollView.contentSize = CGSize(width: mainScrollView.frame.width, height: 2.5 * mainScrollView.frame.height)
        mainScrollView.delegate = self
        mainScrollView.scrollEnabled = false
        
        //ScrollviewGradient
        gradient = CAGradientLayer()
        gradient.colors = [UIColorFromRGB(PURPLE_SELECTED).CGColor, UIColorFromRGB(PURPLE_SELECTED).CGColor, UIColorFromRGB(BACKGROUND_GREY).CGColor]
        gradient.locations = [0, 0.4, 0.6]
        
        gradient.bounds = CGRectMake(0, 0,
            self.mainScrollView.contentSize.width,
            self.mainScrollView.contentSize.height);
        gradient.anchorPoint = CGPointZero;
        
        //BACK BUTTON
        backButton = UIButton(frame: CGRectMake(10, 10, 40, 40))
        backButton.setImage(UIImage(named: "backIcon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        backButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        backButton.tintColor = UIColor.whiteColor()
        backButton.addTarget(self, action: "backButtonListener:", forControlEvents: UIControlEvents.TouchUpInside)
        
        //SHARE BUTTON
        shareButton = UIButton(frame: CGRectMake(10, 10, 40, 40))
        shareButton.setImage(UIImage(named: "shareIcon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        shareButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        shareButton.tintColor = UIColor.whiteColor()
        shareButton.addTarget(self, action: "shareButtonListener:", forControlEvents: UIControlEvents.TouchUpInside)
        
        //MAIN SCORE VIEW
        circleView = UIView(frame: CGRectMake(self.mainScrollView.frame.width/8, self.view.frame.height/5, 3*self.mainScrollView.frame.width/4, 3*self.mainScrollView.frame.width/4))
        circleView.layer.cornerRadius = 3*self.mainScrollView.frame.width/8;
        circleView.backgroundColor = UIColorFromRGB(BACKGROUND_GREY)
        
        var splatScoreLabel = UILabel(frame: CGRectMake(0, 0, 100, 100))
        splatScoreLabel.textColor = UIColorFromRGB(PURPLE_SELECTED)
        splatScoreLabel.text = "SplatIt Score"
        splatScoreLabel.font = UIFont(name: "Pacifico", size: 30.0)
        splatScoreLabel.sizeToFit()
        splatScoreLabel.center = CGPoint(x: circleView.frame.width/2, y: 1*circleView.frame.height/3)
        
        circleView.addSubview(splatScoreLabel)
        
        
        //SETUP SCORE LABEL
        scoreLabel = UILabel(frame: CGRectMake(0, 0, 100, 100))
        scoreLabel.textColor = UIColorFromRGB(PURPLE_SELECTED)
        scoreLabel.font = UIFont.boldSystemFontOfSize(42)
        
        let oldScore = NSUserDefaults.standardUserDefaults().integerForKey("SplatScore")
            self.scoreLabel.text = "\(oldScore)"
            self.scoreLabel.sizeToFit()
            self.scoreLabel.center = CGPoint(x: self.circleView.frame.width/2, y: 2*self.circleView.frame.height/3 - 20)
        
        self.circleView.addSubview(self.scoreLabel)
        
        
        //GET USER DATA
        var user = User()
        var posts = user.getPosts()
        var score = 0;
        userPosts = NSMutableArray()
        currentUser = user
        
        if (posts != nil) {
            //Get objects for the pointer data to posts
            PFObject.fetchAllIfNeededInBackground(posts, block: { (objects, error) -> Void in
                if (error != nil) {
                    println(error)
                } else {
                    if (objects == nil) {
                        println("No posts")
                    } else {
                        for obj in objects {
                            if let pfobj = obj as? PFObject {
                                var post = Post(pfObject: pfobj)
                                self.userPosts.addObject(post)
                                if post.getScore() != nil {
                                    score = self.postScoreWeighting*post.getScore() + score
                                }
            
                            }
                        }
                        
                        self.userPosts = NSMutableArray(array: self.userPosts.reverseObjectEnumerator().allObjects)
                    }
                    
                }
                
                if (user.getReplies() != nil) {
                    //add replies votes to splatScore
                    PFObject.fetchAllIfNeededInBackground(user.getReplies(), block: { (replies, error2) -> Void in
                        if (error2 != nil) {
                            println(error2)
                        } else {
                            if (objects == nil) {
                                println("No replies")
                            } else {
                                
                                for obj in replies {
                                    if let pfobj = obj as? PFObject {
                                        var reply = Reply(pfObject: pfobj)
                                        //self.userReplies.addObject(reply)
                                        if reply.getScore() != nil {
                                            score = self.replyScoreWeighting*reply.getScore() + score
                                        }
                                        
                                    }
                                }
                                
                        
                                //self.userReplies = NSMutableArray(array: self.userReplies.reverseObjectEnumerator().allObjects)
                                
                            }
                        }
                        
                        //set score
                        dispatch_async(dispatch_get_main_queue(), {
                            NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "SplatScore")
                            self.scoreLabel.text = "\(score)"
                            self.scoreLabel.sizeToFit()
                            self.scoreLabel.center = CGPoint(x: self.circleView.frame.width/2, y: 2*self.circleView.frame.height/3 - 20)
                        })
                        
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "SplatScore")
                        self.scoreLabel.text = "\(score)"
                        self.scoreLabel.sizeToFit()
                        self.scoreLabel.center = CGPoint(x: self.circleView.frame.width/2, y: 2*self.circleView.frame.height/3 - 20)
                    })

                }

            })
        } else {
            NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "SplatScore")
            self.scoreLabel.text = "\(score)"
            self.scoreLabel.sizeToFit()
            self.scoreLabel.center = CGPoint(x: self.circleView.frame.width/2, y: 2*self.circleView.frame.height/3 - 20)
        }

        
        //Scrolls to the profile area
        caretButton = UIButton(frame: CGRectMake(7*self.mainScrollView.frame.width/16, self.view.frame.height-self.mainScrollView.frame.width/8-50, self.mainScrollView.frame.width/8, self.mainScrollView.frame.width/8))
        caretButton.setImage(UIImage(named: "caretImageFlipped.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        caretButton.tintColor = UIColorFromRGB(BACKGROUND_GREY)
        caretButton.addTarget(self, action: "caretButtonListener:", forControlEvents: UIControlEvents.TouchUpInside)
        
        //Scrolls back to the score area
        caretButtonUp = UIButton(frame: CGRectMake(7*self.mainScrollView.frame.width/16, 0.6 * mainScrollView.contentSize.height + 20, self.mainScrollView.frame.width/8, self.mainScrollView.frame.width/8))
        caretButtonUp.setImage(UIImage(named: "caretImage.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        caretButtonUp.tintColor = UIColorFromRGB(PURPLE_SELECTED)
        caretButtonUp.addTarget(self, action: "caretUpButtonListener:", forControlEvents: UIControlEvents.TouchUpInside)
        
        //creates a particle system for the splat score
        initParticles()
        
        //renders the elements for user profile
        renderProfile()
        
        //Add Subviews
        mainScrollView.addSubview(backButton)
        //mainScrollView.addSubview(shareButton)
        mainScrollView.addSubview(circleView)
        mainScrollView.addSubview(caretButton)
        mainScrollView.addSubview(caretButtonUp)
        
        //set gradients for background
        mainScrollView.layer.insertSublayer(gradient, atIndex: 0)
        
        //add the main views
        self.view.addSubview(mainScrollView)
    }
    
    ///Adds the profile elements
    func renderProfile() {
        
        //PROFILE SECTION LABEL
        var myProfileLabel = UILabel(frame: CGRectMake(10, 0.6 * mainScrollView.contentSize.height + 80, 100, 100))
        myProfileLabel.text = "My Profile"
        myProfileLabel.textColor = UIColorFromRGB(PURPLE_SELECTED)
        myProfileLabel.font = UIFont.systemFontOfSize(18)
        myProfileLabel.sizeToFit()
        
        //NUMBER POSTS BUTTON
        var totalPosts = 0
        if let countPosts = currentUser.getPosts()?.count {
            totalPosts = countPosts
        }
        
        numberPostsButton = ProfileButton(y: myProfileLabel.frame.maxY + 10, text: "Past posts", value: totalPosts)
        numberPostsButton.addTarget(self, action: "postsButtonListener:", forControlEvents: UIControlEvents.TouchUpInside)
        
        //NUMBER REPLIES BUTTON
        var totalReplies = 0
        if let countReplies = currentUser.getReplies()?.count {
            totalReplies = countReplies
        }
        
        numberRepliesButton = ProfileButton(y: numberPostsButton.frame.maxY - 1, text: "Past replies", value: totalReplies)
        numberRepliesButton.addTarget(self, action: "repliesButtonListener:", forControlEvents: UIControlEvents.TouchUpInside)

        
        //Get the total number of upvotes and downvotes
        var numUpvotes = 0
        var numDownvotes = 0
        
        if let upvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatUpvotes") as? NSArray {
            numUpvotes = upvotes.count
        }
        if let downvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatDownvotes") as? NSArray {
            numDownvotes = downvotes.count
        }

        //RATED POSTS BUTTON
        ratedPostsButton = ProfileButton(y: numberRepliesButton.frame.maxY - 1, text: "Upvoted posts", value: (numUpvotes))
        ratedPostsButton.addTarget(self, action: "ratedButtonListener:", forControlEvents: UIControlEvents.TouchUpInside)
        
        //Get the total number of upvotes and downvotes
        numUpvotes = 0
        numDownvotes = 0
        
        if let upvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatReplyUpvotes") as? NSArray {
            numUpvotes = upvotes.count
        }
        if let downvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatReplyDownvotes") as? NSArray {
            numDownvotes = downvotes.count
        }
        
        //RATED REPLIES BUTTON
        ratedRepliesButton = ProfileButton(y: ratedPostsButton.frame.maxY - 1, text: "Upvoted replies", value: (numUpvotes))
        ratedRepliesButton.addTarget(self, action: "ratedRepliesButtonListener:", forControlEvents: UIControlEvents.TouchUpInside)

        
        //PROFILE SECTION LABEL
        var myLocationLabel = UILabel(frame: CGRectMake(10, ratedRepliesButton.frame.maxY + 20, 100, 100))
        myLocationLabel.text = "My Location"
        myLocationLabel.textColor = UIColorFromRGB(PURPLE_SELECTED)
        myLocationLabel.font = UIFont.systemFontOfSize(16)
        myLocationLabel.sizeToFit()
        
        //ADD MAP
        map = MKMapView(frame: CGRect(x: 0, y: myLocationLabel.frame.maxY + 10, width: self.view.frame.width, height: mainScrollView.contentSize.height-(myLocationLabel.frame.maxY + 25)))
        map.scrollEnabled = false
        map.zoomEnabled = false
        
        initGestureRecognizers()
        
        //Add the elements
        mainScrollView.addSubview(myProfileLabel)
        mainScrollView.addSubview(numberPostsButton)
        mainScrollView.addSubview(numberRepliesButton)
        mainScrollView.addSubview(ratedPostsButton)
        mainScrollView.addSubview(ratedRepliesButton)
        mainScrollView.addSubview(myLocationLabel)
        mainScrollView.addSubview(map)
    }
    
    func initGestureRecognizers() {
        var swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipeUpFrom:")
        swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Up
        
        mainScrollView.addGestureRecognizer(swipeUpGestureRecognizer)
        
        var swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipeDownFrom:")
        swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        
        mainScrollView.addGestureRecognizer(swipeDownGestureRecognizer)
    }
    
    //Gesture Recognizers
    func handleSwipeUpFrom(recognizer: UIGestureRecognizer) {
        if (screen == "Score") {
            caretButtonListener(caretButton)
        }
    }
    
    func handleSwipeDownFrom(recognizer: UIGestureRecognizer) {
        if (screen == "Profile") {
            caretUpButtonListener(caretButtonUp)
        }
    }

    
    func initParticles() {
        //Create our particle image from a cg context
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(20,20), false, 1)
        let con = UIGraphicsGetCurrentContext()
        CGContextAddEllipseInRect(con, CGRectMake(0,0,20,20))
        CGContextSetFillColorWithColor(con, UIColor.whiteColor().CGColor)
        CGContextFillPath(con)
        let im = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Create a particle cell
        let cell = CAEmitterCell()
        cell.birthRate = 5
        cell.lifetime = 10
        cell.velocity = 50
        cell.velocityRange = 50
        cell.contents = im.CGImage
        cell.alphaSpeed = -0.1
        cell.alphaRange = -0.3
        cell.scaleRange = -1
        
        //create the emmiter
        let emit = CAEmitterLayer()
        emit.emitterPosition = CGPointMake(30,100)
        emit.emitterShape = kCAEmitterLayerPoint
        emit.emitterMode = kCAEmitterLayerPoints
        
        //add the particles
        emit.emitterCells = [cell]
        mainScrollView.layer.addSublayer(emit)
        
        //set the emitter postition and size
        emit.emitterPosition = CGPointMake(0,self.view.frame.height + 50)
        emit.emitterSize = CGSizeMake(2*self.view.frame.size.width,1)
        emit.emitterShape = kCAEmitterLayerLine
        emit.emitterMode = kCAEmitterLayerAdditive
        cell.emissionLongitude = 4*CGFloat(M_PI)/2
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return statusBarStyle
    }
    
    //** BUTTON LISTENERS **//
    func backButtonListener(sender: UIButton) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.popViewControllerAnimated(true)
       
    }
    
    //TODO:
    func shareButtonListener(sender: UIButton) {
        println("Share SplatIt score here")
    }
    
    func caretButtonListener(sender: UIButton) {
        screen = "Profile"
        var bottomOffset = CGPointMake(0, self.mainScrollView.contentSize.height - self.mainScrollView.bounds.size.height);
        self.mainScrollView.setContentOffset(bottomOffset, animated: true)
        statusBarStyle = UIStatusBarStyle.Default
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func caretUpButtonListener(sender: UIButton) {
        screen = "Score"
        var bottomOffset = CGPointMake(0, -UIApplication.sharedApplication().statusBarFrame.height);
        self.mainScrollView.setContentOffset(bottomOffset, animated: true)
        statusBarStyle = UIStatusBarStyle.LightContent
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func ratedButtonListener(sender: UIButton) {
        sender.backgroundColor = UIColor.whiteColor()
        
        //if there is not data, get it
        if (ratedPosts == nil) {
            //GET USER DATA
            var posts = NSUserDefaults.standardUserDefaults().objectForKey("SplatUpvotes") as? NSArray
            ratedPosts = NSMutableArray()
            
            if (posts != nil) {
                var query = PFQuery(className: "Post")
                query.whereKey("objectId", containedIn: posts)
                //Get objects for the pointer data
                query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                if (error != nil) {
                        println(error)
                    } else {
                        if (objects == nil) {
                            println("Can't find rated")
                        } else {
                            for obj in objects {
                                if let pfobj = obj as? PFObject {
                                    var post = Post(pfObject: pfobj)
                                    self.ratedPosts.addObject(post)
                                    
                                }
                            }
                        }
                    
                        self.ratedPosts = NSMutableArray(array: self.ratedPosts.reverseObjectEnumerator().allObjects)
                    
                        self.pushToRated()
                    }
                    
                }
            } else {
                println("No rated")
                pushToRated()
            }

        } else {
           pushToRated()
        }
    }
    
    private func pushToRated() {
        var ratedPostsVC = GenericPostsTableViewController(posts: ratedPosts, title: "Upvoted")
        self.navigationController?.pushViewController(ratedPostsVC, animated: true)
    }
    
    func postsButtonListener(sender: UIButton) {
        sender.backgroundColor = UIColor.whiteColor()
        
        //if there is not data, get it
        if (userPosts == nil) {
            //GET USER DATA
            var posts = currentUser.getPosts()
            userPosts = NSMutableArray()
            
            //Get objects for the pointer data
            PFObject.fetchAllIfNeededInBackground(posts, block: { (objects, error) -> Void in
                if (error != nil) {
                    println(error)
                } else {
                    if (objects == nil) {
                        println("No posts")
                    } else {
                    
                        for obj in objects {
                            if let pfobj = obj as? PFObject {
                                var post = Post(pfObject: pfobj)
                                self.userPosts.addObject(post)
                                
                            }
                        }
                    }
                    
                    self.userPosts = NSMutableArray(array: self.userPosts.reverseObjectEnumerator().allObjects)
                    
                    self.pushToPast()
                    
                }
                
            })
            
        //otherwise push the vc
        } else {
            pushToPast()
        }
    }
    
    private func pushToPast() {
        var pastPostsVC = GenericPostsTableViewController(posts: userPosts, title: "Past")
        self.navigationController?.pushViewController(pastPostsVC, animated: true)
    }
    
    func ratedRepliesButtonListener(sender: UIButton) {
        sender.backgroundColor = UIColor.whiteColor()
        
        //if there is not data, get it
        if (ratedReplies == nil) {
            //GET USER DATA
            var posts = NSUserDefaults.standardUserDefaults().objectForKey("SplatReplyUpvotes") as? NSArray
            ratedReplies = NSMutableArray()
            
            if (posts != nil) {
                var query = PFQuery(className: "Reply")
                query.whereKey("objectId", containedIn: posts)
                //Get objects for the pointer data
                query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                    if (error != nil) {
                        println(error)
                    } else {
                        if (objects == nil) {
                            println("Can't find rated")
                        } else {
                            for obj in objects {
                                if let pfobj = obj as? PFObject {
                                    var reply = Reply(pfObject: pfobj)
                                    if (reply.getParentPost() != nil) {
                                        self.ratedReplies.addObject(reply.getParentPost())
                                    }
                                    
                                }
                            }
                        }
                        
                        self.ratedReplies = NSMutableArray(array: self.ratedReplies.reverseObjectEnumerator().allObjects)
                        
                        PFObject.fetchAllIfNeededInBackground(self.ratedReplies, block: { (objects, error) -> Void in
                            self.ratedReplies.removeAllObjects()
                            
                            for obj in objects {
                                if let pfobj = obj as? PFObject {
                                    self.ratedReplies.addObject(Post(pfObject: pfobj))
                                }
                            }
                            
                            self.ratedReplies = self.removeDuplicates(self.ratedReplies)
                            self.pushToRatedReplies()
                        })
                        

                    }
                    
                }
            } else {
                println("No rated")
                pushToRatedReplies()
            }
            
        } else {
            pushToRatedReplies()
        }

    }
    
    func pushToRatedReplies() {
        var ratedRepliesVC = GenericPostsTableViewController(posts: ratedReplies, title: "Upvoted")
        self.navigationController?.pushViewController(ratedRepliesVC, animated: true)
    }
    
    func repliesButtonListener(sender: UIButton) {
        sender.backgroundColor = UIColor.whiteColor()
        
        //if there is not data, get it
        if (userReplies == nil) {
            //GET USER DATA
            var replies = currentUser.getReplies()
            userReplies = NSMutableArray()
            
            //Get objects for the pointer data
            PFObject.fetchAllIfNeededInBackground(replies, block: { (objects, error) -> Void in

                if (error != nil) {
                    println(error)
                } else {
                    if (objects == nil) {
                        println("Can't find replies")
                    } else {
                        for obj in objects {
                            if let pfobj = obj as? PFObject {
                                var reply = Reply(pfObject: pfobj)
                                if (reply.getParentPost() != nil) {
                                    self.userReplies.addObject(reply.getParentPost())
                                }
                                
                            }
                        }
                    }
                    
                    self.userReplies = NSMutableArray(array: self.userReplies.reverseObjectEnumerator().allObjects)
                    
                    PFObject.fetchAllIfNeededInBackground(self.userReplies, block: { (objects, error) -> Void in
                        self.userReplies.removeAllObjects()
                        
                        for obj in objects {
                            if let pfobj = obj as? PFObject {
                                self.userReplies.addObject(Post(pfObject: pfobj))
                            }
                        }
                        
                        self.userReplies = self.removeDuplicates(self.userReplies)
                        self.pushToUserReplies()
                    })
                    

                }
                    
            })
                
        } else {
            pushToUserReplies()
        }
        
    }
    
    func pushToUserReplies() {
        var userRepliesVC = GenericPostsTableViewController(posts: userReplies, title: "Replies")
        self.navigationController?.pushViewController(userRepliesVC, animated: true)
    }

    func highlightButton(sender: UIButton) {
        sender.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
    }
    
    private func removeDuplicates(arr: NSMutableArray) -> NSMutableArray {
        var addedObjects = NSMutableSet()
        var result = NSMutableArray()
        
        for obj in arr {
            if let post = obj as? Post {
                if (!addedObjects.containsObject(post.object.objectId)) {
                    result.addObject(post)
                    addedObjects.addObject(post.object.objectId)
                }
            }
        }
        
        return result;
    }

}