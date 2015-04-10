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
        
    }
    
    func renderNavbar() {
        var backNavItem = BackNavItem(orientation: BackNavItemOrientation.Right)
        backNavItem.button.addTarget(self, action: "backButtonListener:", forControlEvents: UIControlEvents.TouchUpInside)
        
        var discoverButton = UIButton(frame: CGRectMake(0, 0, 20, 20))
        discoverButton.setImage(UIImage(named: "bucketIcon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        discoverButton.tintColor = UIColor.whiteColor()
        discoverButton.addTarget(self, action: Selector("discoverButtonListener:"), forControlEvents: UIControlEvents.TouchUpInside)
        var discoverNavItem = UIBarButtonItem(customView: discoverButton)
        
        self.navigationItem.leftBarButtonItem = discoverNavItem
        self.navigationItem.rightBarButtonItem = backNavItem
        
        var titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        titleLabel.text = navTitle
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont(name: "Pacifico", size: 20.0)
        titleLabel.sizeToFit()
        
        self.navigationItem.titleView = titleLabel
    }
    
    func backButtonListener(sender: UIButton) {
        (self.navigationController? as RootNavViewController).popVC(.Left)
    }
    func discoverButtonListener(sender: UIButton) {
        (self.navigationController? as RootNavViewController).pushVC(.Right, viewController: DiscoverViewController())
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