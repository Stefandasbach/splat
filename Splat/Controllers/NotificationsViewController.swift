//
//  NotificationsViewController.swift
//  Splat
//
//  Created by Aaron Tainter on 4/7/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation
import Parse

class NotificationsViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableData : NSMutableArray = NSMutableArray()
    var navTitle = "Notifications"
    
    init() {
        super.init(style: .Plain)
        /*** Delete for non-testing ***/
      /*  let reply = Notification()
        reply.setType("reply")
        let warning = Notification()
        warning.setType("warning")
        
        tableData = [reply, warning] */
        /*** End Delete ***/
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    
    init(notifications: NSMutableArray!) {
        super.init(style: .Plain)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        if notifications != nil {
            tableData = notifications
        } else {
            tableData = NSMutableArray()
        }
        
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        renderNavbar()
        Notification.resetIconBadgeNumber(UIApplication.sharedApplication())
        
        var query = PFQuery(className: "Notification")
        query.limit = 35
        query.orderByDescending("createdAt")
        query.whereKey("receiver", equalTo: User().getObject().objectId!)
        query.includeKey("post")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            var notifications = NSMutableArray()
            if (error != nil) { println(error) } else {
                if (objects == nil) { println("No posts") } else {
                    if let objs = objects {
                        for obj in objs {
                            if let pfobj = obj as? PFObject {
                                var post = Notification(pfObject: pfobj)
                                //if (post.getPost() != nil) {
                                    self.tableData.addObject(post)
                                //}
                            }
                        }
                    }
                    
                    self.tableView.reloadData()
                }
            }
        }

    }
    
    func renderNavbar() {
        var feedNavItem = FeedNavItem()
        feedNavItem.button.addTarget(self, action: "feedButtonListener:", forControlEvents: UIControlEvents.TouchUpInside)
        
        var discoverButton = UIButton(frame: CGRectMake(0, 0, 40, 40))
        discoverButton.setImage(UIImage(named: "bucketIcon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        discoverButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        discoverButton.tintColor = UIColor.whiteColor()
        discoverButton.addTarget(self, action: Selector("discoverButtonListener:"), forControlEvents: UIControlEvents.TouchUpInside)
        var discoverNavItem = UIBarButtonItem(customView: discoverButton)
        
        self.navigationItem.leftBarButtonItem = discoverNavItem
        self.navigationItem.rightBarButtonItem = feedNavItem
        
        var titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        titleLabel.text = navTitle
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont(name: "Pacifico", size: 20.0)
        titleLabel.sizeToFit()
        
        self.navigationItem.titleView = titleLabel
    }
    
    func feedButtonListener(sender: UIButton) {
        (self.navigationController as! RootNavViewController).popVC(.Left)
    }
    func discoverButtonListener(sender: UIButton) {
        (self.navigationController as! RootNavViewController).pushVC(.Right, viewController: DiscoverViewController())
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var currentNotification = tableData.objectAtIndex(indexPath.row) as! Notification
        if let post = currentNotification.getPost() {
            var previewController = PostPreviewViewController(post: post)
            self.navigationController?.pushViewController(previewController, animated: true)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let notification = tableData.objectAtIndex(indexPath.row) as? Notification {
            if notification.getType() == "Warning" {
                return 100
            } else if notification.getType() == "Reply" {
                return 50
            }
        }
        return 50
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //we get an error without this for some reason...
        if (tableData.count == 0) {
            return UITableViewCell();
        }
        
        var cell: NotificationCell!
        
        let notification = tableData.objectAtIndex(indexPath.row) as! Notification
        let notificationType = notification.getType()
        
        if notificationType == "Reply" {
            cell = tableView.dequeueReusableCellWithIdentifier("ReplyNotificationCell") as? ReplyNotificationCell
        } else if notificationType == "Warning" {
            cell = tableView.dequeueReusableCellWithIdentifier("WarningNotificationCell") as? WarningNotificationCell
        }
        
        if (cell == nil) {
            if notificationType == "Reply" {
                cell = ReplyNotificationCell(style: UITableViewCellStyle.Default, reuseIdentifier: "ReplyNotificationCell")
            } else if notificationType == "Warning" {
                cell = WarningNotificationCell(style: UITableViewCellStyle.Default, reuseIdentifier: "WarningNotificationCell")
            }
        }
        cell.initialize(notification)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let notificationCell = cell as? ReplyNotificationCell {
            notificationCell.cancelLoad()
            notificationCell.postPicture.image = nil
        }
    }
}