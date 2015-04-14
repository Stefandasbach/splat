//
//  feedViewController.swift
//  Splat
//
//  Created by Aaron Tainter on 3/14/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation
import Parse

class FeedViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let dataLimit = 20;
    let dataMaxLoadLimit = 100;
    let dataDistance = 5.0;
    let maxDaysHot = 7;
    
    var NewButton:UIButton!
    var HotButton:UIButton!
    var BestButton:UIButton!
    
    var LocationBar: UIToolbar!
    var LocationButton: UIButton!
    var locationPicker: UIPickerView!
    var selectButton: UIButton!
    
    var selected: String!
    var feedData = NSMutableArray()
    
    var selectedLocation = ""
    var currentSelection = ""
    var userLocation: String!
    
    var backgroundImage: UIImageView!
    var footerView: UIView!
    
    var notificationsBadge: NotificationBadge!
    var notificationsButton: UIButton!
    
    init() {
        super.init(style: .Plain)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        initNotifications()
    }
    
    func initNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNotification:", name: "DoneAddingPost", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNotification:", name: "RemovedPost", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNotification:", name: "RefreshFeed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNotification:", name: "ReloadFeed", object: nil)
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (notificationsBadge == nil && notificationsButton != nil) {
            //get number of notifications
            notificationsBadge = NotificationBadge(number: Notification.getNumberOfNewNotifications())
            notificationsButton.addSubview(notificationsBadge)
        }
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.notificationsBadge.removeFromSuperview()
        self.notificationsBadge = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let loc = NSUserDefaults.standardUserDefaults().objectForKey("SelectedLocation") as? String {
            selectedLocation = loc
        } else {
            selectedLocation = ""
        }
        
        /* Get user's location */
        let defaults = NSUserDefaults.standardUserDefaults()
        var state = defaults.objectForKey("state") as? String
        /* === Uncomment for simulator === */
//        state = "CO"
        /* === Uncomment for simulator === */
        if (state != nil) {
            userLocation = state!
            currentSelection = userLocation
        }
        
        self.renderNavbarandView()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: Selector("refreshFeed"), forControlEvents: UIControlEvents.ValueChanged)
        
        backgroundImage = UIImageView(image: UIImage(named: "feedPlaceholder.png"))
        backgroundImage.frame = self.tableView.frame
        backgroundImage.contentMode = UIViewContentMode.ScaleAspectFit
        
        self.tableView.backgroundColor = UIColorFromRGB(BACKGROUND_GREY)
       // self.tableView.tableFooterView = UIView()
        
        self.selected = "New"
        refreshFeed()
    }
    
    
    //MARK: Initialize
    func renderNavbarandView() {
        self.navigationController?.navigationBar.translucent = false
        //NAV ICONS//
        var newItemImageButton = UIButton(frame: CGRectMake(0, 0, 40, 40))
        newItemImageButton.setImage(UIImage(named: "createPostIcon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        newItemImageButton.tintColor = UIColor.whiteColor()
        newItemImageButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        newItemImageButton.addTarget(self, action: Selector("createButtonListener:"), forControlEvents: UIControlEvents.TouchUpInside)
        var newItemNavItem = UIBarButtonItem(customView: newItemImageButton)

        notificationsButton = UIButton(frame: CGRectMake(0, 0, 40, 40))
        notificationsButton.setImage(UIImage(named: "notificationsIcon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        notificationsButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        notificationsButton.tintColor = UIColor.whiteColor()
        notificationsButton.addTarget(self, action: "notificationsButtonListener:", forControlEvents: UIControlEvents.TouchUpInside)
        var notificationsNavItem = UIBarButtonItem(customView: notificationsButton)
        //get number of notifications
        
        notificationsBadge = NotificationBadge(number: Notification.getNumberOfNewNotifications())
        notificationsButton.addSubview(notificationsBadge)
        
        self.navigationItem.leftBarButtonItem = notificationsNavItem
        self.navigationItem.rightBarButtonItem = newItemNavItem
        
        let navBarHeight:CGFloat = 40.0
        let navBarWidth = self.view.frame.width
        LocationBar = UIToolbar(frame: CGRectMake(0, 0, navBarWidth, navBarHeight))
        LocationBar.barTintColor = UIColorFromRGB(PURPLE_SELECTED)
        
        locationPicker = UIPickerView(frame: CGRectMake(0, self.view.frame.height-20-200, self.view.frame.width, 200))
        locationPicker.delegate = self
        locationPicker.dataSource = self
        locationPicker.showsSelectionIndicator = true
        locationPicker.backgroundColor = UIColor.whiteColor()
        
        selectButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.height-20-240, width: self.view.frame.width, height: 40))
        selectButton.backgroundColor = UIColorFromRGB(PURPLE_SELECTED)
        selectButton.setTitle("Select Location", forState: UIControlState.Normal)
        selectButton.titleLabel?.textAlignment = NSTextAlignment.Center
        selectButton.addTarget(self, action: "selectLocation:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        //FEED BUTTONS//
        if let navBarHeight = self.navigationController?.navigationBar.frame.height {
            let navBarWidth = self.navigationController?.navigationBar.frame.width
            let buttonWidth: CGFloat = 65
            let buttonHeight = navBarHeight
            let buttonY = navBarHeight/2 - buttonHeight/2
            let buttonPadding = 10 as CGFloat
            let buttonPaddingTop = 5 as CGFloat
            let locationButtonPadding = (navBarWidth! - buttonWidth*3)/2
            
            LocationButton = UIButton()
            NewButton = UIButton()
            HotButton = UIButton()
            BestButton = UIButton()
            
            LocationButton.frame = CGRectMake(locationButtonPadding, 0, buttonWidth*3, buttonHeight)
            NewButton.frame      = CGRectMake(0*buttonWidth, 0, buttonWidth,   buttonHeight)
            HotButton.frame      = CGRectMake(1*buttonWidth, 0, buttonWidth,   buttonHeight)
            BestButton.frame     = CGRectMake(2*buttonWidth, 0, buttonWidth,   buttonHeight)
            
            //If there is no location
            if (userLocation == nil) {
                // TODO: Set default  location if foreigner
                LocationButton.setTitle( "My Location",  forState: .Normal)
                LocationButton.selected = false
                
            //If the location is not the user location
            } else if (selectedLocation != "" && selectedLocation != userLocation){
                LocationButton.setTitle( "\(selectedLocation)",  forState: .Normal)
                LocationButton.selected = true
                
            //If it is the user location
            } else {
                LocationButton.setTitle( "\(userLocation) (my location)",  forState: .Normal)
                selectedLocation = userLocation
                currentSelection = userLocation
                LocationButton.selected = false
            }
            
            LocationButton.titleLabel?.font = UIFont(name: "Helvetica", size: 18.0)
            LocationButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
            LocationButton.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.5), forState: UIControlState.Normal)
            
            NewButton.setTitle( "New",  forState: .Normal)
            NewButton.titleLabel?.font = UIFont(name: "Pacifico", size: 18.0)
            NewButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
            NewButton.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.5), forState: UIControlState.Normal)
            NewButton.selected = true
            
            HotButton.setTitle( "Hot",  forState: .Normal)
            HotButton.titleLabel?.font = UIFont(name: "Pacifico", size: 18.0)
            HotButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
            HotButton.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.5), forState: UIControlState.Normal)
            HotButton.selected = false
            
            BestButton.setTitle("Best", forState: .Normal)
            BestButton.titleLabel?.font = UIFont(name: "Pacifico", size: 18.0)
            BestButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
            BestButton.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.5), forState: UIControlState.Normal)
            BestButton.selected = false
            
            LocationButton.contentHorizontalAlignment  = UIControlContentHorizontalAlignment.Center
            LocationButton.contentVerticalAlignment    = UIControlContentVerticalAlignment.Center
            NewButton.contentHorizontalAlignment  = UIControlContentHorizontalAlignment.Center
            NewButton.contentVerticalAlignment    = UIControlContentVerticalAlignment.Center
            HotButton.contentHorizontalAlignment  = UIControlContentHorizontalAlignment.Center
            HotButton.contentVerticalAlignment    = UIControlContentVerticalAlignment.Center
            BestButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
            BestButton.contentVerticalAlignment   = UIControlContentVerticalAlignment.Center
            
            LocationButton.addTarget(self, action: "changeLocation:", forControlEvents: UIControlEvents.TouchUpInside)
            NewButton.addTarget(self, action: "changeSort:", forControlEvents: UIControlEvents.TouchUpInside)
            HotButton.addTarget(self, action: "changeSort:", forControlEvents: UIControlEvents.TouchUpInside)
            BestButton.addTarget(self, action: "changeSort:", forControlEvents: UIControlEvents.TouchUpInside)
            
            //Container for feed buttons
            let buttonContainer = ContainerView()
                buttonContainer.frame = CGRectMake(0, 0, NewButton.frame.width + HotButton.frame.width + BestButton.frame.width, buttonHeight)
                buttonContainer.addSubview(NewButton)
                buttonContainer.addSubview(HotButton)
                buttonContainer.addSubview(BestButton)
            self.navigationItem.titleView = buttonContainer
            self.LocationBar.addSubview(LocationButton)
        }
        
        var content = ContainerView()
        content.frame = LocationBar.frame
        content.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        content.addSubview(LocationBar)
        self.tableView.tableHeaderView = content
        
        
        footerView = UIView(frame: CGRectMake(0.0, 0.0, self.view.frame.width, 40.0))
        //footerView.backgroundColor = UIColor.blackColor()
        
        var actInd = UIActivityIndicatorView(activityIndicatorStyle:UIActivityIndicatorViewStyle.Gray)
        
        actInd.tag = 10;
        
        actInd.frame = CGRectMake(self.view.frame.width/2-20, 5.0, 20.0, 20.0);
        
        actInd.hidesWhenStopped = true;
        
        footerView.addSubview(actInd)
        
        self.tableView.tableFooterView = footerView
    }
    
    func createButtonListener(sender: UIButton) {
        (self.navigationController as! RootNavViewController).pushVC(.Left, viewController: CreatePostViewController())
    }
    
    func notificationsButtonListener(sender: UIButton) {
        
        var notificationsVC = NotificationsViewController()
        (self.navigationController as! RootNavViewController).pushVC(.Right, viewController: notificationsVC)
       
    }
    
    
    //MARK: Load data
    ///Gets the newest data in your area
    func loadNewData(skip: Int, limit: Int) {
        PFGeoPoint.geoPointForCurrentLocationInBackground { (geopoint, error) -> Void in
            if (error != nil) {
                println("Error: location services not enabled")
                self.feedData.removeAllObjects()
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                return
            }
            else {
                var query: PFQuery = PFQuery(className: "Post")
                query.limit = limit
                query.skip = skip
                
                if (self.selectedLocation == "My Location") {
                    if let geo = geopoint {
                        query.whereKey("geopoint", nearGeoPoint: geo, withinMiles: self.dataDistance)
                    }
                } else {
                    query.whereKey("state", equalTo: self.selectedLocation)
                }

                query.orderByDescending("createdAt")
                query.findObjectsInBackgroundWithBlock({
                    (objects, error)->Void in
                    
                    if (skip == 0) {
                        self.feedData.removeAllObjects()
                    }
                    
                    if (error != nil) {
                        println("Error: receiving data")
                        return
                        
                    }
                    
                    if let objs = objects {
                        for object in objs {
                            if let obj = object as? PFObject {
                                self.feedData.addObject(Post(pfObject: obj))
                            }
                        }
                    }
                    
                    self.toggleBackgroundImage()
                    
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                    if let av = self.footerView.viewWithTag(10) as? UIActivityIndicatorView {
                        av.stopAnimating()
                    }
                })
            }
        }

    }
    
    ///loads best scores for one week
    func loadHotData(skip:Int, limit: Int) {
        PFGeoPoint.geoPointForCurrentLocationInBackground { (geopoint, error) -> Void in
            if (error != nil) {
                println("Error: location services not enabled")
                self.feedData.removeAllObjects()
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                return
            }
            else {
                let calendar = NSCalendar.currentCalendar()
                let sevenDaysAgo = calendar.dateByAddingUnit(.CalendarUnitDay, value: -self.maxDaysHot, toDate: NSDate(), options: nil)
                
                var query: PFQuery = PFQuery(className: "Post")
                query.limit = limit
                query.skip = skip
                
                if (self.selectedLocation == "My Location") {
                    if let geo = geopoint {
                        query.whereKey("geopoint", nearGeoPoint: geo, withinMiles: self.dataDistance)
                    }
                } else {
                    query.whereKey("state", equalTo: self.selectedLocation)
                }
                
                query.orderByDescending("score")
                query.whereKey("createdAt", greaterThan: sevenDaysAgo!)
                query.findObjectsInBackgroundWithBlock({
                    (objects, error)->Void in
                    
                    if (skip == 0) {
                        self.feedData.removeAllObjects()
                    }
                    
                    if (error != nil) {
                        println("Error: receiving data")
                        return
                        
                    }
                    
                    if let objs = objects {
                        for object in objs {
                            if let obj = object as? PFObject {
                                self.feedData.addObject(Post(pfObject: obj))
                            }
                        }
                    }
                    
                    self.toggleBackgroundImage()
                    
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                    if let av = self.footerView.viewWithTag(10) as? UIActivityIndicatorView {
                        av.stopAnimating()
                    }
                })
            }
        }

    }
    
    ///loads the best scores for all time
    func loadBestData(skip: Int, limit: Int) {
        PFGeoPoint.geoPointForCurrentLocationInBackground { (geopoint, error) -> Void in
            if (error != nil) {
                println("Error: location services not enabled")
                self.feedData.removeAllObjects()
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                return
            }
            else {

                var query: PFQuery = PFQuery(className: "Post")
                query.limit = limit
                query.skip = skip
                
                if (self.selectedLocation == "My Location") {
                    if let geo = geopoint {
                        query.whereKey("geopoint", nearGeoPoint: geo, withinMiles: self.dataDistance)
                    }
                } else {
                    query.whereKey("state", equalTo: self.selectedLocation)
                }

                query.orderByDescending("score")
                query.findObjectsInBackgroundWithBlock({
                    (objects, error)->Void in
                    
                    if (skip == 0) {
                        self.feedData.removeAllObjects()
                    }
                    
                    if (error != nil) {
                        println("Error: receiving data")
                        return
                        
                    }
                    
                    if let objs = objects {
                        for object in objs {
                            if let obj = object as? PFObject {
                                self.feedData.addObject(Post(pfObject: obj))
                            }
                        }
                    }
                    
                    self.toggleBackgroundImage()
                    
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                    if let av = self.footerView.viewWithTag(10) as? UIActivityIndicatorView {
                        av.stopAnimating()
                    }
                    
                })
            }
        }
        
    
    }
    
    //MARK: Table methods
    func toggleBackgroundImage() {
        if (self.feedData.count == 0) {
            self.tableView.backgroundColor = UIColorFromRGB(BACKGROUND_GREY)
            self.tableView.backgroundView = self.backgroundImage
        } else {
            self.tableView.backgroundColor = UIColor.whiteColor()
            self.tableView.backgroundView = nil
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var currentPost = feedData.objectAtIndex(indexPath.row) as! Post
        var previewController = PostPreviewViewController(post: currentPost)
        self.navigationController?.pushViewController(previewController, animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //we get an error without this for some reason...
        if (feedData.count == 0) {
            return UITableViewCell();
        }
        
        var cell: PostCell!
        cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell
        if (cell == nil) {
            cell = PostCell(style: UITableViewCellStyle.Default, reuseIdentifier: "PostCell")
        }
        
        let post = feedData.objectAtIndex(indexPath.row) as! Post
        cell.initialize(post)
        
        cell.voteSelector.UpvoteButton.tag = indexPath.row
        cell.voteSelector.DownvoteButton.tag = indexPath.row
        
        cell.voteSelector.UpvoteButton.addTarget(self, action: "upvote:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.voteSelector.DownvoteButton.addTarget(self, action: "downvote:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.flagButton.addTarget(self, action: "flag:", forControlEvents: UIControlEvents.TouchUpInside)

        return cell
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let postCell = cell as? PostCell {
            postCell.cancelLoad()
            postCell.myImage.image = nil
        }
    }
    
    //adds data to the feed
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        var currentOffset = scrollView.contentOffset.y;
        var maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        
        if (maximumOffset - currentOffset <= -40) {
            if let av = self.footerView.viewWithTag(10) as? UIActivityIndicatorView {
                av.startAnimating()
            }
            addDataToFeed()
        }
    }
    
    ///hides the statepicker
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        var rect = self.LocationBar.frame
        
        var origin = max(0, self.tableView.contentOffset.y);
        var origin2 = max(0, self.tableView.contentOffset.y);
        if (origin > 400 ) {
            origin = 400
        }
        
        rect.origin.y = origin
        self.LocationBar.frame = rect
        
        self.locationPicker.frame.origin.y = origin2 + self.view.frame.height+20-200
        self.selectButton.frame.origin.y = origin2 + self.view.frame.height+20-240
    }

    //MARK: State picker
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (row == 0) {
            /* Could probably just set this to the user's current state here */
            currentSelection = userLocation
        } else {
            currentSelection = Location.getStates(userLocation)[row-1]
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Location.getStates(userLocation).count+1
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if (row == 0) {
            if (userLocation != nil) {
                return "\(userLocation!) (my location)"
            } else {
                return "My Location"
            }
        } else {
            return Location.getStates(userLocation) [row-1]
        }
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return self.view.frame.width
    }
    
    
    // MARK: - Voting
    func downvote(sender: AnyObject) {
        let pointInTable: CGPoint = sender.convertPoint(sender.bounds.origin, toView: self.tableView)
        let cellIndexPath = self.tableView.indexPathForRowAtPoint(pointInTable)
        if (cellIndexPath != nil) {
            var cellIndexPathExists: NSIndexPath
            cellIndexPathExists = cellIndexPath as NSIndexPath!
            let cell = self.tableView.cellForRowAtIndexPath(cellIndexPathExists) as! PostCell
            
            if let post = feedData[cellIndexPathExists.row] as? Post {
                var upvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatUpvotes") as? NSArray
                var downvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatDownvotes") as? NSArray
                
                if var existingScore = cell.voteSelector.Score.text?.toInt() {
                
                    if let oID = post.object.objectId {
                        //if downvote already selected
                        if (downvotes != nil && downvotes!.containsObject(oID)) {
                            //remove downvote
                            post.removeDownvote()
                            removeArchivedDownvote(oID, downvotes)
                            existingScore = existingScore + 1
                            
                            self.sortRowsUp(cellIndexPathExists.row)
                    
                            //if Upvote already selected
                        } else if (upvotes != nil && upvotes!.containsObject(oID)) {
                            //remove Upvote
                            post.removeUpvote()
                            removeArchivedUpvote(oID, upvotes)
                            existingScore = existingScore - 1
                            
                            post.addDownvote()
                            archiveDownvote(oID, downvotes)
                            existingScore = existingScore - 1
                            
                            self.sortRowsDown(cellIndexPathExists.row)
                            
                            //nothing selected
                        } else {
                            post.addDownvote()
                            archiveDownvote(oID, downvotes)
                            existingScore = existingScore - 1
                            
                            self.sortRowsDown(cellIndexPathExists.row)
                        }
                        
                        cell.voteSelector.Score.text = "\(existingScore)"
                        cell.updateHighlighted()
                    }
                }
            }
           
        } else {return}
    }
    
    func upvote(sender: AnyObject) {
        let pointInTable: CGPoint = sender.convertPoint(sender.bounds.origin, toView: self.tableView)
        let cellIndexPath = self.tableView.indexPathForRowAtPoint(pointInTable)
        if (cellIndexPath != nil) {
            var cellIndexPathExists: NSIndexPath
            cellIndexPathExists = cellIndexPath as NSIndexPath!
            let cell = self.tableView.cellForRowAtIndexPath(cellIndexPathExists) as! PostCell

            if let post = feedData[cellIndexPathExists.row] as? Post {
                var upvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatUpvotes") as? NSArray
                var downvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatDownvotes") as? NSArray
                
                if var existingScore = cell.voteSelector.Score.text?.toInt() {
                
                    if let oID = post.object.objectId {
                        //if upvote already selected
                        if (upvotes != nil && upvotes!.containsObject(oID)) {
                            //remove upvote
                            post.removeUpvote()
                            removeArchivedUpvote(oID, upvotes)
                            existingScore = existingScore - 1
                            
                            self.sortRowsDown(cellIndexPathExists.row)
                        
                            //if downvote already selected
                        } else if (downvotes != nil && downvotes!.containsObject(oID)) {
                            //remove downvote
                            post.removeDownvote()
                            removeArchivedDownvote(oID, downvotes)
                            existingScore = existingScore + 1
                            
                            post.addUpvote()
                            archiveUpvote(oID, upvotes)
                            existingScore = existingScore + 1
                            
                            self.sortRowsUp(cellIndexPathExists.row)
                            
                            //nothing selected
                        } else {
                            post.addUpvote()
                            archiveUpvote(oID, upvotes)
                            existingScore = existingScore + 1
                            
                            self.sortRowsUp(cellIndexPathExists.row)
                        }
                        
                        cell.voteSelector.Score.text = "\(existingScore)"
                        cell.updateHighlighted()
                    }
                }
            }
            
        } else {return}
    }
    
    func changeLocation(sender: UIButton) {
        self.view.addSubview(locationPicker)
        self.view.addSubview(selectButton)
    }
    
    func selectLocation(sender: UIButton) {
        selectedLocation = currentSelection
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(selectedLocation, forKey: "SelectedLocation")
        
        if (currentSelection != "My Location") {
            LocationButton.selected = true
            LocationButton.setTitle(currentSelection, forState: UIControlState.Normal)
            
            if (currentSelection == userLocation) {
                LocationButton.selected = false
                 LocationButton.setTitle("\(userLocation!) (my location)", forState: UIControlState.Normal)
            }
            
        } else {
            LocationButton.selected = false
            LocationButton.setTitle("My Location", forState: UIControlState.Normal)

        }
        locationPicker.removeFromSuperview()
        selectButton.removeFromSuperview()
        refreshFeed()
    }
    
    func changeSort(sender: UIButton) {
        if (sender.titleLabel?.text == "New") {
            HotButton.selected = false
            BestButton.selected = false
            NewButton.selected = true

            selected = "New"
            refreshFeed()
        }
        else if (sender.titleLabel?.text == "Hot") {
            HotButton.selected = true
            BestButton.selected = false
            NewButton.selected = false
            
            selected = "Hot"
            refreshFeed()
        }
        else if (sender.titleLabel?.text == "Best") {
            HotButton.selected = false
            BestButton.selected = true
            NewButton.selected = false
            
            selected = "Best"
            refreshFeed()
        }
    }
    
    func sortRowsDown(startRow: NSInteger) {
        let lastRowToCheck = feedData.count-1
        var rowToChange = startRow
        while (rowToChange < lastRowToCheck) {
            var post1 = feedData[startRow] as? Post
            var post2 = feedData[rowToChange+1] as? Post
            if (post1?.getScore() >= post2?.getScore()) {
                if (rowToChange != startRow) {
                    swapRows(startRow, row2: rowToChange)
                }
                return
            }
            rowToChange++
        }
        if (rowToChange != startRow) {
            swapRows(startRow, row2: lastRowToCheck)
        }
    }
    
    func sortRowsUp(startRow: NSInteger) {
        let lastRowToCheck = 0
        var rowToChange = startRow
        while (rowToChange > lastRowToCheck) {
            var post1 = feedData[startRow] as? Post
            var post2 = feedData[rowToChange-1] as? Post
            if (post1?.getScore() <= post2?.getScore()) {
                if (rowToChange != startRow) {
                    swapRows(startRow, row2: rowToChange)
                }
                return
            }
            rowToChange--
        }
        if (rowToChange != startRow) {
            swapRows(startRow, row2: lastRowToCheck)
        }
        
    }
    
    func swapRows(row1: NSInteger, row2: NSInteger) {
        let path1 = NSIndexPath(forRow: row1, inSection: 0)
        let path2 = NSIndexPath(forRow: row2, inSection: 0)
        feedData.exchangeObjectAtIndex(row1, withObjectAtIndex: row2)
        
        self.tableView.reloadRowsAtIndexPaths([path1, path2], withRowAnimation: UITableViewRowAnimation.Top)
        
    }

    // MARK: Flag
    func flag(sender: UIButton) {
        let pointInTable: CGPoint = sender.convertPoint(sender.bounds.origin, toView: self.tableView)
        let cellIndexPath = self.tableView.indexPathForRowAtPoint(pointInTable)
        if (cellIndexPath != nil) {
            var cellIndexPathExists: NSIndexPath
            cellIndexPathExists = cellIndexPath as NSIndexPath!
            let cell = self.tableView.cellForRowAtIndexPath(cellIndexPathExists) as! PostCell
            
            var post = feedData[cellIndexPathExists.row] as? Post
            var flags = NSUserDefaults.standardUserDefaults().objectForKey("SplatFlags") as? NSArray
            if let oID = post?.object.objectId {
            
                if (flags != nil && flags!.containsObject(oID)) {
                    //remove flag
                    println("removeflag")
                    post?.removeFlag()
                    removeArchivedFlag(flags, oID)
                    cell.updateHighlighted()
                } else {
                    //add flag
                    println("addflag")
                    post?.addFlag()
                    archiveFlag(flags, oID)
                    cell.updateHighlighted()

                }
            }
        } else {return}

    }
    
    ///handles notifications from other controllers
    func receivedNotification(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), {
            
            if (notification.name == "DoneAddingPost") {
                self.changeSort(self.NewButton)
            }
            if (notification.name == "RemovedPost") {
                self.changeSort(self.NewButton)
            }
            if (notification.name == "RefreshFeed") {
                self.tableView.reloadData()
            }
            if (notification.name == "ReloadFeed") {
                self.changeSort(self.NewButton)
            }
            //call back to main queue to update user interface
        });
    }
    
    //refreshes the feed with an initial 20 posts
    func refreshFeed() {
        switch(selected) {
            case "New":
                loadNewData(0, limit: dataLimit)
                break
            case "Hot":
                 loadHotData(0, limit: dataLimit)
                break
            case "Best":
                loadBestData(0, limit: dataLimit)
                break
            default:
                break
        }
    }
    
    ///Adds data to the feed
    func addDataToFeed() {
        
        if (feedData.count < dataLimit || feedData.count % dataLimit != 0) {
            println("not enough posts")
            if let av = self.footerView.viewWithTag(10) as? UIActivityIndicatorView {
                av.stopAnimating()
            }
        } else if(feedData.count > dataMaxLoadLimit) {
            println("too many posts")
            if let av = self.footerView.viewWithTag(10) as? UIActivityIndicatorView {
                av.stopAnimating()
            }
        } else {
            println("loading more data...")
            switch(selected) {
            case "New":
                loadNewData(0, limit: (feedData.count + dataLimit))
                break
            case "Hot":
                loadHotData(0, limit: (feedData.count + dataLimit))
                break
            case "Best":
                loadBestData(0, limit: (feedData.count + dataLimit))
                break
            default:
                break
            }

        }
        
        
    }
    
}