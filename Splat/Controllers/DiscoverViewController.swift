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
import FBSDKShareKit

class DiscoverViewController: UIViewController, UIScrollViewDelegate, FBSDKSharingDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, CaretSelectorDelegate, UIActionSheetDelegate, UIAlertViewDelegate {
    
    var statusBarStyle = UIStatusBarStyle.LightContent
    
    //score weighting
    let postScoreWeighting = 2
    let replyScoreWeighting = 1
    
    //Main views
    var mainScrollView: UIScrollView!
    var gradient: CAGradientLayer!
    
    //Navigation
    var shareButton: UIButton!
    var notificationsButton: UIButton!
    var notificationsBadge: NotificationBadge!
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
    
    var myButton: StatsButton!
    var ratedButton: StatsButton!
    
    var collectionView:UICollectionView!
    var currentData = NSMutableArray()
    var currentSelection = ProfileSelection.MyPosts
    
    var screen = CurrentScreen.Score
    
    var shareActionSheet: UIActionSheet!
    
    enum ProfileSelection {
        case MyPosts
        case MyReplies
        case RatedPosts
        case RatedReplies
    }
    
    enum CurrentScreen {
        case Score
        case Profile
    }
    
    class StatsButton: UIButton {
        
        var labelName = ""
        private(set) var isFocused = false
        
        private var myNumPostsLabel: UILabel!
        private var myNumRepliesLabel: UILabel!
        private var myLabel: UILabel!
        
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override func didMoveToSuperview() {
            self.backgroundColor = UIColor.clearColor()
            self.layer.cornerRadius = 5
            var screenWidth:CGFloat = 320
            var subviewWidth: CGFloat = self.frame.width/3
            if let sView = self.superview {
                screenWidth = sView.frame.width
            }
            
            if screenWidth == 320 {
                myLabel = UILabel(frame: CGRect(x: 0, y: 0, width: subviewWidth, height: self.frame.height))
                myLabel.font = UIFont(name: "Pacifico", size: 14.0)
            } else {
                myLabel = UILabel(frame: CGRect(x: 0, y: 0, width: subviewWidth, height: self.frame.height))
                myLabel.font = UIFont(name: "Pacifico", size: 16.0)
            }
            
            myLabel.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
            myLabel.textAlignment = NSTextAlignment.Center
            myLabel.text = labelName
            
            var myPostsLabel:UILabel!
            
            if screenWidth == 320 {
                myPostsLabel = UILabel(frame: CGRect(x: myLabel.frame.maxX, y: myLabel.center.y, width: subviewWidth, height: self.frame.height/2))
                myPostsLabel.font = UIFont.systemFontOfSize(12)
            } else {
                myPostsLabel = UILabel(frame: CGRect(x: myLabel.frame.maxX, y: myLabel.center.y, width: subviewWidth, height: self.frame.height/2))
                myPostsLabel.font = UIFont.systemFontOfSize(14)
            }
            
            myPostsLabel.text = "Posts"
            myPostsLabel.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
            myPostsLabel.textAlignment = NSTextAlignment.Center
            
            if screenWidth == 320 {
                myNumPostsLabel = UILabel(frame: CGRect(x: myLabel.frame.maxX, y: myLabel.frame.origin.y, width: subviewWidth, height: self.frame.height/2))
                myNumPostsLabel.font = UIFont.boldSystemFontOfSize(14)
            } else {
                myNumPostsLabel = UILabel(frame: CGRect(x: myLabel.frame.maxX, y: myLabel.frame.origin.y, width: subviewWidth, height: self.frame.height/2))
                myNumPostsLabel.font = UIFont.boldSystemFontOfSize(16)
            }
            myNumPostsLabel.text = "\(5)"
            myNumPostsLabel.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
            
            myNumPostsLabel.textAlignment = NSTextAlignment.Center
            
            //Add line to break
            var path = UIBezierPath()
            path.moveToPoint(CGPointMake(myNumPostsLabel.frame.minX + 5, myNumPostsLabel.frame.maxY))
            path.addLineToPoint(CGPointMake(myNumPostsLabel.frame.maxX - 5, myNumPostsLabel.frame.maxY))
            
            //create shape from path
            var shapeLayer = CAShapeLayer()
            shapeLayer.path = path.CGPath
            shapeLayer.strokeColor = UIColor.whiteColor().colorWithAlphaComponent(0.5).CGColor
            shapeLayer.lineWidth = 0.5
            shapeLayer.fillColor = UIColor.clearColor().CGColor
            
            var myRepliesLabel: UILabel!
            
            if screenWidth == 320 {
                myRepliesLabel = UILabel(frame: CGRect(x: myPostsLabel.frame.maxX, y: myLabel.center.y, width: subviewWidth, height: self.frame.height/2))
                myRepliesLabel.font = UIFont.systemFontOfSize(12)
            } else {
                myRepliesLabel = UILabel(frame: CGRect(x: myPostsLabel.frame.maxX, y: myLabel.center.y, width: subviewWidth, height: self.frame.height/2))
                myRepliesLabel.font = UIFont.systemFontOfSize(14)
            }
            
            myRepliesLabel.text = "Replies"
            myRepliesLabel.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
            myRepliesLabel.textAlignment = NSTextAlignment.Center
            
            
            if screenWidth == 320 {
                myNumRepliesLabel = UILabel(frame: CGRect(x: myPostsLabel.frame.maxX, y: myLabel.frame.origin.y, width: subviewWidth, height: self.frame.height/2))
                myNumRepliesLabel.font = UIFont.boldSystemFontOfSize(14)
            } else {
                myNumRepliesLabel = UILabel(frame: CGRect(x: myPostsLabel.frame.maxX, y: myLabel.frame.origin.y, width: subviewWidth, height: self.frame.height/2))
                myNumRepliesLabel.font = UIFont.boldSystemFontOfSize(16)
            }
            
            myNumRepliesLabel.text = "\(10)"
            myNumRepliesLabel.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
            myNumRepliesLabel.textAlignment = NSTextAlignment.Center
            
            //Add line to break
            var path2 = UIBezierPath()
            path2.moveToPoint(CGPointMake(myNumRepliesLabel.frame.minX + 5, myNumRepliesLabel.frame.maxY))
            path2.addLineToPoint(CGPointMake(myNumRepliesLabel.frame.maxX - 5, myNumRepliesLabel.frame.maxY))
            
            //create shape from path
            var shapeLayer2 = CAShapeLayer()
            shapeLayer2.path = path2.CGPath
            shapeLayer2.strokeColor = UIColor.whiteColor().colorWithAlphaComponent(0.5).CGColor
            shapeLayer2.lineWidth = 0.5
            shapeLayer2.fillColor = UIColor.clearColor().CGColor
            
            self.addSubview(myLabel)
            self.addSubview(myPostsLabel)
            self.layer.addSublayer(shapeLayer)
            self.addSubview(myNumPostsLabel)
            self.addSubview(myRepliesLabel)
            self.layer.addSublayer(shapeLayer2)
            self.addSubview(myNumRepliesLabel)
        }
        
        func focus() {
            isFocused = true
            self.backgroundColor = UIColorFromRGB(DARK_PURPLE)
            myLabel.textColor = UIColor.whiteColor()
            myNumPostsLabel.textColor = UIColor.whiteColor()
            myNumRepliesLabel.textColor = UIColor.whiteColor()
        }
        
        func removeFocus() {
            isFocused = false
            self.backgroundColor = UIColor.clearColor()
            myLabel.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
            myNumPostsLabel.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
            myNumRepliesLabel.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        }
        
        func setPosts(num: Int) {
            myNumPostsLabel.text = "\(num)"
        }
        
        func setReplies(num: Int) {
            myNumRepliesLabel.text = "\(num)"
        }
        
    }
        
    init() {
        super.init(nibName: nil, bundle: nil)
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
        
        if (notificationsBadge == nil && notificationsButton != nil) {
            //get number of notifications
            notificationsBadge = NotificationBadge(number: Notification.getNumberOfNewNotifications())
            notificationsButton.addSubview(notificationsBadge)
        }
    
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if (shareActionSheet != nil) {
            shareActionSheet.dismissWithClickedButtonIndex(shareActionSheet.cancelButtonIndex, animated: false)
        }
        
        self.notificationsBadge.removeFromSuperview()
        self.notificationsBadge = nil
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
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
        
        //SHARE BUTTON
        shareButton = UIButton(frame: CGRectMake(20, 10, 40, 40))
        shareButton.setImage(UIImage(named: "shareIcon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        shareButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        shareButton.tintColor = UIColor.whiteColor()
        shareButton.addTarget(self, action: "shareButtonListener:", forControlEvents: UIControlEvents.TouchUpInside)
        
        //NOTIFICATIONS BUTTON
        notificationsButton = UIButton(frame: CGRectMake(self.view.frame.width-60, 10, 40, 40))
        notificationsButton.setImage(UIImage(named: "notificationsIcon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        notificationsButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        notificationsButton.tintColor = UIColor.whiteColor()
        notificationsButton.addTarget(self, action: "notificationsButtonListener:", forControlEvents: UIControlEvents.TouchUpInside)
        
        //get number of notifications
        notificationsBadge = NotificationBadge(number: Notification.getNumberOfNewNotifications())
        notificationsButton.addSubview(notificationsBadge)
        
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

        //get the score and add it
        getUserScore()
        
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
        mainScrollView.addSubview(notificationsButton)
        mainScrollView.addSubview(shareButton)
        mainScrollView.addSubview(circleView)
        mainScrollView.addSubview(caretButton)
        //mainScrollView.addSubview(caretButtonUp)
        
        //set gradients for background
       // mainScrollView.layer.insertSublayer(gradient, atIndex: 0)
        
        //add the main views
        self.view.addSubview(mainScrollView)
    }
    
    func getUserScore() {
        //GET USER DATA
        var user = User()
        var posts = NSMutableArray()
        var score = 0;
        userPosts = NSMutableArray()
        currentUser = user
        
        if (currentUser.getPosts() != nil) {
            if let arr = currentUser.getPosts() {
                posts = NSMutableArray(array: arr)
            }
            
            for var i = 0; i < posts.count; i++ {
                if let post = posts[i] as? PFObject {
                    if let oid = post.objectId {
                        posts[i] = oid
                    }
                }
                
            }
            
            var query = PFQuery(className: "Post")
            query.whereKey("objectId", containedIn: posts as [AnyObject])
            query.orderByDescending("createdAt")
            //Get objects for the pointer data
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if (error != nil) {
                println(error)
            } else {
                if (objects == nil) {
                    println("No posts")
                } else {
                    if let objs = objects {
                        for obj in objs {
                            if let pfobj = obj as? PFObject {
                                var post = Post(pfObject: pfobj)
                                self.userPosts.addObject(post)
                                if post.getScore() != nil {
                                    score = self.postScoreWeighting*post.getScore() + score
                                }
                                
                            }
                        }
                        
                        self.currentData = self.userPosts
                        self.collectionView.reloadData()
                    }
                    
                }
                
                }
                
                if (user.getReplies() != nil) {
                    //add replies votes to splatScore
                    var replyOIDs = NSMutableArray()
                    if let arr = self.currentUser.getReplies() {
                        replyOIDs = NSMutableArray(array: arr)
                    }
                    
                    for var i = 0; i < replyOIDs.count; i++ {
                        if let reply = replyOIDs[i] as? PFObject {
                            if let oid = reply.objectId {
                                replyOIDs[i] = oid
                            }
                        }
                        
                    }
                    
                    var query = PFQuery(className: "Reply")
                    query.whereKey("objectId", containedIn: replyOIDs as [AnyObject])
                    //Get objects for the pointer data
                    query.findObjectsInBackgroundWithBlock({ (replies, error2) -> Void in
                        if (error2 != nil) {
                            println(error2)
                        } else {
                            if (objects == nil) {
                                println("No replies")
                            } else {
                                
                                if let objs = replies {
                                    for obj in objs {
                                        if let pfobj = obj as? PFObject {
                                            var reply = Reply(pfObject: pfobj)
                                            //self.userReplies.addObject(reply)
                                            if reply.getScore() != nil {
                                                score = self.replyScoreWeighting*reply.getScore() + score
                                            }
                                            
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
    }
    
    ///Adds the profile elements
    func renderProfile() {
        
        initGestureRecognizers()
        
        /** NEW PROFILE **/
        var statsCircle: UIView!
        if self.view.frame.width == 320 {
            statsCircle = UIView(frame: CGRect(x: 20, y: 0.6 * mainScrollView.contentSize.height + 20 + UIApplication.sharedApplication().statusBarFrame.height, width: 100, height: 100))
        } else {
            statsCircle = UIView(frame: CGRect(x: 20, y: 0.6 * mainScrollView.contentSize.height + 20 + UIApplication.sharedApplication().statusBarFrame.height, width: 120, height: 120))
        }
        statsCircle.backgroundColor = UIColorFromRGB(BACKGROUND_GREY)
        statsCircle.layer.cornerRadius = statsCircle.frame.width/2
        
        var statsLabel = UILabel(frame: statsCircle.frame)
        statsLabel.textColor = UIColorFromRGB(PURPLE_SELECTED)
        statsLabel.numberOfLines = 2
        if self.view.frame.width == 320 {
            statsLabel.font = UIFont(name: "Pacifico", size: 26.0)
        } else {
            statsLabel.font = UIFont(name: "Pacifico", size: 30.0)
        }
        statsLabel.text = "Stats"
        statsLabel.textAlignment = NSTextAlignment.Center
        statsLabel.frame.origin.x = -2
        statsLabel.frame.origin.y = 0
        
        statsCircle.addSubview(statsLabel)
        
        /** Begin My Button **/
        myButton = StatsButton(frame: CGRect(x: statsCircle.frame.maxX + 10, y: 0, width: self.view.frame.width - 20 - (statsCircle.frame.maxX + 10), height: 50))
        myButton.labelName = "My"
        myButton.center.y = statsCircle.frame.origin.y + statsCircle.frame.height/4
        mainScrollView.addSubview(myButton)
        
        //NUMBER POSTS BUTTON
        var totalPosts = 0
        if let countPosts = currentUser.getPosts()?.count {
            totalPosts = countPosts
        }
        
        //NUMBER REPLIES BUTTON
        var totalReplies = 0
        if let countReplies = currentUser.getReplies()?.count {
            totalReplies = countReplies
        }

        myButton.setPosts(totalPosts)
        myButton.setReplies(totalReplies)
        
        myButton.addTarget(self, action: "myButtonSelected:", forControlEvents: UIControlEvents.TouchUpInside)
        
        myButton.focus()
        /** End My Button **/
        
        /** Begin Rated Button **/
        ratedButton = StatsButton(frame: CGRect(x: statsCircle.frame.maxX + 10, y: 0, width: self.view.frame.width - 20 - (statsCircle.frame.maxX + 10), height: 50))
        ratedButton.labelName = "Rated"
        ratedButton.center.y = statsCircle.frame.origin.y + 3*statsCircle.frame.height/4
        mainScrollView.addSubview(ratedButton)
        
        //Get the total number of upvotes and downvotes
        var numUpvotes = 0
        var numDownvotes = 0
        
        if let upvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatUpvotes") as? NSArray {
            numUpvotes = upvotes.count
        }
        if let downvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatDownvotes") as? NSArray {
            numDownvotes = downvotes.count
        }

        ratedButton.setPosts(numUpvotes)
        
        //Get the total number of upvotes and downvotes
        numUpvotes = 0
        numDownvotes = 0
        
        if let upvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatReplyUpvotes") as? NSArray {
            numUpvotes = upvotes.count
        }
        if let downvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatReplyDownvotes") as? NSArray {
            numDownvotes = downvotes.count
        }

        ratedButton.setReplies(numUpvotes)
        ratedButton.addTarget(self, action: "ratedButtonSelected:", forControlEvents: UIControlEvents.TouchUpInside)
        /** End Rated Button **/
        
        var caretSelector:CaretSelectorBar!
        if self.view.frame.width == 320 {
            caretSelector = CaretSelectorBar(frame: CGRect(x: 0, y: statsCircle.frame.maxY + 10, width: mainScrollView.frame.width, height: 50), items: ["Posts", "Replies"])
             caretSelector.font = UIFont(name: "Pacifico", size: 16.0)
        } else {
            caretSelector = CaretSelectorBar(frame: CGRect(x: 0, y: statsCircle.frame.maxY + 10, width: mainScrollView.frame.width, height: 60), items: ["Posts", "Replies"])
            caretSelector.font = UIFont(name: "Pacifico", size: 18.0)
        }
        
        caretSelector.textPadding = 20
        caretSelector.caretSize = 10
        caretSelector.delegate = self

        
        var background = UIView(frame: CGRect(x: 0, y: caretSelector.frame.maxY - 10, width: self.view.frame.width, height: mainScrollView.contentSize.height-(caretSelector.frame.maxY - 10)))
        background.backgroundColor = UIColor.whiteColor()
        
        var flowLayout:UICollectionViewFlowLayout = UICollectionViewFlowLayout();
        
        collectionView = UICollectionView(frame: background.frame, collectionViewLayout: flowLayout)
        collectionView.registerClass(PostCollectionCell.self, forCellWithReuseIdentifier: "collectionCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.whiteColor()
        
        mainScrollView.addSubview(background)
        mainScrollView.addSubview(collectionView)
        mainScrollView.addSubview(caretSelector)
        mainScrollView.addSubview(statsCircle)
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
        if (screen == CurrentScreen.Score) {
            caretButtonListener(caretButton)
        }
    }
    
    func handleSwipeDownFrom(recognizer: UIGestureRecognizer) {
        if (screen == CurrentScreen.Profile) {
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
    func myButtonSelected(sender: UIButton) {
        myButton.focus()
        ratedButton.removeFocus()
        
        if (currentSelection == ProfileSelection.RatedPosts) {
            currentSelection = ProfileSelection.MyPosts
            updateCollection()
        } else if (currentSelection == ProfileSelection.RatedReplies) {
            currentSelection = ProfileSelection.MyReplies
            updateCollection()
        }
    }
    
    func ratedButtonSelected(sender: UIButton) {
        ratedButton.focus()
        myButton.removeFocus()
        
        if (currentSelection == ProfileSelection.MyPosts) {
            currentSelection = ProfileSelection.RatedPosts
            updateCollection()
        } else if (currentSelection == ProfileSelection.MyReplies) {
            currentSelection = ProfileSelection.RatedReplies
            updateCollection()
        }
    }
    
    //TODO:
    ///Shares on facebook
    func shareButtonListener(sender: UIButton) {
        println("Share SplatIt score here")
        shareActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
        shareActionSheet.addButtonWithTitle("Share on Facebook")
        
        shareActionSheet.actionSheetStyle = .Default
        shareActionSheet.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
            switch buttonIndex {
            case 0: //cancel
                break;
            case 1: //facebook
                shareOnFacebook()
                break;
            default:
                break
            }
    }

    
    func shareOnFacebook() {
        var scoreImage = getScreenshot(self)
        
        scoreImage = cropImage(scoreImage, CGRectMake(0, self.circleView.center.y + UIApplication.sharedApplication().statusBarFrame.height - self.view.frame.width/2, self.view.frame.width, self.view.frame.width))
        
        var fbimage = FBSDKSharePhoto()
        fbimage.image = scoreImage
        fbimage.userGenerated = true
        
        var content = FBSDKSharePhotoContent()
        content.photos = [fbimage]
        
        var shareDialog = FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: self)

    }
    
    //MARK: FBSharing
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        //do something
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        //do something
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        let alert = UIAlertView(title: "Share on facebook?", message: "Make sure that SplatIt can access the Facebook app to spread the word!", delegate: self, cancelButtonTitle: "Got it.")
        alert.show()
    }
    
    func notificationsButtonListener(sender: UIButton) {
        (self.navigationController as! RootNavViewController).popVC(.Left)
    }
    
    func caretButtonListener(sender: UIButton) {
        screen = CurrentScreen.Profile
        var bottomOffset = CGPointMake(0, self.mainScrollView.contentSize.height - self.mainScrollView.bounds.size.height);
        self.mainScrollView.setContentOffset(bottomOffset, animated: true)
        statusBarStyle = UIStatusBarStyle.LightContent
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func caretUpButtonListener(sender: UIButton) {
        screen = CurrentScreen.Score
        var bottomOffset = CGPointMake(0, -UIApplication.sharedApplication().statusBarFrame.height);
        self.mainScrollView.setContentOffset(bottomOffset, animated: true)
        statusBarStyle = UIStatusBarStyle.LightContent
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func ratedButtonListener() {
        
        //if there is not data, get it
        if (ratedPosts == nil) {
            //GET USER DATA
            var posts = NSUserDefaults.standardUserDefaults().objectForKey("SplatUpvotes") as? NSArray
            ratedPosts = NSMutableArray()
            
            if (posts != nil) {
                var query = PFQuery(className: "Post")
                query.whereKey("objectId", containedIn: posts as! [AnyObject])
                query.orderByDescending("createdAt")
                //Get objects for the pointer data
                query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                if (error != nil) {
                        println(error)
                    } else {
                        if (objects == nil) {
                            println("Can't find rated")
                        } else {
                            if let objs = objects {
                                for obj in objs {
                                    if let pfobj = obj as? PFObject {
                                        var post = Post(pfObject: pfobj)
                                        self.ratedPosts.addObject(post)
                                        
                                    }
                                }
                            }
                        }
                    
                       // self.ratedPosts = NSMutableArray(array: self.ratedPosts.reverseObjectEnumerator().allObjects)
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
        currentData = self.ratedPosts
        self.collectionView.reloadData()
        /*var ratedPostsVC = GenericPostsTableViewController(posts: ratedPosts, title: "Upvoted")
        self.navigationController?.pushViewController(ratedPostsVC, animated: true)*/
    }
    
    func postsButtonListener() {
        
        //if there is not data, get it
        if (userPosts == nil) {
            //GET USER DATA
            var posts = NSMutableArray()
            if let arr = currentUser.getPosts() {
                posts = NSMutableArray(array: arr)
            }
            
            for var i = 0; i < posts.count; i++ {
                if let post = posts[i] as? PFObject {
                    if let oid = post.objectId {
                        posts[i] = oid
                    }
                }
                
            }
            
            userPosts = NSMutableArray()
            var query = PFQuery(className: "Post")
            query.whereKey("objectId", containedIn: posts as [AnyObject])
            query.orderByDescending("createdAt")
            //Get objects for the pointer data
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if (error != nil) {
                    println(error)
                } else {
                    if (objects == nil) {
                        println("No posts")
                    } else {
                    
                        if let objs = objects {
                            for obj in objs {
                                if let pfobj = obj as? PFObject {
                                    var post = Post(pfObject: pfobj)
                                    self.userPosts.addObject(post)
                                    
                                }
                            }
                        }
                    }
                    
                    self.pushToPast()
                    
                }
                
            })
            
        //otherwise push the vc
        } else {
            pushToPast()
        }
    }
    
    private func pushToPast() {
        currentData = self.userPosts
        self.collectionView.reloadData()
       /* var pastPostsVC = GenericPostsTableViewController(posts: userPosts, title: "Past")
        self.navigationController?.pushViewController(pastPostsVC, animated: true) */
    }
    
    func ratedRepliesButtonListener() {
        
        //if there is not data, get it
        if (ratedReplies == nil) {
            //GET USER DATA
            var posts = NSUserDefaults.standardUserDefaults().objectForKey("SplatReplyUpvotes") as? NSArray
            ratedReplies = NSMutableArray()
            
            if (posts != nil) {
                var query = PFQuery(className: "Reply")
                query.whereKey("objectId", containedIn: posts as! [AnyObject])
                query.includeKey("parent")
                query.orderByDescending("createdAt")
                //Get objects for the pointer data
                query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                    if (error != nil) {
                        println(error)
                    } else {
                        if (objects == nil) {
                            println("Can't find rated")
                        } else {
                            if let objs = objects {
                                for obj in objs {
                                    if let pfobj = obj as? PFObject {
                                        var reply = Reply(pfObject: pfobj)
                                        if (reply.getParentPost() != nil) {
                                            self.ratedReplies.addObject(Post(pfObject: reply.getParentPost()))
                                        }
                                        
                                    }
                                }
                            }
                        }
                        
                        self.ratedReplies = self.removeDuplicates(self.ratedReplies)
                        self.pushToRatedReplies()

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
        currentData = self.ratedReplies
        self.collectionView.reloadData()
        /*var ratedRepliesVC = GenericPostsTableViewController(posts: ratedReplies, title: "Upvoted")
        self.navigationController?.pushViewController(ratedRepliesVC, animated: true) */
    }
    
    func repliesButtonListener() {
        
        //if there is not data, get it
        if (userReplies == nil) {
            var replies = NSMutableArray()
            if let arr = currentUser.getReplies() {
                replies = NSMutableArray(array: arr)
            }
            
            for var i = 0; i < replies.count; i++ {
                if let reply = replies[i] as? PFObject {
                    if let oid = reply.objectId {
                        replies[i] = oid
                    }
                }

            }
            
            userReplies = NSMutableArray()
            var query = PFQuery(className: "Reply")
            query.whereKey("objectId", containedIn: replies as [AnyObject])
            query.orderByDescending("createdAt")
            query.includeKey("parent")
            //Get objects for the pointer data
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if (error != nil) {
                    println(error)
                } else {
                    if (objects == nil) {
                        println("Can't find replies")
                    } else {
                        if let objs = objects {
                            for obj in objs {
                                if let pfobj = obj as? PFObject {
                                    var reply = Reply(pfObject: pfobj)
                                    if (reply.getParentPost() != nil) {
                                        self.userReplies.addObject(Post(pfObject: reply.getParentPost()))
                                    }
                                    
                                }
                            }
                        }
                    }
                    
                    self.userReplies = self.removeDuplicates(self.userReplies)
                    self.pushToUserReplies()

                }
                    
            })
                
        } else {
            pushToUserReplies()
        }
        
    }
    
    func pushToUserReplies() {
        currentData = self.userReplies
        self.collectionView.reloadData()
        /*
        var userRepliesVC = GenericPostsTableViewController(posts: userReplies, title: "Replies")
        self.navigationController?.pushViewController(userRepliesVC, animated: true) */
    }

    func highlightButton(sender: UIButton) {
        sender.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
    }
    
    private func removeDuplicates(arr: NSMutableArray) -> NSMutableArray {
        var addedObjects = NSMutableSet()
        var result = NSMutableArray()
        
        for obj in arr {
            if let post = obj as? Post {
                if (!addedObjects.containsObject(post.object.objectId!)) {
                    result.addObject(post)
                    addedObjects.addObject(post.object.objectId!)
                }
            }
        }
        
        return result;
    }
    
    //MARK: Collection View
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return currentData.count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var cell:PostCollectionCell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath) as! PostCollectionCell
        
        let post = currentData.objectAtIndex(indexPath.row) as! Post
        
        cell.initialize(post)
        
        return cell;
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        return CGSize(width: collectionView.frame.width/3-1, height: collectionView.frame.width/3-1)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 15)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let datasetCell = collectionView.cellForItemAtIndexPath(indexPath) as? PostCollectionCell {
            let postPreview = PostPreviewViewController(post: datasetCell.currentPost)
            self.navigationController?.pushViewController(postPreview, animated: true)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let postCell = cell as? PostCollectionCell {
            postCell.cancelLoad()
            postCell.imageView.image = nil
        }
    }

    //MARK: caret selector
    func caretSelectorBar(didSelectItem item: String?) {
        if let nonNilItem = item {

            if (nonNilItem == "Posts") {
                if (currentSelection == ProfileSelection.MyReplies) {
                    currentSelection = ProfileSelection.MyPosts
                    updateCollection()
                } else if (currentSelection == ProfileSelection.RatedReplies){
                    currentSelection = ProfileSelection.RatedPosts
                    updateCollection()
                }
            }
            else if (nonNilItem == "Replies") {
                if (currentSelection == ProfileSelection.MyPosts) {
                    currentSelection = ProfileSelection.MyReplies
                    updateCollection()
                } else if ((currentSelection == ProfileSelection.RatedPosts)){
                    currentSelection = ProfileSelection.RatedReplies
                    updateCollection()
                }
            } else {
                //do nothing
            }
        }
    }
    
    func updateCollection() {
        switch(currentSelection) {
            case .MyPosts:
                postsButtonListener()
                break
            case .MyReplies:
                repliesButtonListener()
                break
            case .RatedPosts:
                ratedButtonListener()
                break
            case .RatedReplies:
                ratedRepliesButtonListener()
                break
            default:
                break
        }
    }
}