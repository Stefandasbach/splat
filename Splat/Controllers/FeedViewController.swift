//
//  feedViewController.swift
//  Splat
//
//  Created by Aaron Tainter on 3/14/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation
import Parse

class FeedViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    let dataLimit = 20;
    let dataDistance = 5.0;
    let maxDaysHot = 7;
    
    var NewButton:UIButton!
    var HotButton:UIButton!
    var BestButton:UIButton!
    
    var selected: String!
    var feedData = NSMutableArray()
    
    override init() {
        super.init()
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        initNotifictions()
    }
    
    func initNotifictions() {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.renderNavbar()
        
        self.refreshControl = UIRefreshControl()
         self.refreshControl?.addTarget(self, action: Selector("refreshFeed"), forControlEvents: UIControlEvents.ValueChanged)
        
        self.selected = "New"
        self.loadNewData(0, limit: 10)
    }
    
    func renderNavbar() {
        //NAV ICONS//
        var newItemImageButton = UIButton(frame: CGRectMake(0, 0, 20, 20))
        newItemImageButton.setImage(UIImage(named: "createPostIcon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        newItemImageButton.tintColor = UIColor.whiteColor()
        newItemImageButton.addTarget(self, action: Selector("createButtonListener:"), forControlEvents: UIControlEvents.TouchUpInside)
        var newItemNavItem = UIBarButtonItem(customView: newItemImageButton)
        
        var discoverImageButton = UIButton(frame: CGRectMake(0, 0, 20, 20))
        discoverImageButton.setImage(UIImage(named: "bucketIcon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        discoverImageButton.tintColor = UIColor.whiteColor()
        discoverImageButton.addTarget(self, action: Selector("discoverButtonListener:"), forControlEvents: UIControlEvents.TouchUpInside)
        var discoverNavItem = UIBarButtonItem(customView: discoverImageButton)
        
        self.navigationItem.leftBarButtonItem = discoverNavItem
        self.navigationItem.rightBarButtonItem = newItemNavItem
        
        
        //FEED BUTTONS//
        if let navBarHeight = self.navigationController?.navigationBar.frame.height {
            let buttonWidth: CGFloat = 65
        let buttonHeight = navBarHeight
        let buttonY = navBarHeight/2 - buttonHeight/2
        let buttonPadding = 10 as CGFloat
        let buttonPaddingTop = 5 as CGFloat
            
        NewButton = UIButton()
        HotButton = UIButton()
        BestButton = UIButton()
        
        NewButton.frame = CGRectMake(0*buttonWidth, 0, buttonWidth, buttonHeight)
        HotButton.frame = CGRectMake(1*buttonWidth, 0, buttonWidth, buttonHeight)
        BestButton.frame = CGRectMake(2*buttonWidth, 0, buttonWidth, buttonHeight)
        
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
        
        NewButton.contentHorizontalAlignment  = UIControlContentHorizontalAlignment.Center
        NewButton.contentVerticalAlignment    = UIControlContentVerticalAlignment.Center
        HotButton.contentHorizontalAlignment  = UIControlContentHorizontalAlignment.Center
        HotButton.contentVerticalAlignment    = UIControlContentVerticalAlignment.Center
        BestButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        BestButton.contentVerticalAlignment   = UIControlContentVerticalAlignment.Center
        
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
        }
    }
    
    func createButtonListener(sender: UIButton) {
        var createPostVC = CreatePostViewController()
        self.navigationController?.pushViewController(createPostVC, animated: false)
    }
    
    func discoverButtonListener(sender: UIButton) {
        var discoverVC = DiscoverViewController()
        self.navigationController?.pushViewController(discoverVC, animated: false)
    }
    
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
                query.whereKey("geopoint", nearGeoPoint: geopoint, withinMiles: self.dataDistance)
                query.orderByDescending("createdAt")
                query.findObjectsInBackgroundWithBlock({
                    (objects: [AnyObject]!, error: NSError!)->Void in
                    
                    if (skip == 0) {
                        self.feedData.removeAllObjects()
                    }
                    
                    if (error != nil) {
                        println("Error: receiving data")
                        return
                        
                    }
                    
                    for object in objects {
                        if let obj = object as? PFObject {
                            self.feedData.addObject(Post(pfObject: obj))
                        }
                    }
                    
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                    
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
                query.whereKey("geopoint", nearGeoPoint: geopoint, withinMiles: self.dataDistance)
                query.orderByDescending("score")
                query.whereKey("createdAt", greaterThan: sevenDaysAgo)
                query.findObjectsInBackgroundWithBlock({
                    (objects: [AnyObject]!, error: NSError!)->Void in
                    
                    if (skip == 0) {
                        self.feedData.removeAllObjects()
                    }
                    
                    if (error != nil) {
                        println("Error: receiving data")
                        return
                        
                    }
                    
                    for object in objects {
                        if let obj = object as? PFObject {
                            self.feedData.addObject(Post(pfObject: obj))
                        }
                    }
                    
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                    
                })
            }
        }

    }
    
    ///loads the best scores for all time
    func loadBestData(skip: Int, limit: Int) {
       
                var query: PFQuery = PFQuery(className: "Post")
                query.limit = limit
                query.skip = skip
                query.orderByDescending("score")
                query.findObjectsInBackgroundWithBlock({
                    (objects: [AnyObject]!, error: NSError!)->Void in
                    
                    if (skip == 0) {
                        self.feedData.removeAllObjects()
                    }
                    
                    if (error != nil) {
                        println("Error: receiving data")
                        return
                        
                    }
                    
                    for object in objects {
                        if let obj = object as? PFObject {
                            self.feedData.addObject(Post(pfObject: obj))
                        }
                    }
                    
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                    
                })
            
    
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var currentPost = feedData.objectAtIndex(indexPath.row) as Post
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
        
        let post = feedData.objectAtIndex(indexPath.row) as Post
        
        cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as PostCell!
        
        
        if (cell == nil) {
            cell = PostCell(style: UITableViewCellStyle.Default, reuseIdentifier: "PostCell")
        }
        
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
            postCell.Image.image = nil
        }
    }

    
    // MARK: - Voting
    func downvote(sender: AnyObject) {
        let pointInTable: CGPoint = sender.convertPoint(sender.bounds.origin, toView: self.tableView)
        let cellIndexPath = self.tableView.indexPathForRowAtPoint(pointInTable)
        if (cellIndexPath != nil) {
            var cellIndexPathExists: NSIndexPath
            cellIndexPathExists = cellIndexPath as NSIndexPath!
            let cell = self.tableView.cellForRowAtIndexPath(cellIndexPathExists) as PostCell
            
            if let post = feedData[cellIndexPathExists.row] as? Post {
                var upvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatUpvotes") as NSArray!
                var downvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatDownvotes") as NSArray!
                
                if var existingScore = cell.voteSelector.Score.text?.toInt() {
                
                    if let oID = post.object.objectId {
                        //if downvote already selected
                        if (downvotes != nil && downvotes.containsObject(oID)) {
                            //remove downvote
                            post.removeDownvote()
                            removeArchivedDownvote(post, oID, downvotes)
                            existingScore = existingScore + 1
                            
                            self.sortRowsUp(cellIndexPathExists.row)
                    
                            //if Upvote already selected
                        } else if (upvotes != nil && upvotes.containsObject(oID)) {
                            //remove Upvote
                            post.removeUpvote()
                            removeArchivedUpvote(post, oID, upvotes)
                            existingScore = existingScore - 1
                            
                            archiveDownvote(post, oID, downvotes)
                            existingScore = existingScore - 1
                            
                            self.sortRowsDown(cellIndexPathExists.row)
                            
                            //nothing selected
                        } else {
                            archiveDownvote(post, oID, downvotes)
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
            let cell = self.tableView.cellForRowAtIndexPath(cellIndexPathExists) as PostCell

            if let post = feedData[cellIndexPathExists.row] as? Post {
                var upvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatUpvotes") as NSArray!
                var downvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatDownvotes") as NSArray!
                
                if var existingScore = cell.voteSelector.Score.text?.toInt() {
                
                    if let oID = post.object.objectId {
                        //if upvote already selected
                        if (upvotes != nil && upvotes.containsObject(oID)) {
                            //remove upvote
                            post.removeUpvote()
                            removeArchivedUpvote(post, oID, upvotes)
                            existingScore = existingScore - 1
                            
                            self.sortRowsDown(cellIndexPathExists.row)
                        
                            //if downvote already selected
                        } else if (downvotes != nil && downvotes.containsObject(oID)) {
                            //remove downvote
                            post.removeDownvote()
                            removeArchivedDownvote(post, oID, downvotes)
                            existingScore = existingScore + 1
                            
                            archiveUpvote(post, oID, upvotes)
                            existingScore = existingScore + 1
                            
                            self.sortRowsUp(cellIndexPathExists.row)
                            
                            //nothing selected
                        } else {
                            archiveUpvote(post, oID, upvotes)
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
    
    func changeSort(sender: UIButton) {
        if (sender.titleLabel?.text == "New") {
            HotButton.selected = false
            BestButton.selected = false
            NewButton.selected = true

            selected = "New"
            loadNewData(0, limit: 20)
        }
        else if (sender.titleLabel?.text == "Hot") {
            HotButton.selected = true
            BestButton.selected = false
            NewButton.selected = false
            
            selected = "Hot"
            loadHotData(0, limit: 20)
        }
        else if (sender.titleLabel?.text == "Best") {
            HotButton.selected = false
            BestButton.selected = true
            NewButton.selected = false
            
            selected = "Best"
            loadBestData(0, limit: 20)
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
            let cell = self.tableView.cellForRowAtIndexPath(cellIndexPathExists) as PostCell
            
            var post = feedData[cellIndexPathExists.row] as? Post
            var flags = NSUserDefaults.standardUserDefaults().objectForKey("SplatFlags") as NSArray!
            if let oID = post?.object.objectId {
            
                if (flags != nil && flags.containsObject(oID)) {
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
    
}