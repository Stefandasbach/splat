//
//  GenericPostsTableViewController.swift
//  Splat
//
//  Created by Aaron Tainter on 3/21/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation



import UIKit


class GenericPostsTableViewController : UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableData: NSMutableArray!
    var navTitle: String!
    
    init(posts: NSMutableArray!, title: String!) {
        super.init(style: .Plain)
        
        if posts != nil {
            tableData = posts
        } else {
            tableData = NSMutableArray()
        }
        
        if (title != nil) {
            navTitle = title
        } else {
            navTitle = ""
        }
        
        initNotifications()
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        
        initNotifications()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        initNotifications()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initNotifications()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func initNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNotification:", name: "RefreshFeed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNotification:", name: "RemovedPost", object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        renderNavbar()

    }
    
    func renderNavbar() {
        var backItem = BackNavItem(orientation: BackNavItemOrientation.Left)
        backItem.button.addTarget(self, action: "backButtonListener:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.navigationItem.leftBarButtonItem = backItem
        
        var titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        titleLabel.text = navTitle
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont(name: "Pacifico", size: 20.0)
        titleLabel.sizeToFit()
        
        self.navigationItem.titleView = titleLabel
    }
    
    func backButtonListener(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var currentPost = tableData.objectAtIndex(indexPath.row) as! Post
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
        return tableData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //we get an error without this for some reason...
        if (tableData.count == 0) {
            return UITableViewCell();
        }
        
        var cell: PostCell!
        
        let post = tableData.objectAtIndex(indexPath.row) as! Post
        
        cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell
        
        
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
            postCell.myImage.image = nil
        }
    }
    
    // MARK: - Voting
    func downvote(sender: AnyObject) {
        let pointInTable: CGPoint = sender.convertPoint(sender.bounds.origin, toView: self.tableView)
        let cellIndexPath = self.tableView.indexPathForRowAtPoint(pointInTable)
        if (cellIndexPath != nil) {
            var cellIndexPathExists: NSIndexPath
            cellIndexPathExists = cellIndexPath as NSIndexPath!
            let cell = self.tableView.cellForRowAtIndexPath(cellIndexPathExists) as! PostCell
            
            if let post = tableData[cellIndexPathExists.row] as? Post {
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
                            
                            //if Upvote already selected
                        } else if (upvotes != nil && upvotes!.containsObject(oID)) {
                            //remove Upvote
                            post.removeUpvote()
                            removeArchivedUpvote(oID, upvotes)
                            existingScore = existingScore - 1
                            
                            post.addDownvote()
                            archiveDownvote(oID, downvotes)
                            existingScore = existingScore - 1
                            
                            //nothing selected
                        } else {
                            post.addDownvote()
                            archiveDownvote(oID, downvotes)
                            existingScore = existingScore - 1

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
            
            if let post = tableData[cellIndexPathExists.row] as? Post {
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
                            
                            //if downvote already selected
                        } else if (downvotes != nil && downvotes!.containsObject(oID)) {
                            //remove downvote
                            post.removeDownvote()
                            removeArchivedDownvote(oID, downvotes)
                            existingScore = existingScore + 1
                            
                            post.addUpvote()
                            archiveUpvote(oID, upvotes)
                            existingScore = existingScore + 1
                            
                            //nothing selected
                        } else {
                            post.addUpvote()
                            archiveUpvote(oID, upvotes)
                            existingScore = existingScore + 1

                        }
                        
                        cell.voteSelector.Score.text = "\(existingScore)"
                        cell.updateHighlighted()
                    }
                }
            }
            
        } else {return}
    }
    
    func flag(sender: UIButton) {
        let pointInTable: CGPoint = sender.convertPoint(sender.bounds.origin, toView: self.tableView)
        let cellIndexPath = self.tableView.indexPathForRowAtPoint(pointInTable)
        if (cellIndexPath != nil) {
            var cellIndexPathExists: NSIndexPath
            cellIndexPathExists = cellIndexPath as NSIndexPath!
            let cell = self.tableView.cellForRowAtIndexPath(cellIndexPathExists) as! PostCell
            
            var post = tableData[cellIndexPathExists.row] as? Post
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
    
    func receivedNotification(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), {
        //call back to main queue to update user interface
            
            if (notification.name == "RefreshFeed") {
                self.tableView.reloadData()
            }
            if (notification.name == "RemovedPost") {
                if let post = notification.object as? Post {
                    self.tableData.removeObject(post)
                }
                self.tableView.reloadData()
            }
        });

    }
    

}