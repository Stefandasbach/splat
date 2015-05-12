//
//  NotificationCell.swift
//  Splat
//
//  Created by Stefan Dasbach on 5/11/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation

class NotificationCell: UITableViewCell {
    //this is an error workaround...
    let cellWidth = UIScreen.mainScreen().applicationFrame.width
    
    let UIPadding: CGFloat = 10
    let imageSize: CGFloat = 30
    let timeLabelWidth: CGFloat = 35
    
    var postPicture: UIImageView!
    var notificationText: UILabel!
    var misconductTextView: UITextView!
    var notificationTime: UILabel!
    private var currentNotification: Notification!
    
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
        
        let notificationTextWidth: CGFloat = self.cellWidth - (UIPadding + timeLabelWidth + UIPadding + imageSize + UIPadding)
        notificationText = UILabel(frame: CGRectMake(UIPadding, 0, notificationTextWidth, 50))
        notificationText.font = UIFont.systemFontOfSize(12)
        
        notificationTime = UILabel(frame:  CGRectMake(postPicture.frame.minX - (timeLabelWidth + UIPadding), 0, timeLabelWidth, 20))
        notificationTime.center.y = notificationText.center.y
        notificationTime.font = UIFont.systemFontOfSize(10)
        notificationTime.textColor = UIColor.grayColor()
        notificationTime.textAlignment = .Right
        
        misconductTextView = UITextView(frame: CGRect(x: 10, y: 10, width: cellWidth-20, height: 100 - notificationTime.frame.maxY))
        misconductTextView.textAlignment = NSTextAlignment.Center
        misconductTextView.font = UIFont.systemFontOfSize(12.0)
        misconductTextView.editable = false
        misconductTextView.backgroundColor = UIColor.clearColor()
            
        self.addSubview(misconductTextView)
        self.addSubview(postPicture)
        self.addSubview(notificationText)
        self.addSubview(notificationTime)
    }
    
    func initialize(notification: Notification) {
        currentNotification = notification
        
        var eventCreatedDate = notification.object.createdAt
        var today = NSDate()
        
        /*** Uncomment for non-testing ***/
                let timeSincePost = getStringTimeDiff(eventCreatedDate!, today)
                notificationTime.text = "\(timeSincePost.number)\(timeSincePost.unit)"
        /*** End uncomment ***/
        
        postPicture.image = nil
        if let post = notification.getPost() {
            post.getEventPicture { (imageData) -> Void in
                self.postPicture.image = UIImage(data: imageData)
            }
        }
        
        notificationText.text = notification.getType()
    }
    
    func cancelLoad() {
        if let post = currentNotification.getPost() {
            post.cancelPictureGet()
        }
    }
}
