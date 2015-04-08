//
//  NotificationCell.swift
//  Splat
//
//  Created by Aaron Tainter on 4/7/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation

class NotificationCell: UITableViewCell {
    let UIPadding: CGFloat = 10
    let imageSize: CGFloat = 30
    
    var postPicture: UIImageView!
    private var notificationTime: UILabel!
    private var notificationText: UILabel!
    
    private var currentNotification: Notification!
    
    //this is an error workaround...
    let cellWidth = UIScreen.mainScreen().applicationFrame.width
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        renderCell()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        renderCell()
    }
    
    func renderCell() {
        postPicture = UIImageView(frame: CGRectMake(cellWidth - imageSize - UIPadding, UIPadding, imageSize, imageSize))
        postPicture.contentMode = UIViewContentMode.ScaleAspectFill
        postPicture.clipsToBounds = true
        postPicture.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        
        notificationText = UILabel(frame: CGRectMake(UIPadding, 0, 200, 50))
        notificationText.text = "Someone replied to your post."
        notificationText.font = UIFont.systemFontOfSize(12)
        
        notificationTime = UILabel(frame:  CGRectMake(notificationText.frame.maxX, 0, 50, 50))
        notificationTime.center.y = notificationText.center.y
        notificationTime.font = UIFont.systemFontOfSize(12)
        notificationTime.textColor = UIColor.grayColor()
        
        
        self.addSubview(postPicture)
        self.addSubview(notificationText)
        self.addSubview(notificationTime)
    }
    
    func initialize(notification: Notification) {
        currentNotification = notification
        
        var eventCreatedDate = notification.object.createdAt
        var today = NSDate()
        
        let timeSincePost = getStringTimeDiff(eventCreatedDate, today)
        notificationTime.text = "\(timeSincePost.number)\(timeSincePost.unit)"
        
        postPicture.image = nil
        if let post = notification.getPost()? {
            post.getEventPicture { (imageData) -> Void in
                self.postPicture.image = UIImage(data: imageData)
            }
        }

        
    }
    
    func cancelLoad() {
        if let post = currentNotification.getPost()? {
            post.cancelPictureGet()
        }
    }
}