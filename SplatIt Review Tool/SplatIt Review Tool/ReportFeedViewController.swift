//
//  ReportFeedViewController.swift
//  SplatIt Review Tool
//
//  Created by Aaron Tainter on 5/11/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation
import UIKit
import Parse

class ReportFeedViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    var reportData: NSMutableArray = NSMutableArray()
    var numberOfReportsDict: Dictionary<String, Int> = Dictionary<String, Int>()
    
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNotification:", name: "refreshFeed", object: nil)
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: Selector("getData"), forControlEvents: UIControlEvents.ValueChanged)
        
        getData()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //we get an error without this for some reason...
        if (reportData.count == 0) {
            return UITableViewCell();
        }
        
        var cell: ReportCell!
        cell = tableView.dequeueReusableCellWithIdentifier("ReportCell") as? ReportCell
        if (cell == nil) {
            cell = ReportCell(style: UITableViewCellStyle.Default, reuseIdentifier: "ReportCell")
        }
        
        let post = reportData.objectAtIndex(indexPath.row) as! PFObject
        var numberOfReports = 1
        
        if let oID = post.objectId {
            if let value = numberOfReportsDict[oID] {
                numberOfReports = value
            }
        }
        
        cell.initialize(post, number: numberOfReports)
        
        return cell

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var currentPost = reportData.objectAtIndex(indexPath.row) as! PFObject
        
        var numberOfReports = 1
        
        if let oID = currentPost.objectId {
            if let value = numberOfReportsDict[oID] {
                numberOfReports = value
            }
        }
        
        var previewController = ReportViewController(obj: currentPost, number: numberOfReports)
        self.presentViewController(previewController, animated: true, completion: nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportData.count;
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24.0
    }
    
    
    func getData() {
        var query = PFQuery(className: "Report")
        query.findObjectsInBackgroundWithBlock { (reports, error) -> Void in
            if error != nil {
                println("error")
            } else if let objects = reports {
                var posts = [AnyObject]()
                self.numberOfReportsDict = Dictionary<String, Int>()
                
                for obj in objects {
                    if let pfobj = obj as? PFObject {
                        if let post = pfobj["post"] as? PFObject {
                            
                            if let oID = post.objectId {
                                
                                //get number of reports for one post
                                if let value = self.numberOfReportsDict[oID] {
                                    self.numberOfReportsDict[oID] = value+1
                                } else {
                                    self.numberOfReportsDict[oID] = 1
                                }
                                
                                //add it to the list to query
                                posts.append(oID)
                            }
                        }
                    }
                }
                
                //query for posts that have been reported
                var queryPosts = PFQuery(className: "Post")
                queryPosts.whereKey("objectId", containedIn: posts)
                
                queryPosts.findObjectsInBackgroundWithBlock({ (posts, error) -> Void in
                    if error != nil {
                        println("error")
                    } else if let objects = posts {
                        self.reportData.removeAllObjects()
                        for obj in objects {
                            if let pfobj = obj as? PFObject {
                                self.reportData.addObject(pfobj)
                            }
                        }
                        
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                        
                    } else {
                        println("Can't find posts.")
                    }
                })
                
                
                
            } else {
                println("No reports")
            }
        }
    }
    
    
    ///handles notifications from other controllers
    func receivedNotification(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), {
            if (notification.name == "refreshFeed") {
                self.getData()
            }
        //call back to main queue to update user interface
        });
    }

    
}