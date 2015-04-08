//
//  NotificationsViewController.swift
//  Splat
//
//  Created by Aaron Tainter on 4/7/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation

class NotificationsViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableData: NSMutableArray!
    var navTitle = "Notifications"
    
    init(notifications: NSMutableArray!) {
        super.init()
        
        if notifications != nil {
            tableData = notifications
        } else {
            tableData = NSMutableArray()
        }
        
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
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
        var currentNotification = tableData.objectAtIndex(indexPath.row) as Notification
        if let post = currentNotification.getPost() {
            var previewController = PostPreviewViewController(post: post)
            self.navigationController?.pushViewController(previewController, animated: true)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
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
        
        let notification = tableData.objectAtIndex(indexPath.row) as Notification
        
        cell = tableView.dequeueReusableCellWithIdentifier("NotificationCell") as NotificationCell!
        
        
        if (cell == nil) {
            cell = NotificationCell(style: UITableViewCellStyle.Default, reuseIdentifier: "NotificationCell")
        }
        
        cell.initialize(notification)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let notificationCell = cell as? NotificationCell {
            notificationCell.cancelLoad()
            notificationCell.postPicture.image = nil
        }
    }
}